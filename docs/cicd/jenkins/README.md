# Jenkins 문서

설치부터 Pipeline 실습까지 순서대로 읽을 수 있도록 주제별로 정리했습니다.

1. [Jenkins 설치와 Agent](Jenkins_CICD_구성/Jenkins_설치와_Agent.md) — Jenkins 설치, 실습용 GitLab, SSH Agent 연결
2. [Pipeline과 Webhook](Jenkins_CICD_구성/Jenkins_Pipeline과_Webhook.md) — Pipeline 생성, GitHub/GitLab Webhook, 스크립트 실습
3. [배포 예제](Jenkins_CICD_구성/Jenkins_배포_예제.md) — Maven·Tomcat, GitLab Registry, 단일 VM Docker Compose v2
4. [Shared Library 기본](Jenkins_Shared_Library/Jenkins_Shared_Library_기본.md) — 등록, `vars/`, `resources/`
5. [Shared Library 클래스](Jenkins_Shared_Library/Jenkins_Shared_Library_클래스.md) — `src/` 클래스와 활용 예제

실행용 Groovy 파일은 `Jenkins_pipeline_scripts/`, 테스트 WAR 파일은 `Sample_warfile/`에 그대로 두었습니다.
