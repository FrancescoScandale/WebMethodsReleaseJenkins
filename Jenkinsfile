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
        stage('Deploy') {
            steps {
                echo 'STARTING PROJECT DEPLOY'
                pwsh '.\\deploy.ps1'
                echo 'FINISHED PROJECT DEPLOY'
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