pipeline {
    agent any

    environment {
        AWS_REGION  = "ap-south-1"
        ACCOUNT_ID  = "201263439518"
        REPO_NAME   = "jenkins-lab"

        CLUSTER     = "jenkins-cluster"
        SERVICE     = "jenkins-task-service"
        TASK_FAMILY = "jenkins-task"
        CONTAINER_NAME = "jenkins-container"

        ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Get Git SHA') {
            steps {
                script {
                    env.GIT_SHA = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${REPO_NAME}:${GIT_SHA} ."
            }
        }

        stage('Test Container') {
            steps {
                sh """
                    docker rm -f test || true
                    docker run -d -p 8081:80 --name test ${REPO_NAME}:${GIT_SHA}
                    sleep 5
                    curl -f http://localhost:8081
                    docker rm -f test
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
                sh '''
                    set -e

                    IMAGE=${ECR_REPO}:${GIT_SHA}
                    echo "Deploying image: $IMAGE"

                    # Get current task definition
                    aws ecs describe-task-definition \
                        --task-definition ${TASK_FAMILY} \
                        --query taskDefinition \
                        > task-def.json

                    # Create new task definition revision
                    jq --arg IMAGE "$IMAGE" --arg NAME "${CONTAINER_NAME}" '
                    {
                        family: .family,
                        executionRoleArn: .executionRoleArn,
                        taskRoleArn: .taskRoleArn,
                        networkMode: .networkMode,
                        containerDefinitions: (.containerDefinitions | map(
                            if .name == $NAME
                            then .image = $IMAGE
                            else .
                            end
                        )),
                        requiresCompatibilities: .requiresCompatibilities,
                        cpu: .cpu,
                        memory: .memory
                    }' task-def.json > new-task-def.json

                    # Register new revision
                    NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
                        --cli-input-json file://new-task-def.json \
                        --query 'taskDefinition.taskDefinitionArn' \
                        --output text)

                    echo "New Task Definition ARN: $NEW_TASK_DEF_ARN"

                    # Update service with new revision
                    aws ecs update-service \
                        --cluster ${CLUSTER} \
                        --service ${SERVICE} \
                        --task-definition $NEW_TASK_DEF_ARN

                    # Wait for deployment to complete
                    echo "Waiting for service to stabilize..."
                    aws ecs wait services-stable \
                        --cluster ${CLUSTER} \
                        --services ${SERVICE}

                    echo "Deployment successful!"
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker system prune -af"
            }
        }
    }
}
