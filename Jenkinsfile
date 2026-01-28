pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "201263439518.dkr.ecr.ap-south-1.amazonaws.com/jenkins-lab"
        IMAGE_TAG = "latest"
        TARGET_EC2 = "ubuntu@172.31.2.211"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t jenkins-lab:${IMAGE_TAG} .'
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
                docker tag jenkins-lab:${IMAGE_TAG} $ECR_REPO:${IMAGE_TAG}
                docker push $ECR_REPO:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                ssh -o StrictHostKeyChecking=no $TARGET_EC2 << EOF
                  aws ecr get-login-password --region ap-south-1 |
                  docker login --username AWS --password-stdin $ECR_REPO

                  docker pull $ECR_REPO:${IMAGE_TAG}

                  docker stop webapp || true
                  docker rm webapp || true

                  docker run -d \
                    --name webapp \
                    -p 8081:80 \
                    $ECR_REPO:${IMAGE_TAG}
EOF
                '''
            }
        }
    }
}
