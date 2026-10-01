# AWS Glue와 Redshift 연동 방법

## 개요
AWS Glue는 데이터 준비 및 변환을 자동화하는 서버리스 데이터 통합 서비스입니다. AWS Redshift는 완전관리형 데이터 웨어하우스로, 대규모 데이터 분석에 적합합니다. 이 문서에서는 AWS Glue와 Redshift를 연동하여 데이터를 효율적으로 처리하고 분석하는 방법을 설명합니다.

---

## 1. AWS Glue와 Redshift 연동 준비

### 1.1 IAM 역할 생성
1. AWS Management Console에서 IAM 서비스로 이동합니다.
2. Glue와 Redshift에 필요한 권한을 가진 IAM 역할을 생성합니다.
    - Glue용 정책: `AWSGlueServiceRole`
    - Redshift용 정책: `AmazonRedshiftFullAccess`
3. 생성된 역할을 Glue와 Redshift에 각각 연결합니다.

**참고**  
IAM 역할에 과도한 권한을 부여하지 않도록 최소 권한 원칙을 준수하세요.

---

### 1.2 Redshift 클러스터 생성
1. Redshift 콘솔에서 새 클러스터를 생성합니다.
2. 클러스터의 보안 그룹에서 Glue가 접근할 수 있도록 인바운드 규칙을 설정합니다.
    - Glue가 실행되는 VPC와 동일한 네트워크 환경이어야 합니다.

**참고**  
보안 그룹 설정 시 IP 범위를 제한하여 보안을 강화하세요.

---

### 1.3 Glue 데이터베이스 및 크롤러 생성
1. Glue 콘솔에서 데이터베이스를 생성합니다.
2. 크롤러를 생성하여 Redshift 테이블을 스캔하고 메타데이터를 Glue 데이터 카탈로그에 저장합니다.
    - 크롤러의 데이터 원본으로 Redshift를 선택합니다.
    - 크롤러 실행 후 데이터 카탈로그에서 테이블이 생성되었는지 확인합니다.

**참고**  
크롤러 실행 주기를 적절히 설정하여 불필요한 비용 발생을 방지하세요.

---

## 2. AWS Glue 작업(Job) 생성 및 실행

### 2.1 Glue 작업 생성
1. Glue 콘솔에서 새 작업(Job)을 생성합니다.
2. 소스 데이터베이스로 Glue 데이터 카탈로그를 선택하고, 대상 데이터베이스로 Redshift를 선택합니다.
3. ETL 스크립트를 작성하거나 Glue가 자동 생성한 스크립트를 수정합니다.

**참고**  
자동 생성된 스크립트를 사용하더라도 데이터 변환 로직을 검토하세요.

---

### 2.2 Glue 작업 실행
1. 작업을 실행하고 로그를 확인하여 오류가 없는지 검토합니다.
2. 작업이 성공적으로 완료되면 Redshift에서 데이터가 적재되었는지 확인합니다.

**참고**  
Glue 작업 실행 시 비용이 발생하므로 테스트 환경에서 충분히 검증 후 운영 환경에 배포하세요.

---

## 3. 모니터링 및 최적화

### 3.1 CloudWatch를 통한 모니터링
- AWS CloudWatch를 사용하여 Glue 작업과 Redshift 클러스터의 성능을 모니터링합니다.
- 오류 로그를 분석하여 문제를 해결합니다.

### 3.2 성능 최적화
- Glue 작업의 병렬 처리 수준을 조정하여 처리 속도를 개선합니다.
- Redshift 클러스터의 쿼리 성능을 최적화하기 위해 적절한 분배 키와 정렬 키를 설정합니다.

**참고**  
성능 최적화는 반복적인 테스트와 튜닝 과정을 통해 이루어집니다.

---

## 결론
AWS Glue와 Redshift를 연동하면 대규모 데이터의 ETL 작업을 자동화하고 분석을 효율적으로 수행할 수 있습니다. 위의 단계를 따라 설정하고, 지속적으로 모니터링 및 최적화를 통해 안정적인 데이터 파이프라인을 구축하세요.

## 실제 구성 예시

### Glue와 Redshift 연동 구성 예시

#### 1. IAM 역할 생성 예시
- **Glue용 IAM 역할 생성**
    ```bash
    aws iam create-role --role-name GlueServiceRole \
    --assume-role-policy-document file://trust-policy.json
    aws iam attach-role-policy --role-name GlueServiceRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole
    ```
- **Redshift용 IAM 역할 생성**
    ```bash
    aws iam create-role --role-name RedshiftServiceRole \
    --assume-role-policy-document file://trust-policy.json
    aws iam attach-role-policy --role-name RedshiftServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonRedshiftFullAccess
    ```

#### 2. Redshift 클러스터 생성 예시
- **CLI를 사용한 클러스터 생성**
    ```bash
    aws redshift create-cluster \
    --cluster-identifier my-redshift-cluster \
    --node-type dc2.large \
    --master-username admin \
    --master-user-password YourPassword123 \
    --number-of-nodes 2
    ```
- **보안 그룹 설정**
    ```bash
    aws ec2 authorize-security-group-ingress \
    --group-id sg-0123456789abcdef0 \
    --protocol tcp \
    --port 5439 \
    --cidr 10.0.0.0/16
    ```

#### 3. Glue 크롤러 생성 예시
- **CLI를 사용한 크롤러 생성**
    ```bash
    aws glue create-crawler \
    --name my-crawler \
    --role GlueServiceRole \
    --database-name my-database \
    --targets "{\"JdbcTargets\":[{\"ConnectionName\":\"my-redshift-connection\",\"Path\":\"public/my_table\"}]}"
    ```

#### 4. Glue 작업 생성 및 실행 예시
- **ETL 스크립트 작성**
    ```python
    import sys
    from awsglue.transforms import *
    from awsglue.utils import getResolvedOptions
    from pyspark.context import SparkContext
    from awsglue.context import GlueContext
    from awsglue.job import Job

    args = getResolvedOptions(sys.argv, ['JOB_NAME'])
    sc = SparkContext()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)
    job.init(args['JOB_NAME'], args)

    datasource0 = glueContext.create_dynamic_frame.from_catalog(
            database="my-database", table_name="my_table")
    applymapping1 = ApplyMapping.apply(
            frame=datasource0, mappings=[("column1", "string", "column1", "string")])
    datasink2 = glueContext.write_dynamic_frame.from_jdbc_conf(
            frame=applymapping1,
            catalog_connection="my-redshift-connection",
            connection_options={"dbtable": "my_table", "database": "dev"})
    job.commit()
    ```
- **작업 실행**
    ```bash
    aws glue start-job-run --job-name my-glue-job
    ```

**참고**  
위의 예시는 AWS CLI와 Python을 사용한 구성 방법을 보여줍니다. 환경에 따라 설정 값과 스크립트를 조정하세요.
