# Cloud Storage - 버킷 내 파일 다운로드 기능 구성

## Cloud Storage Bucket 내 파일 다운로드 방법 

1. gcsfuse를 통해 서버 내 버킷을 마운트 후, repo 서버 구성
    - apache , Nginx 등으로 디렉토리에 직접 접근하여 파일을 다운로드하는 방식

2. 버킷 권한에 공개엑세스 추가 
    - 버킷 권한에 allusers or allauthenticatedUsers 대상으로 접근권한을 부여
    - 각 객체별 공개 URL로 접근
    
3. 버킷 접근 권한을 가지는 IAM 계정을 통해 gsutil 등을 사용
    - 별도 IAM 계정을 구성한 뒤, gsutil/gcloud 명령을 통해 버킷 내 파일을 다운로드

4. Signed URL을 생성 후 해당 URL로 접근
    - 적절한 권한을 가진 IAM 계정을 통해 버킷 내 객체별 Signed URL을 생성 가능 
    - Signed URL은 별도 권한이 없더라도 일정 기간동안 객체에 접근이 가능한 URL


## Cloud Run Function/Container를 통한 버킷 내 파일 다운로드 기능 구현 

### 아키텍쳐 구성도
```
Google DNS - GCP LB - ┏Backend #1 - Cloud Run Function #1 (전체 파일 목록 및 URL 출력)
                      ┗Backend #2 - Cloud Run Function #2 (Signed URL 생성 및 Redirection)
```
1. LB에 연결된 도메인을 통해 접근 
2. LB 라우팅 규칙에 따라 URL 경로 별 백엔드 호출 
3. 1번 백엔드 호출시, 현재 버킷 내 디렉토리별 파일 목록을 출력 
    - 별도 서버에 구성된 DB 테이블 내에 기록된 파일 목록을 출력
    - 각 파일별로 Function #2를 호출하는 도메인 URL을 같이 출력 
4. 3번에서 추출한 URL을 통해 Function #2를 호출하는 URL에 연결
5. URL 연결 시, URL의 경로에 해당하는 파일의 Signed URL 생성 
6. Signed URL 생성 후, 해당 URL로 리디렉션하여 파일에 접근 


### DB 테이블 구성 
- Mariadb를 통해 다음과 같이 테이블 구성

#### init.sql
```sql
CREATE DATABASE gcs_bucket_test
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE gcs_bucket_test.bucket_file_table (
  file_id INT AUTO_INCREMENT PRIMARY KEY,
  company_code VARCHAR(255),
  file_name VARCHAR(1024)
) CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
```

#### init.sql 실행
```sh
$ mysql -u root < init.sql
```


#### 참고. 필요시 MariaDB docker Container 실행 
```sh
docker run -d \
  --name mariadb-main \
  --network mariadb-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=connect_test_db \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=appuserpass \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -v $(pwd)/my_cnf/mariadb_main.cnf:/etc/mysql/mariadb.cnf \
  -p 3306:3306 \
  mariadb:10.5.10
```

*** 

### 버킷 내 객체 목록을 DB 테이블에 적재 

- 별도 Docker Container를 실행하여 버킷 내 파일목록을 DB에 자동으로 적재 
- 버킷 내 하위 디렉토리로 구성된 것으로 가정 
    - EX) 
    ```
    버킷 - file_dir1 - file1
         - file_dir2 - file2
         - file_dir3 - file3
    ```
- google.cloud.storage 라이브러리 사용을 위해 SA 계정 키 파일 필요


#### requirements.txt
```
google-cloud-storage==2.10.0
pymysql==1.0.3
```

