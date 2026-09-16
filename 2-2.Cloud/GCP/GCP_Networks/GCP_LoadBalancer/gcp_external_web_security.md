# GCP 외부 웹 서비스 보안 구성 요약

## 1. 기본 구성

```text
사용자 (Internet / Mobile)
        │
        │ HTTPS
        ▼
External Application Load Balancer
        │
        ▼
Cloud Armor
        │
        ▼
Backend Service
        │
        ▼
VM / GKE Backend
```

## 2. 동작 원리

사용자는 실제 VM이나 GKE Backend에 직접 접속하지 않고,
Google의 **External Application Load Balancer**에 먼저 접속한다.

1. 사용자가 `https://service.example.com`으로 접속한다.
2. DNS는 External Load Balancer의 Public IP를 가리킨다.
3. Google Front End(GFE)가 외부 요청을 먼저 수신한다.
4. Cloud Armor가 요청을 검사한다.
5. 정상 요청만 Backend Service를 통해 실제 서버로 전달한다.

즉 다음과 같은 구조가 된다.

```text
Internet → Load Balancer : 허용
Internet → Backend       : 차단
Load Balancer → Backend  : 허용
```

따라서 Backend 서버 자체를 `0.0.0.0/0`으로 직접 공개할 필요가 없다.

## 3. HTTPS

HTTPS 인증서는 Load Balancer에서 처리할 수 있다.

```text
Client ── HTTPS ──> Load Balancer ── HTTP/HTTPS ──> Backend
```

Google-managed certificate를 사용하면 인증서 발급 및 갱신 관리 부담도 줄일 수 있다.

## 4. Cloud Armor 역할

Cloud Armor는 Load Balancer 앞단에서 외부 요청을 검사한다.

주요 기능:

- SQL Injection / XSS 등 WAF 룰
- 악성 IP 차단
- 국가(Geo) 기반 제한
- Rate Limiting
- 비정상 대량 요청 차단
- L7 DDoS 대응

## 5. 권장 구성

대고객용 웹 서비스의 기본 보안 구성으로는 다음 정도가 적절하다.

```text
Internet
   ↓
External HTTPS Application Load Balancer
   ↓
Cloud Armor
   ↓
Private Backend
```

핵심은 **인터넷 공개 지점을 Backend 서버가 아니라 Google Load Balancer로 제한하는 것**이다.

Cloud Armor와 HTTPS를 적용하면 네트워크/웹 계층의 기본 방어선을 구성할 수 있으며,
애플리케이션 내부에서는 별도로 인증·인가, 세션 관리, API 권한 검증 등의 보안이 필요하다.
