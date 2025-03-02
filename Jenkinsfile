pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        TF_VAR_project = 'mlops-retail-demand'
    }

    stages {
        stage('Checkout Repo') {
            steps {
                git credentialsId: 'github-creds-id', 
                    url: 'https://github.com/JJGuilloryGit/mlopspipelineforretaildemand.git', 
                    branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo '✅ Skipping Terraform Apply during testing to avoid AWS charges.'
            }
        }

        stage('Run MLOps Pipeline') {
            steps {
                sh 'bash scripts/run_pipeline.sh'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

