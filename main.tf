resource "aws_vpc" "vpc_vasan" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-main-vpc"
  }
}

resource "aws_subnet" "public_vasan" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc_vasan.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]
  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_vasan" {
  count             = 2
  vpc_id            = aws_vpc.vpc_vasan.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "${var.environment}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = ["eks.amazonaws.com", "ec2.amazonaws.com"]
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-eks-role"
  }
}

resource "aws_security_group" "eks_sg" {
  name        = "${var.environment}-eks-sg"
  description = "Security group for EKS"
  vpc_id      = aws_vpc.vpc_vasan.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.environment}-eks-sg"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "${var.environment}-terraform-state-bucket"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      bucket
    ]
  }
}

resource "null_resource" "skip_s3_creation" {
  provisioner "local-exec" {
    command = "echo 'S3 bucket already exists, skipping creation.'"
  }

  triggers = {
    bucket_exists = "true"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.terraform_state_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.environment}-terraform-state-lock-table"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public_vasan[*].id,
      aws_subnet.private_vasan[*].id
    )
    security_group_ids = [aws_security_group.eks_sg.id]
  }

  tags = {
    Name = "${var.environment}-eks-cluster"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.environment}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = aws_subnet.private_vasan[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      node_group_name,
      scaling_config
    ]
  }

  tags = {
    Name = "${var.environment}-eks-node-group"
  }
}

resource "aws_ecr_repository" "app_repository" {
  name = "${var.environment}-app-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-app-repo"
  }
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc_vasan.id
}