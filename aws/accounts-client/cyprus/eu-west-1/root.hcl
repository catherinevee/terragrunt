locals {
  # Parse account and region from the directory structure
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Extract common variables
  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
  aws_account_role = local.account_vars.locals.aws_account_role
  environment    = local.account_vars.locals.environment
  project        = local.account_vars.locals.project
  company        = local.account_vars.locals.company
  
  # Validation
  validate_environment = contains(["dev", "staging", "prod", "cyprus"], local.environment) ? null : file("ERROR: environment must be one of: dev, staging, prod, cyprus")
}

# Remote state configuration with encryption
remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.company}-terragrunt-state-${local.aws_account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terragrunt-locks"
    s3_bucket_tags = {
      Environment = local.environment
      Project     = local.project
      ManagedBy   = "Terragrunt"
      Purpose     = "terraform-state"
    }
    dynamodb_table_tags = {
      Environment = local.environment
      Project     = local.project
      ManagedBy   = "Terragrunt"
      Purpose     = "terraform-locks"
    }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate AWS provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  
  assume_role {
    role_arn = "${local.aws_account_role}"
  }
  
  default_tags {
    tags = {
      Environment = "${local.environment}"
      Project     = "${local.project}"
      Company     = "${local.company}"
      ManagedBy   = "Terragrunt"
      Terraform   = "true"
      Owner       = "infrastructure-team"
    }
  }
}
EOF
}

# Global inputs with validation
inputs = {
  aws_region     = local.aws_region
  aws_account_id = local.aws_account_id
  environment    = local.environment
  project        = local.project
  company        = local.company
  
  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = local.project
    Company     = local.company
    ManagedBy   = "Terragrunt"
    Terraform   = "true"
    Owner       = "infrastructure-team"
  }
  
  # Performance optimizations
  terraform_parallelism = 10
  terraform_log_level   = "INFO"
} 