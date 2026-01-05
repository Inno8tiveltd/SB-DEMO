pipeline {
    agent any

    tools {
        maven 'maven3'
    }

    environment {
        AWS_REGION    = 'ap-southeast-1'
        EKS_CLUSTER   = 'sb-eks-cluster'
        K8S_NAMESPACE = 'sb-demo'
        APP_NAME      = 'sb-demo'
        REGISTRY = "trial6lqv76.jfrog.io"
        DOCKER_REPO = "docker-sb-docker-local"
        IMAGE_NAME = "sb-demo"
        IMAGE_TAG = "1.0"
         HELM_RELEASE   = "sb-demo"
    CHART_PATH     = "charts/sb-demo"
    }

    stages {

        stage('Build') {
            steps {
                echo 'Building the Project'
                sh 'mvn clean install -DskipTests=true'
                sh 'mvn package'
                sh 'mkdir -p stagingjar'
                sh 'cp target/*.jar stagingjar/'
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

                    def server = Artifactory.newServer(
                        url: "https://${REGISTRY}/artifactory",
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
                }
            }
        }
//         stage('Jar Publish') {
//     steps {
//         script {
//             echo '<--------------- Checking target folder --------------->'
//             sh 'ls -l target'

//             def server = Artifactory.server('jfrog-server')

//             def uploadSpec = '''{
//               "files": [
//                 {
//                   "pattern": "target/*.jar",
//                   "target": "spring-boot-libs-release-local/",
//                   "flat": true
//                 }
//               ]
//             }'''

//             server.upload(uploadSpec)
//         }
//     }
// }


    //     /* ===================== NEW STAGES ===================== */

        stage('Docker Build') {
            steps {
                echo 'Building Docker Image'
                sh """
                  docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Docker Tag') {
            steps {
                echo 'Tagging Docker Image'
                sh """
                  docker tag ${IMAGE_NAME}:${IMAGE_TAG} \
                  ${REGISTRY}/${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Docker Push to JFrog') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'jfrog',
                    usernameVariable: 'JF_USER',
                    passwordVariable: 'JF_PASS'
                )]) {
                    sh """
                      docker login ${REGISTRY} -u $JF_USER -p $JF_PASS
                      docker push ${REGISTRY}/${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
        // stage('Deploy to EKS') {
        //     steps {
        //         sh """
        //         sed -i 's|IMAGE_TAG|${IMAGE_TAG}|g' k8s/deployment.yaml
        //         kubectl apply -f k8s/ -n ${K8S_NAMESPACE}
        //         """
        //     }
        // }

        stage('Deploy (Helm)') {
  steps {
    script {
      env.IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    sh """
      aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
    """

    sh """
      kubectl get ns ${K8S_NAMESPACE} || kubectl create ns ${K8S_NAMESPACE}
    """

    sh """
      helm lint ${CHART_PATH}
    """

    sh """
      helm upgrade --install ${HELM_RELEASE} ${CHART_PATH} \
        -n ${K8S_NAMESPACE} \
        --set image.repository=${REGISTRY}/${DOCKER_REPO}/${IMAGE_NAME} \
        --set image.tag=${IMAGE_TAG} \
        --wait --timeout 5m
    """

    sh """
      kubectl rollout status deployment/${APP_NAME} \
      -n ${K8S_NAMESPACE} --timeout=3m
    """
  }
}
    }

}

