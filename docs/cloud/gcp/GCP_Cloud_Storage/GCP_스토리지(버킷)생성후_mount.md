# GCP - Cloud Storage Mount (gcsfuse)

Ubuntu 24.04 LTS 기본 예제입니다. Rocky Linux 9 설치와 다수 서버용 Ansible `become` 예제는 [gcsfuse 연결](gcp_cloudstorage_gcsfuse연결.md)을 참고합니다. VM 서비스 계정에 대상 버킷의 최소 권한을 부여하고, 서비스 계정 키 파일을 저장하지 않습니다.

## Ubuntu 24.04 LTS 설치
```bash
sudo apt-get update
sudo apt-get install -y curl lsb-release
GCSFUSE_REPO="gcsfuse-$(lsb_release -cs)"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" \
  | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo tee /usr/share/keyrings/cloud.google.asc > /dev/null
sudo apt-get update
sudo apt-get install -y gcsfuse
```

## 테스트 마운트
```bash
mkdir -p "$HOME/gcs-test"
gcsfuse REPLACE_BUCKET "$HOME/gcs-test"
mount | grep gcsfuse
ls "$HOME/gcs-test"
```

Cloud Storage FUSE는 객체 저장소를 마운트하는 도구이며 NFS와 동일한 파일시스템 의미론을 보장하지 않습니다. 자동 마운트는 [Ansible 예제](gcp_cloudstorage_gcsfuse연결.md)를 참고합니다.

참고: [Cloud Storage FUSE 설치](https://cloud.google.com/storage/docs/cloud-storage-fuse/install), [마운트 방법](https://cloud.google.com/storage/docs/cloud-storage-fuse/mount-bucket)
