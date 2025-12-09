pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        SONARQUBE = credentials('sonar-creds') // optional only if using token
    }

    stages {

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            sonar-scanner \
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