#### insert_test_data.py
```py
import os
import pymysql
from google.cloud import storage

def get_db_connection():
    conn = pymysql.connect(
        host=os.environ.get('DB_HOST'),
        port=int(os.environ.get('DB_PORT', 3306)),
        user=os.environ.get('DB_USER'),
        password=os.environ.get('DB_PASSWORD'),
        db=os.environ.get('DB_NAME'),
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False
    )
    return conn

def list_and_store_files(bucket_name, root_prefix=""):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blobs_iter = bucket.list_blobs(prefix=root_prefix, delimiter='/')
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            for page in blobs_iter.pages:
                company_codes = page.prefixes  # 하위 디렉토리명 목록
                for company_code_prefix in company_codes:
                    company_code = company_code_prefix[len(root_prefix):].rstrip('/')
                    blobs = bucket.list_blobs(prefix=company_code_prefix, delimiter='/')
                    for blob in blobs:
                        file_name = blob.name[len(company_code_prefix):]
                        if not file_name.strip():
                            continue
                        print(f"company_code: '{company_code}', file_name: '{file_name}'")
                        sql = """
                            INSERT IGNORE INTO bucket_file_table (company_code, file_name)
                            VALUES (%s, %s)
                        """
                        cursor.execute(sql, (company_code, file_name))
        connection.commit()
    finally:
        connection.close()


if __name__ == "__main__":
    BUCKET_NAME = os.environ.get("BUCKET_NAME")
   #ROOT_PREFIX = "pdf_export/" 버킷 아래 하위 디렉토리가 하나 더있는경우 사용
    if not BUCKET_NAME:
        raise ValueError("BUCKET_NAME 환경변수가 설정되어 있지 않습니다.")
    list_and_store_files(BUCKET_NAME, ROOT_PREFIX)
    print("버킷 하위 파일 정보를 DB에 저장했습니다.")
```


#### dockerfile
```
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY insert_test_data.py ./

ENV GOOGLE_APPLICATION_CREDENTIALS=/secrets/gcp-service-account.json

CMD ["python", "insert_test_data.py"]
```


#### Docker Container 실행 
- DB 연결 정보를 환경 변수에 넣어 실행
```sh
docker build -t data-insert-batch .

docker run \
        #--network mariadb-network \ # DB를 docker로 실행한 경우 사용
        --name data-insert-batch \
        -e BUCKET_NAME=gcp-in-ca-test-bucket-wocheon07 \
        -e DB_HOST=mariadb-main  \
        -e DB_USER=root \
        -e DB_PASSWORD=rootpass \
        -e DB_NAME=gcs_bucket_test \
        -v ./service-account.json:/secrets/gcp-service-account.json \
        data-insert-batch
```

#### 실행 결과 확인

```
MariaDB [gcs_bucket_test]> select * from bucket_file_table
    -> ;
+---------+--------------+---------------------------------+
| file_id | company_code | file_name                       |
+---------+--------------+---------------------------------+
|       1 | 1111         | testfile_1.txt                  |
|       2 | 2222         | testfile_2.pdf                  |
|       3 | 3333         | testfile_3.json                 |
|       4 | backup       | backup_to_gcpbucket.sh          |
|       5 | backup       | vm_startup_script_CentOS7.sh    |
|       6 | backup       | vm_startup_script_Ubuntu2004.sh |
+---------+--------------+---------------------------------+
```


***


### Cloud Run Function #1 - 전체 파일 목록 및 URL 출력 
- 함수명 : fn-calldb-buckect-file-list
- Runtime : python 3.10 
- 인그레스 : 전체 
- VPC : DB 서버에 연결 가능한 네트워크로 구성 
    - subnet, 네트워크 태그 모두 확인 
- 인증 : 공개 엑세스 허용 
- 함수 진입점 : cloud_function_handler

#### 환경 변수 목록 
- DB_HOST=192.168.1.100
- DB_USER=root
- DB_PASSWORD=rootpass
- DB_NAME=gcs_bucket_test

#### requirements.txt
```
functions-framework==3.*
pymysql
```

