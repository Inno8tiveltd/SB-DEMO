pipeline {
    agent any

    tools {
        maven 'maven3'
        sonarScanner 'sonarscanner'    // <<< MUST MATCH JENKINS TOOL NAME
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
                    withSonarQubeEnv('sonarqube-server') {   // <<< MUST MATCH SONARQUBE SERVER NAME
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
