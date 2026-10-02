# Jenkins Pipeline과 Webhook

Pipeline 생성, GitHub/GitLab Webhook, 짧은 스크립트 실습을 순서대로 모았습니다.

---

## Pipeline 프로젝트 생성

### Pipeline 생성
- NEW ITEM > Pipeline 로 추가

### Pipeline scripts

#### 현재 작업 위치 및 PIPELINE의 동작 확인
```ruby
pipeline {
  agent any
  stages {
      stage('execute ls command') {
        steps {
          echo 'execute ls command'
          sh 'ls -la'
        }
      }
      stage('Where do ls command execute?') {
        steps {
          echo 'Here is default.'
          sh 'ls -la'
          echo 'you can define where to execute command.'
          echo 'For example, I want to view root directory'
          sh 'ls -la /'
        }
      }
      stage('Is there any other way?') {
        steps {
          echo 'Maybe sh is independent'
          sh 'cd /'
          sh 'pwd'
          sh 'ls -la'
          echo 'If you want to execute multiple commands in one sh.'
          sh '''cd /
          pwd
          ls -la'''
        }
      }
    }
  }
```


#### 각 Node별로 stage 진행
```ruby
pipeline {
    agent{
        label 'master'
    }
  stages {
      stage('Master_Check') {
        steps {
          echo 'execute ls command'
          sh 'pwd; ls -la'
          sh 'hostname'
        }
      }
       stage('Slave_Check') {
       agent {
	    label 'master'
        }
        steps {
          echo 'execute ls command'
          sh 'pwd; ls -la'
          sh 'hostname'
        }
      }
    }
 }
```


#### Pipeline상에서 ssh, scp 사용
```groovy
pipeline {
	agent{
        label 'master'
    }
	stages {
      stage('SSH_Check') {
        steps {
          sh 'pwd; ls -la'
          sh 'ssh -o StrictHostKeyChecking=accept-new deploy@vm-2 pwd'
          sh 'ssh -o StrictHostKeyChecking=accept-new deploy@vm-2 ls -la'
        }
      }
      stage('SCP copy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'vm-001-private-key', keyFileVariable: 'MY_SSH_KEY')]) {
                    sh '''
					echo test > result.txt
                    scp -i $MY_SSH_KEY result.txt deploy@vm-2:/home/deploy
                    '''
                }
            }
        }
    }
 }

```

* Host key verification failed. 오류 발생 시
```bash
#[Master]
cp /root/.ssh/id_rsa* .
chown jenkins.jenkins ./*
```

* ssh 명령어에 옵션 추가
```bash
ssh -o StrictHostKeyChecking=accept-new deploy@vm-2 pwd
```

* scp에서 key를 지정해도 오류발생하는 경우
  - host ip를 직접 지정
  >ex)
  ```bash
  scp -i $MY_SSH_KEY result.txt deploy@vm-2:/home/deploy
  ==> scp -i $MY_SSH_KEY result.txt deploy@192.168.1.100:/home/deploy
  ```


---

## Git Webhook 구성

### Git Webhook
* 사용자가 git push 실행
	- webhook(일종의 트리거역할)을 통해 자동으로 빌드 진행
	`slave의 workspace/프로젝트명 디렉토리에 clone됨.`

### github token 발급
* github 계정아이콘 클릭 후
	- settings > Developer Settings >Personal access tokens (classic)
		-  generate new token > generate new token(classic)

- 체크 항목 : repo, admin:org, admin:repo_hook

- generate 후 표기되는 token을 복사 <br>
$\textcolor{orange}{\textsf{ * 한번 생성하면 이후에 다시 나오지않으므로 복사해둘것 }}$


### github webhook 설정
- 사용할 repository를 선택 후, settings > webhooks > add webhook 으로 이동
	- Payload URL : http://[jenkins주소]/github-webhook/
	- Content type : application/json

