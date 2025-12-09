pipeline {
    agent any

    tools {
        maven 'maven3'
        // If sonarscanner is installed using tool management
        // tool 'sonarscanner'
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

        stage('Upload Artifact to JFrog') {
            steps {
                script {
                    echo "Uploading JAR to JFrog Artifactory..."

                    // Connect to JFrog Artifactory using credential ID 'jfrog'
                    def server = Artifactory.server('jfrog')

                    // Upload specification
                    def uploadSpec = """{
                      "files": [{
                        "pattern": "target/*.jar",
                        "target": "libs-release-local/hello-world/"
                      }]
                    }"""

                    // Upload to Artifactory
                    server.upload(uploadSpec)

                    // Publish build info
                    server.publishBuildInfo()
                }
            }
        }

    }
}