#### main.py
```py
import pymysql
import os
from flask import jsonify

DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')

CUSTOM_DOMAIN = "http://callfn.wocheon.site"  # 실제 배포 도메인으로 변경

def get_db_connection():
    return pymysql.connect(host=DB_HOST,
                           user=DB_USER,
                           password=DB_PASSWORD,
                           db=DB_NAME,
                           cursorclass=pymysql.cursors.DictCursor)

def cloud_function_handler(request):
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            # 변경된 컬럼명에 맞게 쿼리 수정
            cursor.execute("SELECT file_id, company_code, file_name FROM bucket_file_table")
            results = cursor.fetchall()
        connection.close()

        files = {}
        for row in results:
            file_id = row['file_id']
            company_code = row['company_code']
            file_name = row['file_name']
            files[file_name] = {
                "url": f"{CUSTOM_DOMAIN}/download/{company_code}/{file_name}",
                "file_id": file_id
            }

        return jsonify({
            "status": "ok",
            "deployed_version": "2025-08-29-deploy-test",
            "files": files
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
```

#### Function #1 실행 테스트 
```sh
$ curl https://fn-calldb-buckect-file-list-487401709675.asia-northeast3.run.app | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   726  100   726    0     0   4236      0 --:--:-- --:--:-- --:--:--  4245
{
  "deployed_version": "2025-08-29-deploy-test",
  "files": {
    "backup_to_gcpbucket.sh": {
      "file_id": 4,
      "url": "http://callfn.wocheon.site/download/backup/backup_to_gcpbucket.sh"
    },
    "testfile_1.txt": {
      "file_id": 1,
      "url": "http://callfn.wocheon.site/download/1111/testfile_1.txt"
    },
    "testfile_2.pdf": {
      "file_id": 2,
      "url": "http://callfn.wocheon.site/download/2222/testfile_2.pdf"
    },
    "testfile_3.json": {
      "file_id": 3,
      "url": "http://callfn.wocheon.site/download/3333/testfile_3.json"
    },
    "vm_startup_script_CentOS7.sh": {
      "file_id": 5,
      "url": "http://callfn.wocheon.site/download/backup/vm_startup_script_CentOS7.sh"
    },
    "vm_startup_script_Ubuntu2004.sh": {
      "file_id": 6,
      "url": "http://callfn.wocheon.site/download/backup/vm_startup_script_Ubuntu2004.sh"
    }
  },
  "status": "ok"
}

```

***

### Cloud Run Function #2 - Signed URL 생성 및 리디렉션 
- 함수명 : fn-calldb-buckect-file-url-redirect
- Runtime : python 3.10 
- 인그레스 : 전체 
- VPC : DB 서버에 연결 가능한 네트워크로 구성 
    - subnet, 네트워크 태그 모두 확인 
- 인증 : 공개 엑세스 허용 
- 함수 진입점 : cloud_function_handler


#### 보안비밀 생성 
- SA 키 파일을 Function에서 사용하기 위해 보안비밀 관리자에서 키파일을 보안비밀로 생성
- Secret : account_key

#### IAM 권한 설정 
- 함수에서 사용할 서비스 계정에 다음 IAM 권한이 필요
    - storage.object.get
    - storage.objects.list
    - secretmanager.versions.access

- 다음 역할을 통해 필요 IAM 권한을 부여
    - roles/secretmanager.secretAccessor
        - 보안 비밀 관리자 보안 비밀 접근자
    - roles/storage.objectViewer
        - 저장소 개체 뷰어
    - roles/run.invoker
        - Cloud Run 호출자
 

#### 환경 변수
- BUCKET_NAME=gcp-in-ca-test-bucket-wocheon07
- PROJECT_ID=xxxxxxx
- SECRET_ID=account_key
- BUCKET_ACCESS_MODE=PRIVATE

#### requirements.txt
```
functions-framework==3.*
Flask
google-cloud-storage
google-cloud-secret-manager
google-auth
pymysql
```

#### main.py

