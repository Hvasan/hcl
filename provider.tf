terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
    
    required_version = ">= 1.0.0"

}

provider "aws" {
  alias  = "default"
  access_key = ""
  secret_key = ""
  region     = "us-east-1" # Change to your desired region
}