pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REGISTRY = "201263439518.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPO = "jenkins-lab"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${ECR_REPO}:latest .
                """
            }
        }

        stage('Authenticate to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} \
                | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                """
            }
        }

        stage('Tag Image') {
            steps {
                sh """
                docker tag ${ECR_REPO}:latest \
                ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }
    }
}
