pipeline {
    agent any
    
    tools {
        terraform 'terraform'
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        TF_VAR_project = 'mlops-retail-demand'
        SAGEMAKER_ROLE = credentials('sagemaker-role-arn')
    }

    stages {
        stage('Verify Terraform') {
            steps {
                sh 'terraform version'
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
                    sh '''
                    terraform plan \
                      -var="sagemaker_role_arn=${SAGEMAKER_ROLE}" \
                      -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo '✅ Skipping Terraform Apply during testing to avoid AWS charges.'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}



