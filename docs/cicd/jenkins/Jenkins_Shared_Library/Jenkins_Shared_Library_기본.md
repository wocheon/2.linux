# Jenkins Shared Library 기본

등록 방법과 `vars/`, `resources/` 사용 예제를 모았습니다. 클래스 예제는 [Shared Library 클래스](Jenkins_Shared_Library_클래스.md)를 참고합니다.

---

## Shared Library 설정

### Jenkins Shared Library?
- 여러 파이프라인에서 공통 코드를 재사용할 수 있게 해주는 기능
- 하나의 Git 저장소에 공통으로 사용하는 Groovy 스크립트, 클래스, 템플릿 등을 저장
    - 모든 프로젝트에서 @Library('shared-lib')형태로 불러와서 사용 가능

- Jenkins Shared Library의 장단점
    - 장점
        - 여러 프로젝트에서 동일한 스크립트를 사용하므로 중앙화된 관리 가능해짐
        - 태그/브랜치를 통해 특정 버전의 라이브러리를 사용가능
        - 단위 테스트 포함 가능 (src/ 구조)
        - DevOps Best Practice에 부합

    - 단점
        - 처음 설정 시 Jenkins에 등록하는 수고가 있음
        - Jenkins Master 노드 또는 Folder-level에 설정 필요

#### Jenkins Shared Library 기본 구조

```
shared-library/
├── vars/
│   └── buildPipeline.groovy      # 함수형 API
├── src/
│   └── org/company/build/Deploy.groovy  # 클래스 기반 로직
└── resources/
    └── org/company/template.yml
```

- vars/
    - Jenkinsfile에서 함수처럼 바로 호출할 수 있는 스크립트. 내부에 call() 또는 메서드를 정의합니다.
        - EX) buildApp()

- src/
    - Groovy 클래스를 넣는 곳. 복잡한 로직을 분리하고 싶을 때 사용. 패키지 구조 필수
        - EX) com.mycompany.utils.SomeHelper

- resources/
    - 템플릿 파일, YAML, JSON 등 pipeline 실행 시 필요한 리소스들
        - EX) env.env, config.json


###  Jenkins Shared Library 용 Git 저장소 생성
- gitlab 저장소 생성
    - 저장소 명 : jenkins_shared_library

- 저장소 생성 후, 기본 구조와 같이 디렉토리 생성 진행

- Jenkins 연동이 필요하므로 Access Token을 확인하고 Credentials로 등록
    - GitHub : Personal Access Token
    - GitLab : Project Access Token OR UserID/PW

### Jenkins 내 Jenkins Shared Library 설정

- 설정 방법
    - Jenkins 관리 -> System -> Global Trusted Pipeline Libraries에 정보 입력
        - Name : Library 명 (추후 Pipeline에서 로드시 사용됨)
        - Default Version : 기본 브랜치 명
        - Retrieval method : Modern SCM
        - Source Code Mgmt : git
        - Project repository : 저장소 URL (GitHub/GitLab 주소)
        - Credentials : 저장소 접근용 Credentials

#### Global Trusted/Untrusted Libraries ?
- System 내에는 `Global Trusted Libraries`와  `Global Untrusted Libraries` 섹션이 구분되어있는데, 다음 내용을 참고하여 선택하여 필요한 라이브러리를 등록 하여 사용할것

    - 가능하면 `Global Trusted Libraries`를 사용


    #### Global Trusted/Untrusted Libraries 별 특징

    | 항목               | **Trusted Pipeline Library**                            | **Untrusted Pipeline Library**                   |
    | ---------------- | ------------------------------------------------------- | ------------------------------------------------ |
    | 📦 위치            | Global 설정 or Folder-level 설정<br>(`Manage Jenkins`에서 등록) | `@Library('<lib-name>')` + SCM (예: Git) 에서 직접 로드 |
    | 🔒 Sandbox 제약    | ❌ 없음 (제한 없이 모든 Groovy 기능 사용 가능)                         | ✅ Jenkins **sandbox 내에서 제한적으로 실행**됨              |
    | 🧪 사용할 수 있는 기능   | 파일 읽기, 네트워크 접근, 시스템 API 사용 등 허용                         | 제한적 (네트워크, 파일 시스템 접근 등 금지됨)                      |
    | 🔧 Groovy 클래스 정의 | ✅ 자유롭게 가능 (POJO, static method 등)                       | 🔶 제한 있음 (특정 패턴만 허용)                             |
    | 📁 Typical 사용처   | 기업 내부에서 관리하는 안전한 공통 라이브러리                               | 외부 Contributor 또는 외부 리포의 라이브러리                   |
    | ☣️ 보안 위험         | 낮음 (신뢰된 코드만 사용됨)                                        | 높음 (코드가 검증되지 않음)                                 |


