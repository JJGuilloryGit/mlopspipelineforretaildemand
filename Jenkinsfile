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
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform destroy \
                      -var="sagemaker_role_arn=${SAGEMAKER_ROLE}" \
                      -auto-approve
                    '''
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



