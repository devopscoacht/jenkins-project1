pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_REPO = 'devopscoacht/jenkins-project'
        IMAGE_TAG = "${env.BUILD_ID}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/devopscoacht/jenkins-project1.git', branch: 'master', credentialsId: 'github-credentials'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def app = docker.build("${DOCKERHUB_REPO}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-credentials') {
                        def app = docker.image("${DOCKERHUB_REPO}:${IMAGE_TAG}")
                        app.push()
                    }
                }
            }
        }
    }
}
