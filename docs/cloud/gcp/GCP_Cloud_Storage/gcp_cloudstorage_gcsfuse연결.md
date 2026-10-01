# GCP Cloud Storage gcsfuse 연결

기본 OS: Ubuntu 24.04 LTS. GCSFuse는 객체 저장소를 파일시스템처럼 마운트하는 도구로, 영구 디스크나 NFS와 동일한 POSIX 동작을 보장하지 않습니다. 서버에 연결된 서비스 계정에 대상 버킷의 최소 권한을 부여합니다. 서비스 계정 키 파일 복사나 `expect` 로그인은 사용하지 않습니다.

## Ansible `become`으로 설치·마운트
제어 노드에 `ansible.posix` 컬렉션이 필요합니다. 아래 플레이북은 버킷 이름과 마운트 계정만 바꾸는 테스트용 예제입니다.

```yaml
- hosts: gcsfuse_vms
  become: true
  vars:
    bucket_name: REPLACE_BUCKET
    mount_uid: 1000  # 대상 VM 사용자 id -u 결과로 교체
    mount_gid: 1000  # 대상 VM 사용자 id -g 결과로 교체
    mount_path: /mnt/gcs
  tasks:
    - name: gcsfuse 필수 패키지 설치
      ansible.builtin.apt:
        name: [curl, gnupg, fuse3]
        update_cache: true
    - name: Google 패키지 서명 키 다운로드
      ansible.builtin.get_url:
        url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
        dest: /usr/share/keyrings/cloud.google.asc
        mode: '0644'
    - name: gcsfuse 저장소 등록
      ansible.builtin.apt_repository:
        repo: 'deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt gcsfuse-noble main'
        filename: gcsfuse
    - name: gcsfuse 설치
      ansible.builtin.apt:
        name: gcsfuse
        update_cache: true
    - name: 마운트 디렉터리 생성
      ansible.builtin.file:
        path: '{{ mount_path }}'
        state: directory
        mode: '0755'
    - name: 버킷 마운트 및 fstab 등록
      ansible.posix.mount:
        path: '{{ mount_path }}'
        src: '{{ bucket_name }}'
        fstype: gcsfuse
        opts: '_netdev,implicit_dirs,uid={{ mount_uid }},gid={{ mount_gid }}'
        state: mounted
```

> `mount_uid`/`mount_gid`는 대상 VM의 `id -u`/`id -g` 출력으로 교체하세요.

Rocky Linux 9는 [공식 RPM 설치 절차](https://cloud.google.com/storage/docs/cloud-storage-fuse/install)를 사용하고, 마운트 작업은 동일합니다. `gcsfuse -v`, `mount | grep gcsfuse`, `ls /mnt/gcs`로 확인합니다. 데이터 이전은 `gcloud storage rsync` 등 객체 업로드 도구로 검증 후 진행합니다.

참고: [Cloud Storage FUSE 설치](https://cloud.google.com/storage/docs/cloud-storage-fuse/install), [버킷 마운트](https://cloud.google.com/storage/docs/cloud-storage-fuse/mount-bucket)
