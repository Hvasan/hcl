variable "environment" {
  description = "The environment to deploy (dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "172.32.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["172.32.0.0/18", "172.32.64.0/18"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["172.32.128.0/18", "172.32.192.0/18"]
}

variable "availability_zones" {
  description = "Availability zones for subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket name for Terraform state."
  type        = string
  default     = "terraform-state-hcl-vasan"
}

variable "terraform_state_lock_table_name" {
  description = "DynamoDB table name for state locking."
  type        = string
  default     = "terraform_state_lock_hcl-vasan"
}