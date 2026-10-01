pipeline {
    agent any

  tools {
        maven 'jenkins-maven'  // Jenkins에 등록된 Maven tool 이름
    }

    environment {
        // SonarQube
        SONARQUBE_SCANNER = 'sonarqube_scanner'  // Jenkins에 등록된 SonarQube Scanner tool 이름
        SONARQUBE_SERVER = 'sonarqube'
        SONARQUBE_PROJECTKEY = 'war_build_test'

        // Nexus
        NEXUS_CREDENTIALS = 'nexus-credentials' // Jenkins에 등록된 Nexus 인증 정보 ID
        NEXUS_URL  = "nexus.test-cicd.com"
        NEXUS_URL_PORT  = 80
        MAVEN_NEXUS_REPO  = "maven-releases"
        DOCKER_NEXUS_REPO  = "docker-hosted"
        MVN_NEXUS_URL = 'http://nexus.test-cicd.com/repository/maven-releases/'

        // MVN 
        MVN_ARTIFACT_GROUP_ID = 'com.example'
        MVN_ARTIFACT_ID = 'testwebapp'
        MVN_ARTIFACT_VERSION = '1.0.0'
        MVN_ARTIFACT_PACKAGING = 'war'

        // Docker 
        DOCKER_IMAGE_NAME = "tomcat-testwebapp"
        DOCKER_IMAGE_TAG  = "latest"
    }
    
    stages {
        stage('SonarQube - Code Scan') {
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
        stage('Sonarqube - Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
       stage('Maven -Build') {
            steps {
                sh "mvn clean package"
            }
        }
        stage('Docker - Build Image') {
            steps {
                script {
                    sh "cp ./target/${MVN_ARTIFACT_ID}.war ./target/ROOT.war"
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${NEXUS_URL}:${NEXUS_URL_PORT}/${DOCKER_NEXUS_REPO}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }

        stage('Maven - Create Maven Settigs.xml') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIALS, passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                    writeFile file: 'settings.xml', text: """
                    <settings>
                      <servers>
                        <server>
                          <id>nexus</id>
                          <username>${env.NEXUS_USER}</username>
                          <password>${env.NEXUS_PASS}</password>
                        </server>
                      </servers>
                    </settings>
                    """
                }
            }
        }
        stage('Docker - Login to Nexus Docker Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIALS, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh "echo $NEXUS_PASS | docker login ${NEXUS_URL}:${NEXUS_URL_PORT} --username $NEXUS_USER --password-stdin"
                    }
                }
            }
        }
        stage('MAVEN - Upload to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.NEXUS_CREDENTIALS, passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {                    
                    sh """
                      mvn deploy:deploy-file -X \
                        -DgroupId=${env.MVN_ARTIFACT_GROUP_ID} \
                        -DartifactId=${env.MVN_ARTIFACT_ID} \
                        -Dversion=${env.MVN_ARTIFACT_VERSION} \
                        -Dpackaging=${env.MVN_ARTIFACT_PACKAGING} \
                        -Dfile=target/${env.MVN_ARTIFACT_ID}.${env.MVN_ARTIFACT_PACKAGING} \
                        -Durl=http://${env.NEXUS_URL}/repository/${env.MAVEN_NEXUS_REPO} \
                        -DrepositoryId=nexus \
                        --settings settings.xml;
                     rm -rf settings.xml
                    """
                }
            }
        }
        stage('DOCKER - Push Image to Nexus') {
            steps {
                script {
                    sh "docker push ${NEXUS_URL}:${NEXUS_URL_PORT}/${DOCKER_NEXUS_REPO}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }
}