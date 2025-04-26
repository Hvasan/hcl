terraform {
  backend "s3" {
    bucket         = "terraform-state-hcl-vasan"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_lock_hcl-vasan"
    encrypt        = true
  }
}