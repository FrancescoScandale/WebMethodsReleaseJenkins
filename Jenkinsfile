pipeline {
    agent {
        label 'windows-agent'
        //label 'master'
    }

    stages {
        stage('Build') {
            steps {
                echo 'STARTING PROJECT BUILD'
                pwsh '.\\build.ps1'
                echo 'FINISHED PROJECT BUILD'
            }
        }
        post {
            success {
                stage('Deploy') {
                    steps {
                        echo 'STARTING PROJECT DEPLOY'
                        pwsh '.\\deploy.ps1'
                        echo 'FINISHED PROJECT DEPLOY'
                    }
                    post {
                        failure {
                            mail body: 'Jenkins deploy step has failed. Check the logs for further details.', subject: 'Jenkins deploy FAILED', to: 'frascan@hotmail.it'
                        }
                    }
                }
            }
            failure {
                mail body: 'Jenkins build step has failed. Check the logs for further details.', subject: 'Jenkins Build FAILED', to: 'frascan@hotmail.it'
            }
        }
        stage('Clean') {
            steps {
                echo 'STARTING PROJECT CLEAN'
                pwsh '.\\clean.ps1'
                echo 'FINISHED PROJECT CLEAN'
            }
        }
    }
}