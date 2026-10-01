# Kubernetes Web UI 설치

> **Legacy 안내:** 기존 Kubernetes Dashboard는 유지보수가 종료되었습니다. 신규 테스트 환경에서는 Kubernetes SIG의 Headlamp 사용을 권장합니다.

## Headlamp Helm 저장소 추가

```bash
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
```

## Headlamp 설치

```bash
helm install headlamp headlamp/headlamp \
  --namespace headlamp \
  --create-namespace
```

## 로컬 접속

```bash
kubectl -n headlamp port-forward service/headlamp 8080:80
```

브라우저에서 `http://localhost:8080`으로 접속합니다.

## 인증 주의사항

- `--enable-skip-login` 옵션은 사용하지 않습니다.
- 예제 편의를 위한 `cluster-admin` 바인딩은 생성하지 않습니다.
- 조회·작업에 필요한 최소 권한의 ServiceAccount 토큰을 사용합니다.

```bash
kubectl -n <namespace> create token <service-account>
```
