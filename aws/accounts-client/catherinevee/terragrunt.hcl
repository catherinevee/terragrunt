# Terragrunt account-level configuration for catherinevee

remote_state {
  backend = "s3"
  config = {
    bucket         = "terragrunt-state-catherinevee-root"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terragrunt-locks-catherinevee-root"
  }
}

# Provider and Terraform version constraints
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region  = var.aws_region
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

inputs = {
  account_id   = "${get_aws_account_id()}"
  owner        = "catherinevee"
  organization = "accounts-client"
  aws_region   = "eu-west-1"
  environment  = "shared"
  tags = {
    Owner         = "catherinevee"
    Organization  = "accounts-client"
    ManagedBy     = "Terragrunt"
    Purpose       = "account-root-config"
  }
}
