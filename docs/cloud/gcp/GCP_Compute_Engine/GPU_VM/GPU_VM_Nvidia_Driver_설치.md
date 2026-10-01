# GPU VM NVIDIA 드라이버 설치

기본 환경은 Ubuntu 24.04 LTS, RHEL 계열 대안은 Rocky Linux 9입니다. GPU가 연결된 Compute Engine VM에서 테스트합니다. GPU 종류·머신 계열·리전 호환성은 [공식 GPU 목록](https://cloud.google.com/compute/docs/gpus)을 먼저 확인합니다.

## 설치 스크립트 사용
Secure Boot 설정 및 드라이버 버전 고정이 필요한 경우에는 [Google 공식 가이드](https://cloud.google.com/compute/docs/gpus/install-drivers-gpu)의 해당 절을 사용합니다. 일반 테스트는 다음 절차를 따릅니다.

```bash
python3 --version
curl -fSsL https://storage.googleapis.com/compute-gpu-installation-us/installer/latest/cuda_installer.pyz -o cuda_installer.pyz
sudo python3 cuda_installer.pyz install_driver
```

스크립트가 VM을 재부팅하면 다시 접속하여 같은 설치 명령을 실행해 완료합니다. 설치 후:

```bash
nvidia-smi
```

설치 모드(`repo`/`binary`)에 따라 커널 업데이트 처리 방식이 다릅니다. 운영 환경에서는 Google 문서에서 드라이버 분기와 Secure Boot 호환성을 확인합니다.

참고: [Compute Engine GPU 드라이버 설치](https://cloud.google.com/compute/docs/gpus/install-drivers-gpu)
