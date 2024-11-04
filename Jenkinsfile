pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE = 'devopscoacht/fastapi-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/devopscoacht/jenkins-project1.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_HUB_CREDENTIALS}") {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Add deployment steps (e.g., SSH to server and run Docker commands)
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
