pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
        DOCKER_IMAGE = "ashokdocke/wiki:latest"
        DOCKER_NETWORK = "wiki-network"
        POSTGRES_CONTAINER = "wikidb"
        WIKI_CONTAINER = "wiki-app"
        HOST_PORT = "3000"       // Change if port is in use
        CONTAINER_PORT = "3000"
        WORKDIR = "${WORKSPACE}/wiki-ci-cd"
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

        stage('Prepare config.yml & assets') {
            steps {
                echo "⚙️ Preparing config.yml and assets..."
                sh """
                    # Ensure Jenkins has write permission
                    mkdir -p $WORKDIR
                    chmod -R 777 $WORKDIR

                    # Create config.yml
                    cat > $WORKDIR/config.yml <<EOL
db:
  type: postgres
  host: $POSTGRES_CONTAINER
  port: 5432
  user: wikijs
  pass: wikijsrocks
  db: wiki
server:
  host: 0.0.0.0
  port: $CONTAINER_PORT
auth:
  local:
    enabled: true
    username: admin
    password: Admin123!
    email: admin@example.com
EOL

                    # Ensure assets folder & favicon
                    mkdir -p $WORKDIR/assets
                    if [ ! -f $WORKDIR/assets/favicon.ico ]; then
                        touch $WORKDIR/assets/favicon.ico
                    fi
                """
                echo "✅ config.yml and assets prepared"
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Skipping tests for Wiki.js project"
                sh 'echo "Tests skipped"'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh "docker build -t $DOCKER_IMAGE $WORKDIR"
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

                // Create Docker network if missing
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

                // Remove old Wiki.js container if exists
                sh """
                    if docker ps -a -q -f name=$WIKI_CONTAINER | grep -q .; then
                        docker rm -f $WIKI_CONTAINER
                    fi
                """

                // Run Wiki.js container
                sh """
                    docker run -d --name $WIKI_CONTAINER --network $DOCKER_NETWORK -p $HOST_PORT:$CONTAINER_PORT \\
                        -v $WORKDIR/config.yml:/wiki/config.yml:ro \\
                        -v $WORKDIR/assets:/wiki/assets:ro \\
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
            echo "❌ Pipeline failed! Check logs for errors."
        }
    }
}

