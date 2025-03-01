# -----------------------------------------------
# 1. PROVIDER SETUP/S3 Backend
# -----------------------------------------------
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "awsaibucket1"
    key            = "mlops/main.tfstate"
    region         = "us-east-1"
    profile        = "jjguilloryuser1"
    encrypt        = true
  }
}

# -----------------------------------------------
# 2. VPC & SUBNETS FOR RDS AND EKS
# -----------------------------------------------
resource "aws_vpc" "ml_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ml-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ml_igw" {
  vpc_id = aws_vpc.ml_vpc.id

  tags = {
    Name = "ml-igw"
  }
}

# Subnets in different AZs
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.ml_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  map_public_ip_on_launch = true

  tags = {
    Name = "ml-subnet-1"
    "kubernetes.io/cluster/ml-cluster" = "shared"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.ml_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  
  map_public_ip_on_launch = true

  tags = {
    Name = "ml-subnet-2"
    "kubernetes.io/cluster/ml-cluster" = "shared"
  }
}

# Route Table
resource "aws_route_table" "ml_rt" {
  vpc_id = aws_vpc.ml_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ml_igw.id
  }

  tags = {
    Name = "ml-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "rta_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.ml_rt.id
}

resource "aws_route_table_association" "rta_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.ml_rt.id
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.ml_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# -----------------------------------------------
# 3. RDS DATABASE FOR CLICKSTREAM DATA
# -----------------------------------------------
resource "aws_db_subnet_group" "ml_subnet_group" {
  name       = "ml-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "ML DB subnet group"
  }
}

resource "aws_db_instance" "ml_rds" {
  allocated_storage      = 20
  engine                = "postgres"
  engine_version        = "12"
  instance_class        = "db.t3.micro"
  db_name               = "clickstreamdb"
  username              = "mlopsadmin"
  password              = "securepassword123"
  parameter_group_name  = "default.postgres12"
  publicly_accessible   = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.ml_subnet_group.name
  skip_final_snapshot   = true
}

# -----------------------------------------------
# 4. EKS CLUSTER FOR MODEL DEPLOYMENT
# -----------------------------------------------
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role-3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_eks_cluster" "ml_eks" {
  name     = "ml-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}

# -----------------------------------------------
# 5. OUTPUTS
# -----------------------------------------------
output "rds_endpoint" {
  value = aws_db_instance.ml_rds.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.ml_eks.name
}