#### github 토큰을 jenkins credential 으로 등록
- Jenkins 관리 > Credentials > System <br>
	- \> Global credentials (unrestricted) > Add credentials

	* Credential option
		- Scope : global
		- username : github id 입력
		- password : github token 입력
		- ID : credential 명칭 입력
<br>

### webhook 동작 테스트 진행
* New item > pipiline

* option
	- General : GitHub project 체크, Project url에 repository 주소 복사
	- Build Triggers : GitHub hook trigger for GITScm polling

	- script
```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check Path') {
			steps {
				sh '''hostname
					  hostname -i
					  pwd'''
			}
		}
		stage('Checkout') {
			steps {
				git branch: 'master',
					credentialsId: 'github_token',
					url: 'https://github.com/wocheon/docker_images.git'
			}
		}
		stage('Deploy') {
			steps {
				sh '''cp -f index.html /var/www/html/index.html
					curl localhost
				   '''
			}
		}
	}
}
```


- 생성 완료 후 수동으로 빌드 시 문제없는지 확인.

- 웹상에서 commit 생성 후 빌드가 진행되는지 확인.
- local에서 push 후에도 정상적으로 빌드 되는지 확인.



### GIT LAB에서 webhook 구성.

### Jenkins Plugin 및 Credential 등록
* 작업 순서
	1. Jenkins Plugins에서 GItlab 검색하여 전체 설치 진행.
	2. gitlab에서 Access token 발급 후, Jenkins에 credential로 등록

#### Gitlab 엑세스 토큰 생성
* **Gitlab**
 - 프로젝트 선택 > setting> 엑세스 토큰 > role : developer , api 체크 후 생성

#### Jenkins credential 생성
* **Jenkins**
- global credentials > add credential
	- Kind : GitLab API token
	- API token : [gitlab에서 생성한 프로젝트 토큰값 입력]
	- ID : [gitlab id]

#### Jenkins- Gitlab 연결
* **Jenkins**
	- jenkins관리 >	system > Gitlab
		- Connection name : [연결 명칭 입력]
		- GitLab host URL : [gitlab주소 ex) https://testdomainname.info ]
		- Credentials : [이전 단계에서 생성한 credential 선택]

	- 테스트 후 Success 뜨면 저장


#### trigger를 Webhook으로 설정하여 Pipeline 프로젝트 생성
* **Jenkins**
	- new item > pipeline
	- Build Triggers 부분에 표시된 webhook URL 복사
	>예시
	```
	Build when a change is pushed to GitLab.
	GitLab webhook URL: http://34.64.241.60:8080/project/gitlab-test
	```
	- 아래로 내려가서 고급 > Secret token Generate 후 복사

* **Gitlab**
- 프로젝트설정 > 웹훅 > add new webhook
	- URL : [Jenkins trigger 부분에 표시된 URL 입력 ]
	- token : [생성한 Secret 토큰 입력]
	- trigger : [용도에 맞게 선택] ( 일단 푸쉬이벤트만 선택함..)
	- SSL verification : 체크

- 웹훅 추가 후 > 테스트 > 푸쉬이벤트로 테스트 진횅.
`Hook executed successfully: HTTP 200 메세지가 나오면 성공`

- 파이프라인 스크립트 입력후 저장.
`수동 빌드 및 로컬 push시 자동 빌드 모두 확인완료`

### docker node 연동 및 테스트

#### slave 노드에서 image 확인 및 run test
```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check image') {
			steps {
				sh '''hostname
					  hostname -i
					  docker image ls  | grep nginx
					  docker container ls -a'''
			}
		}
		stage('Container Run') {
			steps {
				sh '''docker container run -d -p 80:80 --name nginx_test nginx
				      docker container ls -l
					  curl localhost'''
			}
		}
		stage('Container Remove') {
			steps {
				sh '''docker container rm nginx_test -f
					  docker container ls -l'''
			}
		}
	}
}
```
<br>


