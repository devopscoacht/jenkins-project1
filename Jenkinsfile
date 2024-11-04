pipeline {
    agent any

    environment {
        // Define all environment variables at pipeline level
        APP_NAME = 'fastapi-app'
        DOCKERHUB_USERNAME = 'devopscoacht'
        IMAGE_NAME = "${DOCKERHUB_USERNAME}/${APP_NAME}"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    cleanWs()
                    checkout scm
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh """
                            docker build -t ${IMAGE_NAME}:${IMAGE_TAG} \
                            --build-arg BUILD_NUMBER=${IMAGE_TAG} \
                            --no-cache .
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                        """
                    } catch (Exception e) {
                        error "Failed to build Docker image: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh """
                                echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                                docker push ${IMAGE_NAME}:latest
                            """
                        }
                    } catch (Exception e) {
                        error "Failed to push Docker image: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    try {
                        sh """
                            docker stop ${APP_NAME} || true
                            docker rm ${APP_NAME} || true
                            docker run -d \
                                --name ${APP_NAME} \
                                -p 8000:8000 \
                                --restart unless-stopped \
                                ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    } catch (Exception e) {
                        error "Failed to deploy: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    // Cleanup
                    sh """
                        docker logout || true
                        docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                        docker rmi ${IMAGE_NAME}:latest || true
                        docker system prune -f || true
                    """
                } catch (Exception e) {
                    echo "Cleanup failed: ${e.getMessage()}"
                }
                cleanWs()
            }
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
