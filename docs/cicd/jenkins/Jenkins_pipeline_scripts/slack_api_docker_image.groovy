pipeline { 
    agent {
            label 'slack_node'
    }
    environment {
        // git Environments
        git_checkout_branch_name="main"
        git_checkout_url="xxx"
        git_credential_id="gitlab_credential"
        // Pipeline Environments
        accept_pipeline_work='TRUE'
        SLACK_TOKEN=credentials('slack_oauth_token')  // secret_text로 저장됨
        // Slack Notifications Environment
        SLACK_CHANNEL = "#cicd_alert"
        SLACK_COLOR = "good"

    }
    
    stages{
        stage('Aceept Pipeline Work Check'){
            steps{
                script{
                    if(env.accept_pipeline_work != "TRUE") {
                        error('# Accept Pipeline work Is Not True!')
                    }
                }
            }
        }
        stage('Node Check'){
            steps{
                sh'''
                echo "### Node Info ###"
                echo "- Hostname : $(hostname), IP : $(hostname | gawk '{print $1}') , User : $(whoami)"
                echo "- Work_dir : $(pwd)
                ls -lrth
                '''
            }
        }
        stage('Gitlab CheckOut on Work Dir') {
            steps{
                git branch: "${env.git_checkout_branch_name}",
                credentialsId: "${env.git_credential_id}",
                url: "${env.git_checkout_url}"
            }
        }
        stage('Rebuild Docker Image') {
            steps{
                script{
                def version_check_1 = sh(script: "docker image ls | grep slack_api_docker_image | gawk '{print \$2}' | sort -rh | head -1", returnStdout: true).trim()
                env.Latest_version = version_check_1
                def version_check_2 = sh(script: "echo ${env.Latest_version}+0.1 | bc", returnStdout: true).trim()
                env.Next_version = version_check_2

                sh'''
                echo "# Docker Image Version Check"
                echo "Latest Version : ${Latest_version}, Next Version : ${Next_version}"
                echo "# Rebuild Docker Image"
                docker build -t [gitlab_url]:[gitlab_container_repo_port]/[gitlab_url]/slack_api_docker_image:${Next_version} .
                '''
                }
            }           
        }
        stage('Push New Docker Image') {
            steps{
                sh'''
                echo "# Push New Version Docker Image to gitlab"
                docker push [docker_image_name]:${Next_version}
                '''
            }
        }
        stage('Run Docker Container with New Docker Image') {
            steps{
                sh'''
                docker image rm [docker_image_name]:${Latest_version} -f
                docker rm slack-api -f
                docker run -d -p 5000:5000 -e SLACK_TOKEN=${SLACK_TOKEN} --name slack-api [docker_image_name]:${Next_version}
                docker ps -a
                '''
            }
        }
    }
    post {
        success {
            slackSend(channel: env.SLACK_TOKEN, color: 'good', message: ":exclamation: *[CI/CD] Docker Image Version Updated (Version : ${env.Next_version}) *")
        }
        failure {
            slackSend(channel: env.SLACK_TOKEN, color: 'good', message: ":exclamation: *[CI/CD] Error - Jenkins Pipeline Failed! *")
        }
    }

}