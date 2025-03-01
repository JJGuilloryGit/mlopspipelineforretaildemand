pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'retail-demand-model'
        DOCKER_TAG = "${BUILD_NUMBER}"
        AWS_DEFAULT_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'ml-cluster'
        DB_HOST = credentials('DB_HOST')
        DB_NAME = 'clickstreamdb'
        DB_USER = credentials('DB_USER')
        DB_PASSWORD = credentials('DB_PASSWORD')
    }

    stages {
        stage('Code Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python -m pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    python -m pytest tests/test_model.py -v
                '''
            }
        }

        stage('Train Model') {
            steps {
                sh '''
                    mkdir -p models
                    python src/train.py \
                        --db-host=$DB_HOST \
                        --db-name=$DB_NAME \
                        --db-user=$DB_USER \
                        --db-password=$DB_PASSWORD
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'models/*.pkl', fingerprint: true
                }
            }
        }

        stage('Validate Model') {
            steps {
                sh '''
                    python src/validate.py \
                        --model-path models/model.pkl \
                        --threshold 0.5
                '''
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Build Docker image
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_DEFAULT_REGION}
                        
                        # Update deployment yaml with new image
                        sed -i "s|image:.*|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}|" k8s/deployment.yaml
                        
                        # Apply kubernetes manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
