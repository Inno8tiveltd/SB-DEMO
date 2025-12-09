pipeline {
    agent any

    tools {
        maven 'maven3'

    }

    stages {

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonarqube-server') {
            script {
                def scannerHome = tool 'sonarscanner'
                sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=SB-DEMO \
                    -Dsonar.projectName=SB-DEMO \
                    -Dsonar.sources=src \
                    -Dsonar.java.binaries=target
                """
            }
        }
    }
}

    }
}
