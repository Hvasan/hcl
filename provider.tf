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
  access_key = "AKIAX3NVJFI7A2EGPR7J"
  secret_key = "WWwV9V+v0L3WmG5/J2UQMbt6y8OUxBUWZ4JRCtDo"
  region     = "us-east-1" # Change to your desired region
}