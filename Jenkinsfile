pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t webapp:1 .'
            }
        }

        stage('Tag Image for ECR') {
            steps {
                sh '''
                  docker tag webapp:1 \
                  201263439518.dkr.ecr.ap-south-1.amazonaws.com/jenkins-lab:1
                '''
            }
        }
    }
}
