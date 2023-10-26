pipeline {
    agent {
        label 'windows-agent'
        //label 'master'
    }

    stages {
        stage('Build') {
            steps {
                echo 'STARTING PROJECT BUILD'
                pwsh '.\build.ps1'
                echo 'FINISHED PROJECT BUILD'
            }
        }
    }
}