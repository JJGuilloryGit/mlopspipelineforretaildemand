
provider "aws" {
  region = "us-east-1"
}

resource "aws_sagemaker_notebook_instance" "mlops_notebook" {
  name          = "mlops-notebook"
  instance_type = "ml.t2.medium"
  role_arn      = var.sagemaker_role_arn
}
