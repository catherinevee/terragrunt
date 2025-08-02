# Root Terragrunt configuration for eu-west-1 staging environment

remote_state {
  backend = "s3"
  config = {
    bucket         = "terragrunt-state-catherinevee-eu-west-1-staging"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terragrunt-locks-catherinevee-eu-west-1-staging"
  }
}

# Provider and Terraform version constraints
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region  = "eu-west-1"
  version = "~> 6.2.0"
}
terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}
EOF
}