### Groovy 스크립트 내 사용방법

- Jenkinsfile 최상단에 다음과 같이 선언하여 사용

```groovy
// 기본
@Library('라이브러리이름') _

// 버전(브랜치) 지정 시
@Library('라이브러리이름@브랜치명') _
```

- 함수 사용 예시

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                script {
                    exampleFunction() // vars/example.groovy에 정의된 함수
                }
            }
        }
    }
}
```


---

## 전역 함수 (`vars/`)

### 개요
- Jenkins Shared Library의 전역함수(vars/)를 구성
- Pipeline 스크립트에서 해당 함수를 호출 하여 사용하도록 구성


### Jenkins Shared Library 내 전역함수 (vars/)

```
shared-library/
├── vars/
   └── buildPipeline.groovy      # 함수형 API
```
- /vars 폴더는 파이프라인에서 직접 호출할 수 있는 전역 함수(글로벌 변수/함수) 또는 `스텝(Step)`을 정의하는 공간

- 해당 디렉토리에 groovy 파일을 생성하여 함수를 정의하면 이를 호출해서 사용 가능

- 글로벌 변수(Global Variable)/글로벌 함수(Global Function)/스텝(Step)/커스텀 스텝(Custom Step) 등 으로 불림
    - Jenkins 공식 문서에서는 글로벌 변수(Global Variable)로 지정
    - 해당 스크립트에서 정의한 함수는 하나의 step 처럼 동작하므로 Step/Custom Step으로 부르기도 함

- 주로 steps 블록에서 바로 사용
    - 변수 처리/조건문/반복문등 복잡한 작업이 필요한경우, Script 구문 내에서 동작 필요


- 전역 함수만을 사용하는 경우, 디렉토리 구조가 복잡해질 수  있음
    - 하위 디렉토리 구조를 만들수 없어, 각 기능별로 구분하기 어려움
        - 기능별 디렉토리 구성을 위해서는 class로 변경 필요
        - 간단한 함수는 전역함수로, 복잡한 구성은 Class로 구성 필요


### 기본 동작 구조

- 테스트 용 함수 작성
    -  jenkins_shared_library/vars/sayHello.groovy
```groovy
def call(String name = "Test") {
    echo "Hello ${name}!"
}
```

- Jenkinsfile에서 사용 예시

```groovy
// Jenkins Shared Library 호출
@Library('my-shared-library') _

