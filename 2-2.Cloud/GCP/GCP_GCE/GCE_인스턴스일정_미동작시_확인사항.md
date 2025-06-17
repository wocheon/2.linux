# GCP Compute Engine 인스턴스일정 미작동시 확인 사항 
- 인스턴스 일정을 적용하였으나, 설정 시간이 되어도 VM이 시작 or 종료 되지않는 경우 다음 내용을 확인

 ## 보안 VM - 무결성 모니터링
 - Compute Engine 설정 중 보안 VM 항목을 확인
  - 보안 VM - vTPM, 무결성 모니터링 활성화 여부
  - 해당 항목이 활성화 된 경우 인스턴스 일정을 통해 VM 시작/종료시  무결성 모니터링이 진행됨
  - 무결성 모니터링에 실패하면 인스턴스 일정에 의해 시작/종료 동작이 중지될 수 있음
  - 해당 옵션을 해제하려면 인스턴스 중지 필요

### 무결성 모니터링 관련 로그 확인 방법 
- 로그 탐색기에서 다음 항목을 검색
  - type.googleapis.com/cloud_integrity.IntegrityEvent
  - 로그 중 대상 VM에 대한 로그가 존재하는지 확인
 
### 무결성 모니터링 정책 업데이트
- 초기 무결성 정책 기준은 인스턴스 생성 시 암시적으로 신뢰할 수 있는 부팅 이미지에서 파생됨.
    - 인스턴스 구성에서 커널 업데이트 또는 커널 드라이버 설치와 같은 계획된 부팅 관련 변경사항이 발생한 후에는 이로 인해 무결성 확인에 실패하게 되므로 기준을 업데이트 필요

- 해당 기준을 현재 인스턴스 구성을 사용하여 업데이트를 진행 
  - 기준 업데이트시, VM 인스턴스는 실행중이어야 함
  - setShieldedInstanceIntegrityPolicy 권한 필요

```bash
gcloud compute instances update INSTANCE_NAME --zone=ZONE --shielded-learn-integrity-policy
```
