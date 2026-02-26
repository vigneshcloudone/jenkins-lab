pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ACCOUNT_ID = "201263439518"
        REPO_NAME  = "jenkins-lab"
        CLUSTER    = "jenkins-ecs-cluster"
        SERVICE    = "jenkins-task-service"
        TASK_FAMILY = "jenkins-task"

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
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${REPO_NAME}:${GIT_SHA} ."
            }
        }

        stage('Test Container') {
            steps {
                sh """
                docker run -d -p 8081:80 --name test ${REPO_NAME}:${GIT_SHA}
                sleep 5
                curl -f http://localhost:8081 || exit 1
                docker stop test && docker rm test
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

        stage('Push Image') {
            steps {
                sh """
                docker tag ${REPO_NAME}:${GIT_SHA} ${ECR_REPO}:${GIT_SHA}
                docker push ${ECR_REPO}:${GIT_SHA}
                """
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh """
                echo "Fetching current task definition..."

                aws ecs describe-task-definition \
                --task-definition ${TASK_FAMILY} \
                --query taskDefinition > task-def.json

                echo "Updating image..."

                cat task-def.json | jq --arg IMAGE "${ECR_REPO}:${GIT_SHA}" \
                '.containerDefinitions[0].image=$IMAGE |
                 del(.taskDefinitionArn,.revision,.status,.requiresAttributes,.compatibilities,.registeredAt,.registeredBy)' \
                > new-task-def.json

                echo "Registering new revision..."

                aws ecs register-task-definition \
                --cli-input-json file://new-task-def.json

                echo "Updating ECS service..."

                aws ecs update-service \
                --cluster ${CLUSTER} \
                --service ${SERVICE} \
                --force-new-deployment
                """
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker system prune -f"
            }
        }
    }
}
