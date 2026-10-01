# GCP - 가비아 도메인 설정

## 도메인 구매
- 가비아에서 원하는 도메인 검색후 구매하기
    - wocheon07.store

## GCP Cloud DNS 영역 생성
- GCP Cloud DNS에 구매한 도메인명으로 영역 생성

- 네트워크서비스 > Cloud DNS 
    - 영역만들기 
        - 영역 이름 : DNS 영역 구분자
        - DNS 이름 : 도메인명 입력

##  Cloud DNS NS 레코드를 가비아에 등록

- 영역 생성후 NS 레코드 세트를 확인 
    - 해당 네임서버를 가비아 도메인에 등록하여 도메인 관리를 가비아 > GCP로 변경

- My가비아 > 도메인 관리 <br>
`홈 > 전체도메인 > 도메인 상세 페이지`
- 네임서버를 생성한 GCP DNS영역의 NS 레코드 (네임서버)로 변경 <br>
`(변경 후 적용에 시간 소요 - 약 1일?)`

- nslookup으로 네임서버 변경확인 가능
```bash
$ nslookup -type=NS wocheon07.store
서버:    LCNPXSADC01.CNS.LGCNS.COM
Address:  165.244.232.63

권한 없는 응답:
wocheon07.store nameserver = ns-cloud-d1.googledomains.com
wocheon07.store nameserver = ns-cloud-d3.googledomains.com
wocheon07.store nameserver = ns-cloud-d4.googledomains.com
wocheon07.store nameserver = ns-cloud-d2.googledomains.com

ns-cloud-d1.googledomains.com   internet address = 216.239.32.109
ns-cloud-d1.googledomains.com   AAAA IPv6 address = 2001:4860:4802:32::6d
ns-cloud-d3.googledomains.com   internet address = 216.239.36.109
ns-cloud-d3.googledomains.com   AAAA IPv6 address = 2001:4860:4802:36::6d
ns-cloud-d4.googledomains.com   internet address = 216.239.38.109
ns-cloud-d4.googledomains.com   AAAA IPv6 address = 2001:4860:4802:38::6d
ns-cloud-d2.googledomains.com   internet address = 216.239.34.109
ns-cloud-d2.googledomains.com   AAAA IPv6 address = 2001:4860:4802:34::6d
```

## GCP DNS영역에 레코드 추가 
- DNS영역에서 신규 레코드를 추가 
    - 유형 : A
    - 데이터 : 연결할 VM 외부주소

## 도메인 접속확인 
- 80 포트로 접속 가능하도록 web설정 후 
 브라우저 혹은 curl localhost로 확인