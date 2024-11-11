pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'devopscoacht/jenkins-project'      
        DOCKER_REGISTRY = 'https://registry.hub.docker.com'
        DOCKER_CREDENTIALS = credentials('dockerhub_credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', 
                    url: 'https://github.com/devopscoacht/jenkins-project1.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build with both BUILD_NUMBER and latest tags
                    docker.build("${DOCKER_HUB_REPO}:${BUILD_NUMBER}")
                    docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub_credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        // Login to Docker Hub
                        sh """
                            echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                            docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                            docker push ${DOCKER_HUB_REPO}:latest
                            docker logout
                        """
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Remove both tags of the image
                    sh """
                        docker rmi ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                        docker rmi ${DOCKER_HUB_REPO}:latest
                        docker system prune -f
                    """
                }
            }
        }
    }

    post {
        always {
            node {
                cleanWs()
            }
        }
        failure {
            error("Pipeline failed! Sending notifications...")
        }
        success {
            echo 'Pipeline succeeded! Deployment complete.'
        }
    }
}