pipeline {
    agent any
    stages {
        stage('Greet') {
            steps {
                // 작성한 파일명과 동일한 명칭으로 함수를 호출
                sayHello('Jenkins')
            }
        }
    }
}
```

### 함수 구성 예시

#### node_check.groovy
- 현재 실행중인 노드 정보 확인용함수
```groovy
def call() {
	sh '''
	echo "### Node Info ###"
	echo "- Hostname : $(hostname) , IP : $(hostname -i | gawk '{print $1}') User : $(whoami)"
	echo "- Work_dir : $(pwd)"
	echo "- Work dir File list"
	ls -lrth
	'''
}
```

#### pipeline_work_check.groovy
-  특정 환경변수 값에 따라 강제로 에러를 발생시켜 파이프라인 실행 중지

```groovy
def call(String pipeline_work_variable) {
    if (pipeline_work_variable != "TRUE") {
            echo "# Pipeline Work Variable is Not TRUE"
             error("# Force Error Occured")
            }
}
```

#### load_variables_from_file

- key=value 형태로 구성된 파일을 읽어서, 해당 값을 variables 배열에 할당
    - 주로 environment/config 파일 내 지정한 변수를 불러올때 사용
```groovy
def call(String variables_file) {
    // Read and parse the variables file
    def variables = readFile(variables_file)
        .split('\n') // Split lines
        .findAll { it && !it.startsWith('#') } // Ignore empty lines and comments
        .collectEntries { line ->
            def (key, value) = line.split('=', 2)
            [(key): value] // Convert to key-value pair
        }

    return variables
}
```


#### slack_pipeline_approval.groovy
- 해당 함수 실행시, 현재 단계에서 input 값을 받을때까지 대기하며, 값을 받은 이후에 다음단계가 진행됨

- 승인요청(input값 요청) 발생 시 지정한 Slack 채널로 승인 페이지 링크를 포함한 알림을 발송


```groovy
def call(String channelID) {
    def jobName = env.JOB_NAME ?: 'Unknown Job'
    def buildNumber = env.BUILD_NUMBER ?: 'Unknown Build'
    def buildUrl = env.BUILD_URL ?: ''

    def message = """
    :rocket: *배포 승인 요청*
    프로젝트: `${jobName}`
    빌드번호: `#${buildNumber}`
    상세정보: ${buildUrl}/input
    """

    slackSend(
        channel: channelID,
        message: message,
        color: '#36a64f'  // 초록색 (원하는 색으로 변경 가능)
    )

    input message: '배포하시겠습니까?', ok: '승인'
}
```


#### SlackSuccess.groovy
- 빌드 성공 시 지정된 Slack 채널로 알림을 보내는 함수
- 함수 호출시에 지정한 CustomMessage + BaseMessage를 Slack으로 발송
- BaseMessage에는 빌드 정보/빌드 페이지 링크가 포함함
- color는 good (초록색)으로 지정

```groovy
def call(String channel, String customMessage = '') {
    def baseMessage = ":hammer_and_wrench: Build Info: *${env.JOB_NAME} #${env.BUILD_NUMBER}*\n:globe_with_meridians:<${env.BUILD_URL}|View Result On Jenkins>"
    def msg = customMessage ? "${customMessage}\n${baseMessage}" : baseMessage
    slackSend(channel: channel, color: 'good', message: msg)
}
```

#### SlackFailures.groovy
- 빌드 실패 시 지정된 Slack 채널로 알림을 보내는 함수
- 함수 호출시에 지정한 CustomMessage + BaseMessage를 Slack으로 발송
- BaseMessage 에는 빌드정보/로그내역(마지막 15줄)/리빌드 링크/빌드 페이지 링크가 포함
    - Rebuild 링크 사용시 별도 Plugin 및 Script Approval 설정
- color는 good (초록색)으로 지정

```groovy
def call(String channel, String customMessage = null) {
    script {
        def fullLog = currentBuild.rawBuild.getLog(150)
        def filteredLog = fullLog.findAll { line -> !(line.startsWith('[Pipeline]') || line.startsWith('+')) }
        def lastline = filteredLog.takeRight(15).join('\n')
        def rebuildUrl = "${env.BUILD_URL}rebuild"

        def baseMessage = """\n:hammer_and_wrench: Build Info: *${env.JOB_NAME} #${env.BUILD_NUMBER}*\n:mag: *Last Logs* (tail 15)\n```${lastline}\n```\n<${rebuildUrl}|*:repeat: Rebuild Now*>\n\n:globe_with_meridians:<${env.BUILD_URL}|View Result On Jenkins>"""

        def msg = customMessage ? "${customMessage}\n${baseMessage}" : ":exclamation:[CI/CD] - 배포 오류\nSource_id : ${env.target_source_id}\n${baseMessage}"

        slackSend(
            channel: channel,
            color: 'danger',
            message: msg
        )
    }
}
```

#### jenkins_default_variables.groovy
- 현재 실행중인 빌드의 기본 환경변수를 출력
- 디버깅 용도로 사용 가능
```groovy
def call() {
    echo "==== Jenkins Core Variables ===="
    echo "JENKINS_HOME: ${env.JENKINS_HOME}"
    echo "JENKINS_URL: ${env.JENKINS_URL}"
    echo "JOB_NAME: ${env.JOB_NAME}"
    echo "JOB_BASE_NAME: ${env.JOB_BASE_NAME}"
    echo "JOB_URL: ${env.JOB_URL}"
    echo "BUILD_NUMBER: ${env.BUILD_NUMBER}"
    echo "BUILD_ID: ${env.BUILD_ID}"
    echo "BUILD_TAG: ${env.BUILD_TAG}"
    echo "BUILD_URL: ${env.BUILD_URL}"
    echo "EXECUTOR_NUMBER: ${env.EXECUTOR_NUMBER}"
    echo "NODE_NAME: ${env.NODE_NAME}"
    echo "NODE_LABELS: ${env.NODE_LABELS}"
    echo "WORKSPACE: ${env.WORKSPACE}"

    echo "\n==== Git Variables (if SCM is Git) ===="
    echo "GIT_COMMIT: ${env.GIT_COMMIT}"
    echo "GIT_PREVIOUS_COMMIT: ${env.GIT_PREVIOUS_COMMIT}"
    echo "GIT_BRANCH: ${env.GIT_BRANCH}"
    echo "GIT_LOCAL_BRANCH: ${env.GIT_LOCAL_BRANCH}"
    echo "GIT_URL: ${env.GIT_URL}"
    echo "GIT_AUTHOR_NAME: ${env.GIT_AUTHOR_NAME}"
    echo "GIT_AUTHOR_EMAIL: ${env.GIT_AUTHOR_EMAIL}"

    echo "\n==== Pull Request Variables (if Multibranch) ===="
    echo "CHANGE_ID: ${env.CHANGE_ID}"
    echo "CHANGE_URL: ${env.CHANGE_URL}"
    echo "CHANGE_TITLE: ${env.CHANGE_TITLE}"
    echo "CHANGE_AUTHOR: ${env.CHANGE_AUTHOR}"
    echo "CHANGE_AUTHOR_DISPLAY_NAME: ${env.CHANGE_AUTHOR_DISPLAY_NAME}"
    echo "CHANGE_BRANCH: ${env.CHANGE_BRANCH}"
    echo "CHANGE_TARGET: ${env.CHANGE_TARGET}"

    echo "\n==== System Environment ===="
    echo "HOME: ${env.HOME}"
    echo "PATH: ${env.PATH}"
    echo "SHELL: ${env.SHELL}"
    echo "USER: ${env.USER}"
    echo "PWD: ${env.PWD}"

    echo "\n==== Full Environment (printenv) ===="
    sh 'printenv | sort'
}
```



### 예시 - Jenkins Shared Library 전역 함수를 이용한 Groovy 스크립트

- test_values.txt
```sh
# 1-5
value_1="111"
value_2="222"
value_3="333"
value_4="444"
value_5="555"
# a-c
value_a="aaa"
value_b="bbb"
value_c="ccc"
```


- jenkins_files/Jenkinsfile.groovy

```groovy
// Jenkins Shared Library 지정
@Library('jenkins_shared_library') _

