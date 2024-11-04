pipeline {
    agent any

    environment {
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
                cleanWs()
                git branch: 'master',
                    url: 'https://github.com/devopscoacht/jenkins-project1.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} .
                    docker tag ${env.IMAGE_NAME}:${env.IMAGE_TAG} ${env.IMAGE_NAME}:latest
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \${DOCKER_PASS} | docker login -u \${DOCKER_USER} --password-stdin
                        docker push ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                        docker push ${env.IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stop ${env.APP_NAME} || true
                    docker rm ${env.APP_NAME} || true
                    docker run -d \
                        --name ${env.APP_NAME} \
                        -p 8000:8000 \
                        --restart unless-stopped \
                        ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                """
            }
        }
    }

    post {
        always {
            node('built-in') {
                sh """
                    docker logout || true
                    docker rmi ${env.IMAGE_NAME}:${env.IMAGE_TAG} || true
                    docker rmi ${env.IMAGE_NAME}:latest || true
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
