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

        def registry = 'https://trialdshkbv.jfrog.io/'
             stage("Jar Publish") {
            steps {
                script {
                        echo '<--------------- Jar Publish Started --------------->'
                         def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jfrog"
                         def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                         def uploadSpec = """{
                              "files": [
                                {
                                  "pattern": "jarstaging/(*)",
                                  "target": "libs-release-local/{1}",
                                  "flat": "false",
                                  "props" : "${properties}",
                                  "exclusions": [ "*.sha1", "*.md5"]
                                }
                             ]
                         }"""
                         def buildInfo = server.upload(uploadSpec)
                         buildInfo.env.collect()
                         server.publishBuildInfo(buildInfo)
                         echo '<--------------- Jar Publish Ended --------------->'  
                
                }
            }   
        }   
}
