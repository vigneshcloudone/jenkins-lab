pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t webapp:1 .'
            }
        }
    }
}
