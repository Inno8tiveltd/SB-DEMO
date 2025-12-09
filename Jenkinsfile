pipeline {
    agent any

    tools {
        maven 'maven3'

    }

    stages {

        stage('Build') {
            steps {
                echo 'Building the Project'
                sh 'mvn clean install -DskipTests=true' 
            }
        }
        stage('Test') {
            steps {
                echo 'Running Unit Tests'
                sh 'mvn surefire-report:report'
                echo 'Unit Tests Completed'
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
