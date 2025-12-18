pipeline {
    agent any

    tools {
        maven 'maven3'
    }

    environment {
        REGISTRY = "https://trialdshkbv.jfrog.io"
    }

    stages {

        stage('Build') {
            steps {
                echo 'Building the Project'
                sh 'mvn clean install -DskipTests=true'
                sh 'mvn package'
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

        stage('Jar Publish') {
            steps {
                script {

                    echo '<--------------- Checking target folder --------------->'
                    sh 'ls -l target'

                    echo '<--------------- Jar Publish Started --------------->'

                    def server = Artifactory.newServer(
                        url: "${REGISTRY}/artifactory",
                        credentialsId: "jfrog"
                    )

                    def uploadSpec = '''{
                        "files": [
                            {
                                "pattern": "target/*.jar",
                                "target": "spring-boot-libs-release-local/",
                                "flat": true
                            }
                        ]
                    }'''

                    server.upload(spec: uploadSpec)

                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }
    }
}