pipeline {
    agent { label 'test'}
    environment {
        SLACK_CHANNEL = '#test_alert'
		target_source_id = 'testid'
		accept_pipeline_work='TRUE'
		variable_file="test_values.txt"
    }
    stages {
        // 파이프라인 실행 여부를 확인하는 커스텀 함수 호출
        stage('Pipeline_work_check') {
		    steps {
			  pipeline_work_check(env.accept_pipeline_work)
			}
		}
        // 빌드가 실행되는 노드의 상태 또는 조건을 확인하는 커스텀 함수 호출
		stage('Node_Check') {
		    steps {
			    node_check()
			}
		}
         // 현재 파이프라인의 모든 환경 변수 값을 출력하는 커스텀 함수 호출
        stage('Show All Environment Variables') {
            steps {
                jenkins_default_variables()
            }
        }
         // Slack 채널을 통해 파이프라인 승인 처리
        stage('slack_pipeline_approval')
        {
         steps{
                slack_pipeline_approval(env.SLACK_CHANNEL)
            }
         }
         // 파일에서 변수 값을 읽어와 환경 변수로 할당하고, 값을 출력
		stage('read_variable test')
		{
		    steps{
		        script{
		            def variables = load_variables_from_file("test_values.txt")
		            env.target_value_1 = variables['value4']
		            env.target_value_2 = variables['valueb']
		            echo "${env.target_value_1} , ${env.target_value_2}"
		        }
		    }
		}
    }
    // 빌드 결과에 따른 Slack 알림 발송
    post {
        // 빌드 성공시에만 발송
        success {
            slackSuccess(env.SLACK_CHANNEL, "✅ 배포 성공!")
        }
        // 빌드 실패시에만 발송
        failure {
            slackFailure(env.SLACK_CHANNEL, "⛔ 배포 실패!")
        }
    }
}

```


---

## 리소스 (`resources/`)

### 개요
- Jenkins Shared Library의 리소스 내에 파일를 구성
- Pipeline 스크립트에서 리소스를 호출하여 함수나 Class.Method에서  사용하도록 구성


### Jenkins Shared Library 내 리소스 (resources/)
```
shared-library/
└── resources/
    └── org/company/template.yml
