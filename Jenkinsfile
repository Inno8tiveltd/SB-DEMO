pipeline {
    agent {
        node{
            label 'maven'
        }
    }
     tools {
        maven 'maven3'
        SonarQube Scanner 'sonarscanner'
    }

    stages {
        stage('build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=sonar00732_spring-boot-application -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
                }
            }
        }
    }
}
