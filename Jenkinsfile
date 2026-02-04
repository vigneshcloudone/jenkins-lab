pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO  = "201263439518.dkr.ecr.ap-south-1.amazonaws.com/jenkins-lab"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh "docker build -t jenkins-lab:${IMAGE_TAG} ."
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION |
                docker login --username AWS --password-stdin $ECR_REPO
                '''
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                docker tag jenkins-lab:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }
    }
}
