pipeline {
    agent any

    environment {
        // Replace with your Docker Hub username
        registryCredentials = 'dockerhub_credentials'
        dockerImage        = ''
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/devopscoacht/jenkins-project1.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("devopscoacht/jenkins-project:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                script {
                    docker.withRegistry('', 'registryCredentials') {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Cleanup') {
            steps {
                sh "docker rmi devopscoacht/jenkins-project:${env.BUILD_NUMBER}"
            }
        }
    }
}
