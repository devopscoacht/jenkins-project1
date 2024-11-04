pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'devopscoacht/fastapi-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        GIT_REPO = 'https://github.com/devopscoacht/jenkins-project1.git'
        GIT_BRANCH = 'master'
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
                    git branch: "${GIT_BRANCH}",
                        url: "${GIT_REPO}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Login to DockerHub
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh """
                            docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                                --build-arg BUILD_NUMBER=${DOCKER_TAG} \
                                --no-cache .
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )]) {
                        sh """
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                        docker stop fastapi-app || true
                        docker rm fastapi-app || true
                        docker run -d \
                            --name fastapi-app \
                            -p 8000:8000 \
                            --restart unless-stopped \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Cleanup
                sh """
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker rmi ${DOCKER_IMAGE}:latest || true
                    docker system prune -f || true
                """
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
