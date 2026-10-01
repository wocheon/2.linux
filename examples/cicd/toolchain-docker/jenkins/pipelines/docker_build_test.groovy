pipeline {
  agent any

  environment {
    SONARQUBE_SERVER = 'sonarqube'
    SONARQUBE_SCANNER = 'sonarqube_scanner'
    SONARQUBE_PROJECTKEY = 'docker_build_test'
    IMAGE_NAME = "tz-converter"
    IMAGE_TAG  = "latest"
    NEXUS_URL  = "nexus.test-cicd.com"
    NEXUS_URL_PORT  = 80
    NEXUS_REPO  = "docker-hosted"
    DOCKER_CREDENTIALS_ID = "nexus-credentials"
  }

  stages {
    stage('Check Workspace Path & FIles') {
      steps {
        echo 'execute ls command'
        sh '''
          pwd; ls -la
        '''
      }
    }
    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('sonarqube') {
          withCredentials([string(credentialsId: 'sonarqube-token', variable: 'token')]) {
            script {
              def scannerHome = tool env.SONARQUBE_SCANNER
              sh """              
                ${scannerHome}/bin/sonar-scanner \
                  -Dsonar.projectKey=${env.SONARQUBE_PROJECTKEY} \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=http://test-cicd.com/sonarqube \
                  -Dsonar.login=$token              
              """
            }
          }
        }
      }
    }
    stage('Quality Gate') {
      steps {
        timeout(time: 1, unit: 'HOURS') {
          waitForQualityGate abortPipeline: true
        }
      }
    }


    
    stage('Build Docker Image') {
        steps {
            script {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
    }
    stage('Tag Image for Nexus') {
        steps {
            script {
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${NEXUS_URL}:${NEXUS_URL_PORT}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    
    stage('Login to Nexus Docker Registry') {
        steps {
            script {
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh "echo $NEXUS_PASS | docker login ${NEXUS_URL}:${NEXUS_URL_PORT} --username $NEXUS_USER --password-stdin"
                }
            }
        }
    }
    stage('Push Image to Nexus') {
        steps {
            script {
                sh "docker push ${NEXUS_URL}:${NEXUS_URL_PORT}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
  }
}
