pipeline {
    agent any

    environment {
        // DockerHub credentials stored in Jenkins (ID = dockerhub-cred)
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')

        // Your Docker image name (change if needed)
        DOCKER_IMAGE = "ashokdocke/wiki:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Checking out source code from GitHub..."
                git branch: 'main', url: 'https://github.com/ashokckumar/wiki.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "📦 Installing Node.js dependencies..."
                // Use --legacy-peer-deps to bypass dependency version conflicts
                sh 'npm install --legacy-peer-deps'
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Running tests (skipped for Wiki.js demo)..."
                sh 'echo "Skipping tests for Wiki.js project"'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh "docker build -t $DOCKER_IMAGE ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Pushing Docker image to Docker Hub..."
                sh """
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push $DOCKER_IMAGE
                """
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline finished."
        }
        success {
            echo "✅ Pipeline succeeded! Docker image pushed to Docker Hub."
        }
        failure {
            echo "❌ Pipeline failed! Check the Jenkins logs for errors."
        }
    }
}

