
terraform {
  backend "s3" {
    bucket = "awsaibucket1"
    key    = "mlops/terraform.tfstate"
    region = "us-east-1"
  }
}
