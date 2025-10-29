- 로컬 서버에서 kubectl 로 gke를 컨트롤 하는 방법

## gcp - kubectl 연동

1. vm의 Cloud API 액세스 범위를 모든 Cloud API에 대한 전체 액세스 허용 으로 변경
    - 중지 후 변경하여 재부팅 필요

2. google-cloud-sdk 최신버전 설치
- https://cloud.google.com/sdk/docs/install?hl=ko#linux
```
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-461.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-461.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
```

3. kubectl 설치
- https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl?hl=ko#run_against_a_specific_cluster
```
gcloud components install kubectl
kubectl version --client
```
4. gke 인증 플러그인 설치
```
gcloud components install gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
```

4. kubectl 구성 업데이트 및 클러스터의 kubeconfig 컨텍스트를 생성
```
 gcloud container clusters list
NAME                LOCATION           MASTER_VERSION      MASTER_IP      MACHINE_TYPE  NODE_VERSION        NUM_NODES  STATUS
wocheon07-gke-test  asia-northeast3-a  1.29.0-gke.1381000  34.64.250.154  g1-small      1.29.0-gke.1381000             RUNNING


gcloud container clusters get-credentials wocheon07-gke-test --region=asia-northeast3-a
```


5. docker 설치 
```
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce.x86_64
docker --version
systemctl enable docker --now
```

6. ngix 이미지 pull 하여 pod 생성하기
```
docker image pull nginx 
```

- 기본 pod 생성
```
kubectl run my-app --image nginx --port=80
```

- deployment 생성
```
kubectl create deployment my-dep --image=nginx --port=80
# scaling 진행
kubectl scale deploy my-dep --replicas=2
# 노드포트 추가
kubectl expose deployment my-dep --type=NodePort
```
- 확인

```bash
 kubectl describe svc my-dep
Name:                     my-dep
Namespace:                default
Labels:                   app=my-dep
Annotations:              cloud.google.com/neg: {"ingress":true}
Selector:                 app=my-dep
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.16.14.171
IPs:                      10.16.14.171
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  31303/TCP
Endpoints:                10.12.0.15:80,10.12.0.16:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>


[root@gcp-ansible-test ~]$ curl 10.12.0.15:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

- gcp 방화벽 오픈후 확인
http://34.22.95.3:31303/


## kubectl 서비스계정관련 오류 

- gke-gcloud-auth-plugin 은 캐시를 저장하여  사용하므로 잘못된 정보가 캐시되어있다면 다음과 같이 권한 오류가 발생할 수 있음

- service 삭제 
```
[root@gcp-ansible-test ~]# kubectl delete service my-dep
Error from server (Forbidden): services "my-dep" is forbidden: User "daskete07@gmail.com" cannot delete resource "services" in API group "" in the namespace "default": requires one of ["container.services.delete"] permission(s)
```

- gcloud 계정 확인
    - default로 변경 확인
    - 서비스 어카운트가 활성화 되지않았다면 gcloud config configurations activate default 로 변경
    - 변경해도 캐시가 남아있으므로 kubectl로 변경이 불가능
```    
 gcloud config configurations list
NAME     IS_ACTIVE  ACCOUNT                                             PROJECT    COMPUTE_DEFAULT_ZONE  COMPUTE_DEFAULT_REGION
default  True       487401709675-compute@developer.gserviceaccount.com  test-project  asia-northeast3-c     asia-northeast3
viewer   False      daskete07@gmail.com                                 test-project  asia-northeast3-c     asia-northeast3 #viewr 권한 계정
```

- gke_gcloud_auth_plugin_cache 확인 후 삭제 
```
ls -l .kube/gke_gcloud_auth_plugin_cache
-rw------- 1 root root 393 Feb 27 21:32 .kube/gke_gcloud_auth_plugin_cache

 rm .kube/gke_gcloud_auth_plugin_cache
```
- 정상적으로 삭제됨을 확인
```
kubectl delete service my-dep
service "my-dep" deleted
```

## 노드풀 사이즈 조절
- 노드풀 확인
```
gcloud container clusters describe wocheon07-gke-test --region=asia-northeast3-a
```

- 노드풀 사이즈 조절
    - 옵션 순서대로 안쓰면 제대로 적용이 안되므로 주의
```
gcloud container clusters resize wocheon07-gke-test --region=asia-northeast3-a --num-nodes 0 --node-pool=node-pool-1

Pool [node-pool-1] for [wocheon07-gke-test] will be resized to 0 node(s) in each zone it spans.

Do you want to continue (Y/n)?  Y

Resizing wocheon07-gke-test...⠼
```