#### Gitlab webhook 트리거 사용
* gilab에 변경사항이 push 되면 webhook을 통해 Jenkins PIPELINE을 가동
	- 기존 동작중인 컨테이너를 삭제하고,<br> 새 index.html 파일을 docker image에 포함해서 <br> web_test이미지를 재생성하여 컨테이너 run

```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check Path') {
			steps {
				sh '''hostname
					  hostname -i
					  pwd
					  docker image ls
					  docker rm web_test -f
					  '''
			}
		}
		stage('Checkout') {
			steps {
				git branch: 'master',
					credentialsId: 'gitlab-token',
					url: 'https://testdomainname.info/wocheon/docker_images.git'
			}
		}
		stage('Deploy') {
			steps {
				sh '''docker build -t web_test .
					docker run -d -p 80:80 --name web_test web_test
					docker container ls
					curl localhost
				   '''
			}
		}
	}
}
```
<br>

#### pipeline IF문 사용 및 명령어 결과값 변수 사용
```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check Path') {
			steps {
				sh '''hostname
					  hostname -i
					  pwd
					  docker image ls
					  '''
				script{
				    chck = sh(script: 'docker container ls --all | grep web_test | wc -l', returnStdout: true).trim()
				    if(chck>=1){
				        sh "docker rm web_test -f"
				    }
				}
			}
		}
		stage('Checkout') {
			steps {
				git branch: 'master',
					credentialsId: 'gitlab-token',
					url: 'https://testdomainname.info/wocheon/docker_images.git'
			}
		}
		stage('Deploy') {
			steps {
				sh '''docker build -t web_test .
					docker run -d -p 80:80 --name web_test web_test
					docker container ls
					curl localhost
				   '''
			}
		}
	}
}
```



#### 최종 구성도
```
로컬에서 docker image 등을 수정 후 git push
> git webhook
> jenkins pipeline 진행 ( 빌드 => 테스트 => 배포)
> slave node에 docker container 생성 > 확인
```


---

## Pipeline 스크립트 모음

### 0.pipeline_test
```python
pipeline {
  agent any
  stages {
      stage('execute ls command') {
        steps {
          echo 'execute ls command'
          sh 'ls -la'
        }
      }
      stage('Where do ls command execute?') {
        steps {
          echo 'Here is default.'
          sh 'ls -la'
          echo 'you can define where to execute command.'
          echo 'For example, I want to view root directory'
          sh 'ls -la /'
        }
      }
      stage('Is there any other way?') {
        steps {
          echo 'Maybe sh is independent'
          sh 'cd /'
          sh 'pwd'
          sh 'ls -la'
          echo 'If you want to execute multiple commands in one sh.'
          sh '''cd /
          pwd
          ls -la'''
        }
      }
    }
  }
```



### 1.pipeline_syntax_if_test
```python
pipeline{
    agent{
		label 'slave'
	}
    stages{
        stage('var check'){
            steps{
                script{
                    var1 = sh(script: 'ls -l | wc -l', returnStdout: true).trim()
                }

                echo '${var1}'
                sh """pwd
				   ls -l
				   echo ${var1}"""
            }
        }
        stage('if check'){
            steps{
				echo "aa"
                script{
                    var1 = sh(script: 'ls -l | wc -l', returnStdout: true).trim()
					sh "echo ${var1}"
                    if(var1>=1){
                        sh "echo \'ok(${var1})\'"
                    }
                    else{
                         sh "echo \'no(${var1})\'"
                    }
                }

            }
        }
    }

}
```