```py
from flask import redirect
from google.cloud import storage, secretmanager
from google.oauth2 import service_account
import datetime
import os
import json

project_id = os.environ.get('PROJECT_ID')
secret_id = os.environ.get('SECRET_ID')
BUCKET_NAME = os.environ.get('BUCKET_NAME')
BUCKET_ACCESS_MODE = os.environ.get('BUCKET_ACCESS_MODE', 'PRIVATE').upper()

def access_secret_version(project_id, secret_id, version_id="latest"):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(name=name)
    secret_string = response.payload.data.decode("UTF-8")
    return secret_string

def generate_signed_url(blob_name, expiration_minutes=15):
    key_json_str = access_secret_version(project_id, secret_id)
    credentials_info = json.loads(key_json_str)
    credentials = service_account.Credentials.from_service_account_info(credentials_info)
    storage_client = storage.Client(credentials=credentials)
    bucket = storage_client.bucket(BUCKET_NAME)
    blob = bucket.blob(blob_name)
    url = blob.generate_signed_url(expiration=datetime.timedelta(minutes=expiration_minutes))
    return url

def generate_public_url(blob_name):
    return f"https://storage.googleapis.com/{BUCKET_NAME}/{blob_name}"

def cloud_function_handler(request):
    try:
        path = request.path
        # 요청 URL에서 company_code와 파일명 추출, 예: /download/company_code/filename.txt
        parts = path.split('/')
        if len(parts) < 4 or parts[1].lower() != 'download':
            return "Invalid URL path", 400
        company_code = parts[2]
        file_name = parts[3]

        blob_name = f"{company_code}/{file_name}"

        if BUCKET_ACCESS_MODE == 'PUBLIC':
            redirect_url = generate_public_url(blob_name)
        else:
            redirect_url = generate_signed_url(blob_name)
        return redirect(redirect_url)
    except Exception as e:
        return f"Error generating download URL: {e}", 500
```

#### Function #2 실행 테스트 
- wget으로 접근시, 정상적으로 리디렉션 후 파일다운로드 가능 확인

```sh
$ wget https://fn-calldb-buckect-file-url-redirect-487401709675.asia-northeast3.run.app/download/backup/backup_to_gcpbucket.sh
.....
HTTP request sent, awaiting response... 302 Found
Location: https://storage.googleapis.com/gcp-in-ca-test-bucket-wocheon07/backup/backup_to_gcpbucket.sh?Expires=1757409593&GoogleAccessId=487401709675-compute%40developer.gserviceaccount.com&Signature=YmTzFIwdMqrSgi3hMBA%2BHwjMxvec%2Fgh%2BofzPR9ouBDEgNTteR4Ftl2DoiwrzeppGqAxX%2BF73YMQJkwb4Vyiyu%2FfskSfbRM%2FX%2BYsoX4gBNMEuKdl5%2F0t4YsfQMTJz9DYR649aQv%2B4%2BeHwjACpJmY2bVNiPOEKpe6mlPBwFoe2J%2Bjitva9GI%2FKVCaGT4suaj5iHIMerVaerRvJ9SGuIhddndTWSqk%2F0e06F6rPhzED6vkFUvhjJBkxb3wsGGeptE%2FzWetzDX9q7TBDkNw%2FrV2BAm9COi2PX2nb7eT5S6%2FDb47sSql5hGY7w4pr0RLkVdgEl1Kf6DcAMDbcXd5WE2Wu3Q%3D%3D [following]
--2025-09-09 18:04:53--  https://storage.googleapis.com/gcp-in-ca-test-bucket-wocheon07/backup/backup_to_gcpbucket.sh?Expires=1757409593&GoogleAccessId=487401709675-compute%40developer.gserviceaccount.com&Signature=YmTzFIwdMqrSgi3hMBA%2BHwjMxvec%2Fgh%2BofzPR9ouBDEgNTteR4Ftl2DoiwrzeppGqAxX%2BF73YMQJkwb4Vyiyu%2FfskSfbRM%2FX%2BYsoX4gBNMEuKdl5%2F0t4YsfQMTJz9DYR649aQv%2B4%2BeHwjACpJmY2bVNiPOEKpe6mlPBwFoe2J%2Bjitva9GI%2FKVCaGT4suaj5iHIMerVaerRvJ9SGuIhddndTWSqk%2F0e06F6rPhzED6vkFUvhjJBkxb3wsGGeptE%2FzWetzDX9q7TBDkNw%2FrV2BAm9COi2PX2nb7eT5S6%2FDb47sSql5hGY7w4pr0RLkVdgEl1Kf6DcAMDbcXd5WE2Wu3Q%3D%3D
Resolving storage.googleapis.com (storage.googleapis.com)... xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx, ...
Connecting to storage.googleapis.com (storage.googleapis.com)|xxx.xxx.xxx.xxx|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 470 [application/x-shellscript]
Saving to: ‘backup_to_gcpbucket.sh’

backup_to_gcpbucket.sh                  100%[=============================================================================>]     470  --.-KB/s    in 0s

2025-09-09 18:04:53 (5.39 MB/s) - ‘backup_to_gcpbucket.sh’ saved [470/470]
```


