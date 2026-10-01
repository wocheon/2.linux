# Linux and infrastructure notes

Linux 운영, 클라우드, 컨테이너, CI/CD, 모니터링과 메시징 관련 문서 및 실행 예제를 정리한 저장소입니다.

## Directory guide

- [`docs/linux`](docs/linux): Linux 기본, 업그레이드, 보안, 네트워크 및 WSL
- [`docs/cloud`](docs/cloud): AWS 및 GCP
- [`docs/containers`](docs/containers): Docker 및 Kubernetes
- [`docs/cicd`](docs/cicd): Git, Jenkins 및 Argo CD
- [`docs/observability`](docs/observability): Prometheus, Grafana, Scouter, Ganglia 및 vnStat
- [`docs/messaging`](docs/messaging): Kafka 및 Google Cloud Pub/Sub
- [`docs/platforms`](docs/platforms): Tomcat, Redmine, Anaconda 및 데이터 플랫폼
- [`examples`](examples): 실행 가능한 CI/CD 및 Solr 예제
- [`scripts`](scripts): 운영 및 저장소 관리 스크립트
- [`archive`](archive): 이전 버전 참고 자료

## Repository policy

- 셸 스크립트와 설정 파일은 LF 줄바꿈을 사용합니다.
- 비밀번호, 토큰 및 실제 환경 파일은 커밋하지 않습니다.
- 빌드 가능한 JAR, WAR, CLASS 파일은 소스와 의존성 정의로 대체하는 것을 권장합니다.
- 실행 예제와 관련된 이미지 및 설정은 해당 예제 디렉터리에 함께 둡니다.
