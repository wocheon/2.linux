# K8S - GCP GKE(Google Kubernetes Engine)


## 신규 프로젝트 생성
- 새프로젝트를 만들고 프로젝트 id 복사

- Cloud Shell 실행
```
gcloud config set project wocheon-keduit
```

### 구글 GCP SDK
- 리눅스상에서 GCP의 콘솔을 연결 하는 도구


## 프로젝트 생성후 활성화 시켜야할 API목록
- GCP SDK 


### 활성화 할 `API` 목록
- Cloud Build API
    - 기존의 도커의 경우 이미지 생성 -> 업로드의 작업이 분리됨
    - Cloud Build 를 사용하면 이미지 생성 부터 GCP 내의 사설 저장소에 이미지를 업로드 하는 것 까지 한번에 진행할 수 있다.

- Cloud Source Repositories API 
  - github와 같이 소스코드를 저장, 관리할수있는 GCP내의 코드저장소

- Google Container Registry API
  - GCP내에 이미지를 저장 관리할수 있는 사설저장소 

- Kubernetes Engine API
  - 쿠버네티스 클러스터 연결을 위한 API


## Cloud Shell 세팅

* 본인의 프로젝트 ID값을 뽑아내기
```bash
$ gcloud config set project ciw0707-0517

$ gcloud config list project
[core]
project = graphite-byte-313706

$ gcloud config list project --format "value(core.project)"
graphite-byte-31370
```

 
* 프로젝트 ID를 변수에 할당
```bash
$(gcloud config list project --format "value(core.project)")

$ echo $PROJECT_ID
graphite-byte-313706
```

* k8s sample 파일 가져오기 ( git clone )
```
git clone https://github.com/beomtaek78/btstore
cd btstore/kube/
```

* GKE(Google Kubernetes Engine) cluster 생성 및 확인
```bash
gcloud container clusters get-credentials cluster-3 --zone asia-northeast3-b --project wocheon-keduit

# 현재 상태를 확인
kubectl get node
kubectl get pods,svc -o wide
kubectl get rs
kubectl get deploy
kubectl get namespace
```

## Zone 과 Region의 차이점
- zone (도시)
  - 실제 물리적인 DC의 위치를 의미 
- region (국가)
  - DC를 연결하여 이중화된 클러스터 환경을 구축하는 논리적 그룹


## GCP실습 - blue, green 배포

### 클러스터 생성
- 리전 
  - northeast3중 하나 
- 출시버전 
  - 기본
- 노드 이미지 
  - docker가 설치된 ubuntu
- Spec 
  - E2-medium
- 부팅디스크 크기 
  - 100G

- 노드수 3 개


### ubuntu(local vm)와 GCP GKE연동
- local pc를 인터넷 연결 가능하도록 설정
```bash
apt-update 
gcloud init snap install google-cloud-sdk --classic
```

>명령어가 없는 경우 
```bash
PATH=$PATH:/snap/bin
```
- 절차대로 진행후 링크가 뜨면 접속해서 로그인하기

<br>


- kuectl 설치 
```bash
snap install kubectl --classic
```

- GKE 클러스터 생성
```bash
gcloud container clusters get-credentials cluster-1 --zone asia-northeast3-a --project ciw0707-0517
```
- GKE 노드 목록 확인
```bash
kubectl get nodes
```

- kube-system namespace의 pod 확인 
```bash
kubectl get pod -n kube-system
```

- k8s sample 파일 가져오기 (git clone)
```bash
cd mkdir k8s ; cd k8s

git clone https://github.com/beomtaek78/btstore
cd btstore/kube/
```

- docker 설치
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
```

* Cloud build로 docker image 빌드

>kube/config/cloudbuild.yaml 
```yml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/imageview:blue', './blue']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/imageview:green', './green']
images: ['gcr.io/$PROJECT_ID/imageview:blue', 'gcr.io/$PROJECT_ID/imageview:green']
```
```
gcloud build submit --config kube/config/cloudbuild.yaml 
```

```
kubectl api-resources
kubectl get deploy
```

* configmap & secrets 배포
```
kubectl apply -f config/configmap.yaml
kubectl apply -f config/secrets.yaml
```

- config/deployment-blue, config/deployment-green.yaml 파일 수정 후 배포
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      color: blue (green은 그린으로)
    spec:
      containers:
      - image: gcr.io/ciw0707-0517/imageview:blue
   #                 [PROJECT_ID]
```

- yaml파일로 k8s에 배포
```bash
kubectl apply -f config/deployment-green.yaml --validate=false
```

- pod 상태 확인
```
kubectl get pod -o wide
```

- pod의 IP확인하기
```
kubectl describe pod webserver-blue-88df46c95-2hhdm |grep IP
```

- Centos7 이미지로 내부 접속용 pod 생성
```
kubectl run -it --image=centos:7 bash
```

- pod의 ip의 웹서버 동작 확인하기
```
curl [Pod IP Address]
```
>내부에서는 접근이 가능하지만 외부에서는 접근이 불가능


- 배포한 pod를 삭제
```
kubectl delete pod bash
#or
kubectl delete -f config/deployment-blue.yaml
```

- 로드밸런서 배포
```
kubectl apply -f config/service.yaml
```

- GCP페이지에서 클라우드 엔진 > 서비스 및 수신 목록에 생성이 되었는지 확인 
- 엔드포인트로 접속해보기
- yaml메뉴를 눌러서 blue를 green으로 변경하면 변경사항적용



## QUIZ 

1. nginx 이미지와 httpd(/var/www/html이 기본 디렉토리 아님!) 이미지를 <br> 
    본인의 사설 저장소에 업로드 하되, 아래의 내용을 포함해야 한다. <br>
    (build 를 이용할 것)
    
    - nginx 의 기본 홈 디렉토리에 index.html ( HELLO NGINX)
    - httpd 의 기본 홈 디렉토리에 index.html (HELLO HTTPD)

2. nginx 로 만든 deployment 는 label 을 web: nginx, httpd 로 만든 deployment 는 <br> label 이 web: httpd 여야 한다. 
    - 둘다.. 공통 라벨로 system: server 가 붙는다

3. service /LB 이용하여 nginx 가 기본적으로 외부에서 접속 가능해야 한다. <br>
     라벨 셀럭터를 web: httpd 로 하면 httpd 페이지가 열려야 한다.

>파일은 github확인

```bash
#docker 이미지 빌드
docker build -t gcr.io/ciw0707-0517/imageview:nginx ./nginx.d/
docker build -t gcr.io/ciw0707-0517/imageview:httpd ./httpd.d/

# Cloud 빌드
gcloud builds submit --config ./cloudbuild.yaml 

# GKE에 배포
kubectl create -f deployment-httpd.yaml
kubectl create -f deployment-nginx.yaml
kubectl create -f service.yaml
```

## 로컬에서 GCP 이미지 저장소로 이미지 push하기

- CentOS 7 이미지 pull (docker hub에서)
```
docker pull centos:7
```

- 이미지 tag 변경
```
docker tag centos:7 gcr.io/ciw0707-0517/mycentos:1.0
```

- GCP 이미지 저장소에 push
```
gcloud docker -- push gcr.io/ciw0707-0517/mycentos:1.0
```

## kubectl 자동완성 켜기 
```
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc 
```

## pod의 레플리카 조정하기

1. replicaset/Deployment의 메니페스트 파일 내에서 replicas 부분을 조정하고 해당파일을 다시 apply하기 
  - 조정된 레플리카수가 적용됨 

2. kubectl  scale --replicas=5 -f test.yaml 