### 2.Dockerfile_Webhook_Deploy
```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check Path') {
			steps {
				sh '''hostname
					  hostname -i
					  pwd
					  docker image ls
					  '''
				script{
				    chck = sh(script: 'docker container ls --all | grep web_test | wc -l', returnStdout: true).trim()
				    if(chck>=1){
				        sh "docker rm web_test -f"
				    }
				}
			}
		}
		stage('Checkout') {
			steps {
				git branch: 'master',
					credentialsId: 'gitlab-token',
					url: 'https://testdomainname.info/wocheon/docker_images.git'
			}
		}
		stage('Build') {
			steps {
	               sh '''docker build -t web_test .
	                    docker image ls | grep web_test'''
			}
		}
		stage('Deploy') {
			steps {
				sh '''docker build -t web_test .
					docker run -d -p 80:80 --name web_test web_test
					docker container ls
					curl localhost
				   '''
			}
		}
	}
}
```


### 3.mvn_build_test
#### Maven Project
* General
    - GitLab Connection : gitlab_connect (System)
* 소스 코드 관리
    - Repository URL : https://testdomainname.info/wocheon/mvn_project.git
    - Credentials : - none -
    - Branches to build
        - Branch Specifier (blank for 'any') : */main

* Build Steps
    - Maven Version : maven_home (ToolS)
    - Goals : clean package

#### System & Credentials
>System

* `gitlab_connect`
    -  GitLab
        - GitLab connections
            - Connection name : gitlab_connect
            - GitLab host URL : https://testdomainname.info
            - Credentials : GitLab API token (gitlab_api_token_wocheon07) (Credential)

> Tools
* `maven_home`
    - Maven
        - Name : maven_home
        - MAVEN_HOME : /usr/share/maven
        - Install automatically : 체크 해제

>Credential
* `GitLab API token (gitlab_api_token_wocheon07)`
    - Scpoe : Global
    - ID : wocheon07
    - API token : Gitlab API Acess Token
    - Description : gitlab_api_token_wocheon07

### 4. Maven_Pipeline_Deploy

```python
pipeline {
	agent {
		label 'slave'
	}
	stages {
		stage('Check Current Path') {
			steps {
				sh '''hostname
					  hostname -i
					  pwd
					  ls -lrth
					  '''
			}
		}
		stage('Gitlab Checkout') {
			steps {
				git branch: 'main',
					credentialsId: 'mvn_project',
					url: 'https://testdomainname.info/wocheon/mvn_project.git'
				sh 'ls -lrth'
			}
		}
		stage('Build_Warfile') {
			steps {
				sh '''
					mvn clean package
					cd target
					mv test.war ROOT.war
					ls -lrth
					 '''
			}
		}
		stage('Build_Dockerfile') {
			steps {
				sh '''
					pwd
					ls -lrth
					docker build -t web-app .
					docker image ls
				   '''
			}
		}
		stage('Deploy') {
			steps {
				sh '''
				    docker rm web-app -f
					docker run -d -it -p 8090:8080 --name web-app web-app
					docker container ls -a
					sleep 3
					curl localhost:8090
				   '''
			}
		}
	}
}
```

### 6. scp_test
```python
pipeline {
    agent any
    stages {
        stage('Check Current Path') {
            agent { label 'master' }
            steps {
                sh '''hostname
                      hostname -i
                      pwd
                      ls -lrth
                      '''
            }
        }
        stage('ssh test') {
            agent { label 'slave' }
            steps {
                   sh '''
                   pwd
                   ls -lrth
                   ssh -o StrictHostKeyChecking=accept-new deploy@192.168.2.100 pwd
                   echo "AA" >> testfile
                   '''
            }
        }
        stage('scp test') {
            agent { label 'master' }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins_private_key', keyFileVariable: 'MY_SSH_KEY')]) {
                   sh '''
                   pwd
                   ls -lrth
                   scp -i $MY_SSH_KEY testfile deploy@192.168.2.100:/home/deploy
                   '''
                }
            }
        }
    }
}

```

### build number 변경 방법

1. /var/lib/jenkins/jobs/[job_name]/nextBuildNumber 파일 수정

2. Plugin 설치 -  Next Build Number Plugin
    - 변경할 프로젝트의 모든 빌드기록 삭제 후 <br>
     Set Next Build Number로 다음 빌드번호 지정
