pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        DOCKER_IMAGE = "ashokdocke/wiki:latest"
        DOCKER_NETWORK = "wiki-network"
        POSTGRES_CONTAINER = "wikidb"
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

        stage('Run Containers') {
            steps {
                echo "📌 Running Postgres and Wiki.js containers..."

                // Create Docker network if not exists
                sh """
                    if ! docker network inspect $DOCKER_NETWORK >/dev/null 2>&1; then
                        docker network create $DOCKER_NETWORK
                    fi
                """

                // Run Postgres container if not running
                sh """
                    if ! docker ps -q -f name=$POSTGRES_CONTAINER | grep -q .; then
                        docker run -d --name $POSTGRES_CONTAINER \\
                            -e POSTGRES_DB=wiki \\
                            -e POSTGRES_USER=wikijs \\
                            -e POSTGRES_PASSWORD=wikijsrocks \\
                            --network $DOCKER_NETWORK \\
                            -p 5432:5432 \\
                            postgres:15
                    fi
                """

                // Run Wiki.js container
                sh """
                    docker run -d --name wiki-app --network $DOCKER_NETWORK -p 3000:3000 \\
                        -v \$(pwd)/config.yml:/wiki/config.yml \\
                        $DOCKER_IMAGE
                """
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline finished."
        }
        success {
            echo "✅ Pipeline succeeded! Docker image pushed and containers running."
        }
        failure {
            echo "❌ Pipeline failed! Check the logs for errors."
        }
    }
}

