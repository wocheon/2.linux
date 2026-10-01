# GCP Persistent Disk, Hyperdisk, Local SSD 비교

|유형|연결 방식|대표 용도|데이터 보존|
|---|---|---|---|
|Persistent Disk (`pd-standard`, `pd-balanced`, `pd-ssd`, `pd-extreme`)|네트워크 블록 디스크|부팅·일반 데이터·DB|VM 삭제 시 디스크 자동 삭제 설정에 따라 달라짐|
|Hyperdisk (Balanced, Extreme, Throughput, ML 등)|네트워크 블록 디스크|성능을 별도로 프로비저닝하는 워크로드|VM과 분리해 유지 가능; 자동 삭제 설정 확인|
|Local SSD|VM 호스트에 직접 연결|캐시·스크래치·임시 고속 I/O|게스트 OS 재부팅 시 보존, VM 중지·선점·삭제 시 기본적으로 소실|

## 선택 시 주의

- Persistent Disk와 Hyperdisk는 모두 머신 계열·리전·디스크 유형별 지원 및 성능 한도가 다릅니다. 스냅샷·공유 모드도 선택한 유형에서 확인합니다.
- Local SSD는 **게스트 OS 재부팅만으로 데이터가 사라지는 것은 아닙니다**. VM 정지/일시중지 시 데이터 보존 옵션은 지원 조건과 Preview 상태를 확인해야 합니다.
- Local SSD 용량·디스크 개수는 머신 유형에 따라 달라지므로 `375 GB × 24개`로 고정하지 않습니다.
- 영구 데이터는 Persistent Disk/Hyperdisk 또는 Cloud Storage에 저장·백업합니다.

참고: [Persistent Disk](https://cloud.google.com/compute/docs/disks/persistent-disks), [Hyperdisk](https://cloud.google.com/compute/docs/disks/hyperdisks), [Local SSD](https://cloud.google.com/compute/docs/disks/local-ssd)
