pipeline {
    agent {
        label 'windows-agent'
    }

    stages {
        stage('Build') {
            steps {
                echo 'STARTING PROJECT BUILD'
                pwsh '.\\build.ps1'
                echo 'FINISHED PROJECT BUILD'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'STARTING PROJECT DEPLOY'
                pwsh '.\\deploy.ps1'
                echo 'FINISHED PROJECT DEPLOY'
            }
        }
    }

    post {
        success {
            script {
                echo 'STARTING PROJECT CLEAN'
                pwsh '.\\clean.ps1'
                echo 'FINISHED PROJECT CLEAN'
            }
        }
        failure {
            def failingStage = currentBuild.currentExecutable.displayName
            mail body: 'Jenkins $failingStage step has failed. Check the logs for further details.', subject: 'Jenkins $failingStage FAILED', to: 'frascan@hotmail.it'
        }
    }
}