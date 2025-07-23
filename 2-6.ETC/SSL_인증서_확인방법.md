# SSL 인증서 정보 확인 방법

# 개요 
- 도메인에 할당된 SSL 인증서 정보를 점검하는 여러가지 방법

- 접근 가능 환경(브라우저 접근 가능/불가)에 따라 구분


## 웹 브라우저를 통해 도메인에 접근이 가능한 경우
- curl 명령어로 확인
- openssl보다 간단하고 직관적으로, 연결 및 기본 인증서 정보를 빠르게 확인 가능
- 실제 웹서버 응답, 인증서 적용 상태와 간략한 SSL 정보까지 한번에 확인 가능
- GCP LB의 Frontend에 대해 실행하는 경우    
    - GFE와 TLS 핸드셰이크가 이루어진 뒤 실제 HTTP(S) 요청이 백엔드 까지 전달
    - 따라서 curl로 확인하면 GCP LB 로그에 남게됨

```sh
curl -Iv https://[도메인]
```

## 웹브라우저 접근이 불가하거나, IP만 알고 있는 경우
- openssl 명령어로 직접 확인
- 도메인이 직접 열리지 않거나, IP를 통해 인증서 세부정보를 점검해야 할 때 사용
- SSL 핸드셰이크 레벨에서 인증서 전체 상세 정보까지 확인이 가능
- GCP LB의 Frontend에 대해 실행하는 경우
    - 해당 명령어는 backend까지 트래픽을 보내지않음
    - GFE와 TLS 핸드셰이크를 하는 독립된 세션을 열어서 인증서 확인만 하고 연결이 끝나기 때문에 기존 연결등에 영향이 없음

    ```sh
    # 인증서 전체 정보 확인
    echo | openssl s_client -servername [도메인] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -text    

    # 만료 일자만 확인 
    echo | openssl s_client -servername [도메인] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -enddate 

    #  CA정보/도메인/만료일자 확인
    echo | openssl s_client -servername [도메인] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -text | egrep '(After|Issuer:|Subject:)'
    ```

## 참고
- openssl 명령어에서 `-servername` 은 SNI 기반 환경에서 원하는 인증서를 받아오기 위해 가급적 지정하는 것이 안전
    - EX) 여러 도메인이 하나의 인증서를 사용하는 경우 (SAN 멀티도메인 인증서)
        ```sh
        # 도메인 별 인증서 확인 (모두 같은 인증서를 사용하므로 동일 결과 출력)
        echo | openssl s_client -servername [도메인_1] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -text    

        echo | openssl s_client -servername [도메인_2] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -text    

        echo | openssl s_client -servername [도메인_3] -connect [도메인 OR IP]:443 2>/dev/null | openssl x509 -noout -text 
        ```           

- curl은 실제 HTTP 동작 관점의 빠른 점검에, openssl은 인증서 구조/보안/체인 상세 분석에 각각 유리하므로 구분하여 사용