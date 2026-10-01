# k8s dashboard 설치

## k8s dashboard yaml 다운로드
```
wget  https://kubetm.github.io/documents/appendix/kubetm-dashboard-v2.0.0.yaml
```

## 파일명 변경
``
mv kubetm-dashboard-v2.0.0.yaml k8s-dashboard-v2.0.0.yaml
``

## yaml 파일 수정
>vi k8s-dashboard-v2.0.0.yaml
```yaml
# 다음 사항을 변경 후 진행

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001 # 추가
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort # 추가

args:
            - --enable-skip-login # 추가
            - --auto-generate-certificates
            - --enable-skip-login # 추가
            - --namespace=kubernetes-dashboard
            - --token-ttl=0 # 추가



apiVersion: rbac.authorization.k8s.io/v1beta1 
# => apiVersion: rbac.authorization.k8s.io/v1 로 변경

```

## service_account 작성
>vi service_account.yml

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
```

## cluster_role_binding 작성
>vi cluster_role_binding.yml
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin
    namespace: kube-system
```

## kubectl apply 순서
1. k8s-dashboard-v2.0.0.yaml
2. service_account.yml
3. cluster_role_binding.yml

## 서비스 동작확인 
- 노드 포트를 30001로 고정하였으므로 외부주소:30001로 접속

## K8s Dashboard 인증 
- 인증방식 : 토큰

- 토큰생성 
```
kubectl -n kube-system create token admin 
```

* 위 명령의 결과값을 넣고 로그인하여 화면이 정상적으로 출력되는지 확인
`(워크로드 등의 화면중에서 404 에러 발생시 재설치 필요)`
