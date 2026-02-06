
# 사설 도메인 - 외부 CA 인증서 발급 관련 사항

## 사설 도메인이란?

* 공용 DNS에 등록되지 않고, 사내 내부 DNS 서버에서만 해석 가능한 도메인.
* 외부 인터넷에서는 도메인 조회 자체가 불가능하며, 접근도 불가.
* 예) `<서비스명>.<사명>.com` 형태지만 내부 DNS 전용으로만 관리됨.


### 사설 도메인 여부 확인 방법 
```sh
# 1. 공용 DNS 서버에서 조회 시도
# Non-existent domain 또는 NXDOMAIN -> 공용 DNS에 등록되지 않은 도메인 (사설 도메인 가능성 높음)
nslookup <도메인명> 8.8.8.8

# 2. 내부 DNS 서버로 조회 시도
# 정상 응답 시 내부 DNS에 등록된 도메인이므로 사설도메인 가능성 높음
nslookup <도메인명> <내부 DNS 서버 IP>

# 3. 도메인 네임서버 정보 확인
# 네임서버가 사내 네임서버 IP나 사설 IP이면 사설 도메인
dig NS <도메인명>
```

## 사설 도메인에서 외부 CA 인증서 발급의 한계


- 사설 도메인의 경우 CNAME 인증 등 외부 CA와의 연결을 통해 확인하는 방식으로는 인증 불가
    - 외부 CA는 내부 DNS에 연결할 수 없으므로, 사설도메인을 찾을 수 없음 

- `이메일 확인등의 방법을 통해서 인증서 발급은 가능`

## 사설 도메인에서 인증서 사용 방안

### 내부 CA(사내 인증서) 운영

* 내부망 전용 인증서를 직접 발급하여 사용.
* 사내 CA 루트 인증서를 GCP VM, GKE Pod 등 클라이언트에 신뢰하도록 설치해야 함.
* 신뢰 설정 미비 시 TLS 인증서 오류 발생.

### Split Horizon DNS 및 LB 구성

* 내부용 LB에 사내 인증서 할당, 내부 DNS에서 사설 도메인 해석.
* 외부용 LB 별도 생성, 외부 DNS에 공인 도메인 혹은 별도 도메인 등록.
* 외부 LB에는 외부 CA 인증서 할당하여 외부 사용자 접근 허용.

### 이메일 인증 등 별도 인증 방법으로 발급 
- 굳이 외부 CA 인증서가 필요하다면 CNAME 인증 등의 방식 외 이메일 인증 등으로 인증서를 발급 받아 사용할 수 있음 



## 참고 - GCP VM에 사내 CA 루트 인증서 설치
- GCP VM 간 사내 인증서가 할당된 도메인을 사용하여 통신 하는 경우, 사내 CA루트 인증서를 신뢰 하지 않기 때문에 TLS 인증서 오류가 발생

| 상황                          | 결과               |
| --------------------------- | ---------------- |
| 사내 인증서 + 클라이언트에 CA 루트 미설치   | TLS 인증서 신뢰 오류 발생 |
| 사내 인증서 + 클라이언트에 CA 루트 신뢰 등록 | 정상 TLS 통신 가능     |


### GCP VM에 사내 CA 루트 인증서 설치 방법 (Ubuntu/Debian 기준)


1. **사내 루트 인증서 파일 준비**

   * 예: `company-root-ca.crt`

2. **인증서 복사**

   ```bash
   sudo cp /tmp/company-root-ca.crt /usr/local/share/ca-certificates/company-root-ca.crt
   ```

3. **시스템 인증서 업데이트**

   ```bash
   sudo update-ca-certificates
   ```

4. **적용 확인**

   * `/etc/ssl/certs/` 아래에 `.pem` 링크가 생성됨
   * TLS 접속 시 인증서 오류가 없어지는지 확인

### GCP VM에 사내 CA 루트 인증서 설치 방법 (RHEL/CentOS 계열)

1. **인증서 복사**

   ```bash
   sudo cp /tmp/company-root-ca.crt /etc/pki/ca-trust/source/anchors/company-root-ca.crt
   ```

2. **시스템 CA 목록 업데이트**

   ```bash
   sudo update-ca-trust extract
   ```

3. **적용 확인**