```
 - 템플릿 파일, 설정 파일, 스크립트, 정적 데이터 등 파이프라인에서 활용할 다양한 리소스를 저장하는 공간
    - EX) 이메일 템플릿, YAML/JSON 설정 파일, 셸 스크립트 등

- 파이프라인 또는 Shared Library의 함수에서 `libraryResource` 스텝을 이용해 해당 리소스의 내용을 읽고 이를 반환하여 사용가능
  - **리소스 파일 로드 가 아닌 파일 내용을 읽고 문자열을 반환하는 것이므로 주의 필요**

  - EX)
    ```groovy
    // resources/email_template.txt
    Hello, this is your build notification.

    // vars/sendEmail.groovy
    def call() {
        def template = libraryResource('email_template.txt')
        echo template
    }
    ```


### 예시 - Jenkins Shared Library 내 .env 리소스 사용
- Jenkins Shared Library 내에 저장한 env.env 파일을 읽어서 이를 파이프라인의 Environment로 사용


##### jenkins_shared_library/resources/configs/env.env
- 파이프라인에서 environment 구문에서 지정하는 환경 변수를 별도 파일로 분리
-  Pipeline context(this 또는 steps)를 인자로 받아 사용

```env
SLACK_CHANNEL = '#test_alert'
target_source_id = 'testid'
accept_pipeline_work='TRUE'
variable_file="test_values.txt"
```

##### jenkins_shared_library/vars/loadEnvVariables.groovy
  - 리소스 파일을 지정하여 loadVariablesFromString를 호출 하는 함수
  -

  -  `loadVariablesFromString`
      - 지정한 리소스파일을 읽어 content에 할당
      -  libraryResource로 리소스 로드시 파일 내 문자열을 리턴하므로 문자열을 파싱하는 별도 함수를 사용
      -  기존 함수(loadVariables)는 readfile 로 인해 리소스내의 문자열을 파일명으로 인식하므로 사용 불가

      ```groovy
      def call(script, String resourcePath) {
          def content = script.libraryResource(resourcePath)
          return loadVariablesFromString(content)
      }

      def loadVariablesFromString(String content) {
          return content
              .split('\n')
              .findAll { it && !it.startsWith('#') && it.contains('=') }
              .collectEntries { line ->
                  def (key, value) = line.split('=', 2)
                  [(key.trim()): value.trim().replaceAll(/^['"]|['"]$/, '')]
              }
      }
      ```


#### Jenkins Pipeline 스크립트에서 사용
```groovy
// Jenkins Shared Library 지정
@Library('jenkins_shared_library') _

pipeline {
  agent { label 'test'}

  stages {
    stage ('Load .env from Jenkins Shared Library'){
      steps{
        script{
          //  Pipeline context를 this로 전역함수에 전달
          // 리소스파일을 매개변수로 loadVariables 함수를 실행 후, 결과값을 변수 envVars에 할당
          def envVars = loadVariables(this, 'config/env.env')

         // Pipeline 실행에 필요한 변수를 env로 할당
          env.SLACK_CHANNEL = envVars['SLACK_CHANNEL']
          env.accept_pipeline_work = envVars['accept_pipeline_work']
          env.variable_file = envVars['variable_file']
        }
      }
    }
    // 파이프라인 실행 여부를 확인하는 커스텀 함수 호출
    stage('Pipeline_work_check') {
	   steps {
	 	  pipeline_work_check(env.accept_pipeline_work)
	 	}
	 }
    // 파일에서 변수 값을 읽어와 환경 변수로 할당하고, 값을 출력
	 stage('read_variable test'){
	   steps{
	     script{
	       def variables = load_variables_from_file(env.variable_file)
	         env.target_value_1 = variables['value4']
	         env.target_value_2 = variables['valueb']
	         echo "${env.target_value_1} , ${env.target_value_2}"
	     }
	   }
	 }
  }
  // 빌드 결과에 따른 Slack 알림 발송
  post {
    // 빌드 성공시에만 발송
    success {
      slackSuccess(env.SLACK_CHANNEL, "✅ 배포 성공!")
    }
    // 빌드 실패시에만 발송
    failure {
      slackFailure(env.SLACK_CHANNEL, "⛔ 배포 실패!")
    }
  }
}

```
