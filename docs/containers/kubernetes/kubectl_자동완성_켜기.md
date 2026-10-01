# K8S Kubectl 자동완성 켜기

## .bashrc파일에 추가
> vi ~/.bashrc 
* 마지막 3줄 주석처리 해제 

* kubectl completion bash 추가
```bash
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc 
```


## /etc/profile파일에 추가

* /etc/profile 수정
>vi /etc/profile
```bash
kubectl completion bash
```
* /etc/profile 재설정

```
source /etc/profile
```

## 영구적용
```
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
```

* /etc/bash_completion.d에 kubectl 생성확인
