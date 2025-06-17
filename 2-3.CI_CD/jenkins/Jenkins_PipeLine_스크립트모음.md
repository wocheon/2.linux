## 0.pipeline_test
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



## 1.pipeline_syntax_if_test
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

## 2.Dockerfile_Webhook_Deploy
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


## 3.mvn_build_test
### Maven Project
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

### System & Credentials
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

## 4. Maven_Pipeline_Deploy

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

## 6. scp_test
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
                   ssh -o StrictHostKeyChecking=no root@192.168.2.100 pwd
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
                   scp -i $MY_SSH_KEY testfile root@192.168.2.100:/root
                   '''
                }
            }
        }                
    }
}

```

# build number 변경 방법

1. /var/lib/jenkins/jobs/[job_name]/nextBuildNumber 파일 수정 
   
2. Plugin 설치 -  Next Build Number Plugin
    - 변경할 프로젝트의 모든 빌드기록 삭제 후 <br>
     Set Next Build Number로 다음 빌드번호 지정