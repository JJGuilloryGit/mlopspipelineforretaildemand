pipeline {
    agent any
    
    tools {
        terraform 'terraform'
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Pipeline Start') {
            steps {
                echo "Starting Pipeline Test Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
            }
        }

        stage('Test Stage 1') {
            steps {
                script {
                    try {
                        sh 'echo "Test Stage 1"'
                        echo "Stage 1 completed successfully"
                    } catch (Exception e) {
                        echo "Stage 1 failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }

        stage('Test Stage 2') {
            steps {
                script {
                    try {
                        sh 'echo "Doing some work..."'
                        echo "Stage 2 completed successfully"
                    } catch (Exception e) {
                        echo "Stage 2 failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Pipeline test completed successfully '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
        }
        failure {
            echo "FAILED: Pipeline test failed '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
        }
        always {
            cleanWs()
        }
    }
}





