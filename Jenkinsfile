def FAILED_STAGE

pipeline {
    agent {
        label 'windows-agent'
    }

    stages {
        stage('Build') {
            steps {
                FAILED_STAGE=env.STAGE_NAME
                echo 'STARTING PROJECT BUILD'
                pwsh '.\\build.ps1'
                echo 'FINISHED PROJECT BUILD'
            }
        }
        
        stage('Deploy') {
            steps {
                FAILED_STAGE=env.STAGE_NAME
                echo 'STARTING PROJECT DEPLOY'
                pwsh '.\\deploy.ps1'
                echo 'FINISHED PROJECT DEPLOY'
            }
        }

        stage('Clean') {
            steps {
                FAILED_STAGE=env.STAGE_NAME
                echo 'STARTING PROJECT CLEAN'
                pwsh '.\\clean.ps1'
                echo 'FINISHED PROJECT CLEAN'
            }
        }
    }

    post {
        failure {
            script {
                mail body: 'Jenkins ${FAILED_STAGE} step has failed. Check the logs for further details.', subject: 'Jenkins ${FAILED_STAGE} FAILED', to: 'frascan@hotmail.it'
            }
        }
    }
}