# Docker - Google Artifact Registry 연동

## 개요 

- GKE 사용시 노드내에 이미지가 없는 경우 imagePullbackoff 발생 
    - 이 경우 각 노드별로 Docker login을 진행하거나 Artifact Registry를 사용하여 이미지를 가져올수 있도록 설정해야함

- Docker Hub와 거의 동일한 형태로 사용가능하며 비용이 적음

- Docker 외 다른 registry로도 사용가능 
    - yum, apt, maven 등 

## Google Artifact Registry 인증 

### GAR(Google Artifact Registry) 사용시 필요 IAM 역할 
- 대상 
    - 기본 서비스 계정 

- 권한 
    - 다음 권한 중 적절 권한 부여 
    - Artifact Registry 관리자 (Manager)
    - Artifact Registry 작성자 (Writer)
    - Artifact Registry 리더 (Viewer)
    - 서비스 계정 토큰 생성자 (엑세스토큰을 통한 인증시 필요)

### GAR(Google Artifact Registry) 인증 방법

#### 1. 사용자 인증 정보 도우미
- gcloud 명령어를 통해 인증을 구성하는 방법

- 인증 절차 
    - 사용자 인증정보 인증 구성
    ```
    gcloud auth login
    ```

    - Gcloud로 GAR 인증 
    ```
    gcloud auth configure-docker {GAR리전}-docker.pkg.dev
    ```

- 인증정보 저장위치
    - Linux
        - $HOME/.docker/config.json
    - Windows
        - %USERPROFILE%/.docker/config.json


#### 2. 독립형 사용자 인증 정보 도우미
-  gcloud CLI를 사용할 수 없는 시스템에서 Artifact Registry에 인증하도록 Docker를 구성할때 사용

- 인증 절차 
    - 인증 도우미 설치용 스크립트 생성 
    >vi gar_identificate.sh
    ```sh
    VERSION=2.1.22
    OS=linux  # or "darwin" for OSX, "windows" for Windows.
    ARCH=amd64  # or "386" for 32-bit OSs

    curl -fsSL "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${VERSION}/docker-credential-gcr_${OS}_${ARCH}-${VERSION}.tar.gz" \
    | tar xz docker-credential-gcr \
    && chmod +x docker-credential-gcr && sudo mv docker-credential-gcr /usr/bin/
    ```

    - Artifact Registry 사용자 인증 정보를 사용하도록 Docker를 구성

    ```sh
    docker-credential-gcr configure-docker --registries={GAR 리전}-docker.pkg.dev
    ```

- 인증정보 저장위치
    - Linux
        - $HOME/.docker/config.json
    - Windows
        - %USERPROFILE%/.docker/config.json


#### 3. 액세스 토큰 사용
- 해당 방법을 통한 인증은 60분간만 유효하므로 임시로 인증 수행 후 다른 방법으로 인증을 갱신 혹은 정기 작업으로 수행 필요

- 서비스 계정에 서비스 계정 토큰 생성자 IAM 역할 부여 필요

- 서비스 토큰 생성하여 docker login 수행 
```
gcloud auth print-access-token \
    --impersonate-service-account ACCOUNT | docker login \
    -u oauth2accesstoken \
    --password-stdin https://{GAR 리전}-docker.pkg.dev
```

#### 4. 서비스 계정 키 사용
- 서비스 계정의 키를 사용하여 인증하는 방법 
    - 키 파일은 따로 업로드 필요

- 인증 절차 

    - base64로 키 파일 인코딩 
        - 수행하지않아도 인증에는 문제 없음        
    ```
    base64 service_account_key.json > service_account_key_enc.json
    ```

    - 키파일로 Docker login 수행 
    ```    
    cat service_account_key_enc.json | docker login -u _json_key_base64 --password-stdin https://{GAR 리전}-docker.pkg.dev
    ```

## GAR에서 컨테이너 이미지 내보내기(push) 및 가져오기(pull)

- GAR에 push하기 위해서는 다음 형태로 이미지 태그를 지정해야함

```sh
{GAR 리전}-docker.pkg.dev/{GCP 프로젝트 ID}/{GAR 저장소명}/{IMAGE명}:{version}
```

>ex) 
```
asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test:1.0
```

- 로컬에 있는 이미지를 다음 형태로 변경 
```
docker image tag crawler_test asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test:1.0
```

- 컨테이너 이미지 push 
```sh
$ docker image push asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test

Using default tag: latest
The push refers to repository [asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test]
0dbc18fadba8: Pushed
342057a08fa9: Pushed
cdf98729ffbc: Pushed
30337f5d62b2: Pushed
8dedb761dddc: Pushed
920b0b0b3bd7: Pushed
b0e4a5454929: Pushed
1446d1b15175: Pushed
7810e995d400: Pushed
3999ea91fb6e: Pushed
43df359389fd: Pushed
d3e8d42f967c: Pushed
5d64de483bf5: Pushed
latest: digest: sha256:521f45fc92c68ce0eb94432907c70fde3cf04ab4ab618cdd456b43ca259a7642 size: 3051
```


- 컨테이너 이미지 pull 
```sh
$ docker image pull asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test:latest

latest: Pulling from cslee-arch01/testgke-gar/crawler_test
Digest: sha256:521f45fc92c68ce0eb94432907c70fde3cf04ab4ab618cdd456b43ca259a7642
Status: Downloaded newer image for asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test:latest
asia-northeast3-docker.pkg.dev/cslee-arch01/testgke-gar/crawler_test:latest
```