## Cloud Run Container 배포 방법
- 인라인편집기로 생성시 배포 유형이 함수로 지정되며, Artifact Registry를 통한 이미지 배포로 수정시 제대로 반영되지 않는 문제 발생

- 기존 함수 삭제 후, Artifact Registry에 이미지 Push > Cloud Run Container로 배포하는 형태로 구성
    - Cloud Build, Jenkins 등의 CI/CD 연계 가능 


### gcloud를 통한 Artifact Registry 인증 
- docker image push가 가능하도록 
```
gcloud auth configure-docker asia-northeast3-docker.pkg.dev
```

### 배포 환경 구성하기
- Cloud Run 컨테이너 배포 아키텍쳐
```
docker_image -> Artifact Registry 
                └ 배포 이미지     -> Cloud Run Container
```

- Cloud Run 함수에 설정한 환경변수는 별도 파일로 저장하여 배포시 사용
- 이미지로 배포시에는 유형이 `함수`가아난 `컨테이너`로 지정됨
- latest 태그를 가지는 이미지를 사용하여 함수를 재배포하는 형태

#### 환경변수 파일 구성
- `envlist` 라는 파일을 생성하여 해당 파일에 환경변수를 저장
> envlist
```
DB_HOST=192.168.1.100
DB_USER=appuser
DB_PASSWORD=appuserpass
DB_NAME=gcs_bucket_test
```

#### dockerfile
- Cloud Run 에서 사용할 수 있도록 dockerfile을 구성
- ENV로 함수 진입점을 선언
- 기본 포트인 8080포트 사용

> dockerfile
```
# 베이스 이미지 Python 3.10 기반
FROM python:3.10-slim

# 작업 디렉터리 설정
WORKDIR /app

# 의존성 복사 및 설치
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY . .

# Cloud Functions Gen2 진입점 환경변수 설정 (예: 함수 진입점 함수명)
ENV FUNCTION_TARGET=cloud_function_handler

# 함수가 gRPC 기반으로 실행되도록 진입점 설정
CMD ["functions-framework", "--target=cloud_function_handler", "--port=8080"]
```

#### docker 이미지 빌드 및  Artifact Registry에 Push

- Artifact Registry에 push가 가능하도록 이미지 tag를 `[저장소명]/[함수명]:[tag]` 형태로 지정

```
#!/bin/bash

gar_repo="asia-northeast3-docker.pkg.dev/gcp-in-ca/cloud-run-source-deploy"
function_name="fn-calldb-buckect-file-list"
tag="latest"

# 빌드
docker build --no-cache -t ${gar_repo}/${function_name}:${tag} .

# 푸시
docker push ${gar_repo}/${function_name}:${tag}
```


#### Cloud Run Container 배포 
- envlist 파일을 읽어서 `--set-env-vars` 옵션을 통해 환경변수 전달 
- 기존 함수/컨테이너와 설정을 동일하게 구성한뒤 배포 진행
```
#!/bin/bash

gar_repo="asia-northeast3-docker.pkg.dev/gcp-in-ca/cloud-run-source-deploy"
function_name="fn-calldb-buckect-file-list"
tag="latest"

env_vars=$(cat envlist | grep -v '^#' | xargs | sed 's/ /,/g')

gcloud run deploy ${function_name} \
  --image ${gar_repo}/${function_name}:${tag} \
  --region asia-northeast3 \
  --platform managed \
  --set-env-vars $env_vars \
  --network=test-vpc-1 \
  --subnet=test-vpc-sub-01 \
  --network-tags=mariadb \
  --allow-unauthenticated
```