pipeline { 
    agent {
            label 'deploy_node'
    }
    environment {
        
        // git Environments
        git_checkout_branch_name="main"
        git_checkout_url="xxx"
        git_credential_id="gitlab_credential"
        // pipeline Environments
        accept_pipeline_work='TRUE'
        target_variables_file="config_files/variables.txt"
        serverlist_yaml_file="config_files/serverList.yaml"
        ssh_credential="deploy_node_private_key"

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
        stage('Check Target Variables') {
            steps{
                script{
                    def variables = readFile("${env.target_variables_file}")
                        .spilt('\n') // split lines
                        .findAll { it && !it.startsWith('#')} //Ignore empty line and comments
                        .collectEntries { line ->
                            def (key, value) = line.split('=', 2)
                            [(key): value] //convert to key-value pair
                        }

                        env.target_source_id = variables['target_source_id']
                        echo "${target_source_id}"
                }
            }           
        }
        stage('Deply Jarfile to Target Server') {
            steps{
                script{
                    // yaml 파일 로드
                    def serverData = readYaml file: "${env.serverlist_yaml_file}"

                    // SSH Key 파일 사용 구간
                    withCredentails([sshUserPrivateKey(credentialsId: "${env.ssh_credential}", keyFileVariable: "MY_SSH_KEY")]) {
                        serverData.serverList.each { server ->
                            server.jarDir.each { jar->
                                if (jar.sourceId == env.target_source_id) {
                                    echo "[Server Info] Server Name: ${server.name} Host: ${server.host}\n -Source ID: ${jar.sourceId} Process Name: ${jar.ProcName}"
                                    echo "- Source  File : ${jar.source_file}, Jar_Path: ${jar.jarPath}"
                                    sh """
                                    ssh -o StrictHostKeyChecking=no -i $MY_SSH_KEY user@${server.host} "if [ -f ${jar.jarPath} ];then rm -rf ${jar.jarPath}_old; cp ${jar.jarPath} ${jar.jarPath}_old; else echo "#Copy New File"; fi;"
                                    scp -o StrictHostKeyChecking=no -i $MY_SSH_KEY user@${server.host} source_files/${jar.source_file} user@${server.host}:${jar.jarPath}
                                    ssh -o StrictHostKeyChecking=no -i $MY_SSH_KEY user@${server.host} "ls -lrth ${jar.jarPath}"
                                    """
                                }
                            }
                        }
                    }
                }
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
