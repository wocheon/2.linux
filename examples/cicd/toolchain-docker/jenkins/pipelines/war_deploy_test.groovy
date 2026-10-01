pipeline {
  agent any

  environment {
    IMAGE_NAME = "tomcat-testwebapp"
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
    stage('Pull Image to Nexus') {
        steps {
            script {
                sh "docker pull ${NEXUS_URL}:${NEXUS_URL_PORT}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    stage('rebuild & restart Container') {
      steps {
        echo 'Maybe sh is independent'
        sh'''
        docker run --rm -d -p 5001:8080 --name ${IMAGE_NAME} ${NEXUS_URL}:${NEXUS_URL_PORT}/${NEXUS_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
        docker image prune -f 
        docker system prune -f
        '''
      }
    }
  }
}
