pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ACCOUNT_ID = "201263439518"
        REPO_NAME  = "jenkins-lab"
        ECR_REPO   = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Get Git Commit SHA') {
            steps {
                script {
                    env.GIT_SHA = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                    echo "Git SHA: ${env.GIT_SHA}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${REPO_NAME}:${GIT_SHA} .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh """
                docker tag ${REPO_NAME}:${GIT_SHA} ${ECR_REPO}:${GIT_SHA}
                docker push ${ECR_REPO}:${GIT_SHA}

                # Optional additional tag with build number
                docker tag ${REPO_NAME}:${GIT_SHA} ${ECR_REPO}:${BUILD_NUMBER}
                docker push ${ECR_REPO}:${BUILD_NUMBER}
                """
            }
        }
    }
}
