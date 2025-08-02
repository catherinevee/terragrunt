# ==============================================================================
# KMS Module Configuration for Client A - Development Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/kms.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "KMS Encryption - Development (eu-west-2)"
  
  # KMS configuration for development environment
  kms_config = {
    # General KMS settings
    enable_key_rotation = true
    deletion_window_in_days = 7  # Shorter for dev environment
    
    # KMS keys configuration
    keys = {
      # General encryption key
      general = {
        description = "General encryption key for Client A development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "General Encryption"
          Environment = "Development"
          Service = "General"
        }
      }
      
      # S3 encryption key
      s3 = {
        description = "S3 encryption key for Client A development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "S3 Encryption"
          Environment = "Development"
          Service = "S3"
        }
      }
      
      # RDS encryption key
      rds = {
        description = "RDS encryption key for Client A development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "RDS Encryption"
          Environment = "Development"
          Service = "RDS"
        }
      }
      
      # ElastiCache encryption key
      elasticache = {
        description = "ElastiCache encryption key for Client A development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "ElastiCache Encryption"
          Environment = "Development"
          Service = "ElastiCache"
        }
      }
      
      # CloudWatch encryption key
      cloudwatch = {
        description = "CloudWatch encryption key for Client A development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "CloudWatch Encryption"
          Environment = "Development"
          Service = "CloudWatch"
        }
      }
    }
    
    # Key policies (optional - will use default if not specified)
    key_policies = {}
    
    # Tags for all KMS resources
    tags = {
      Environment = "Development"
      Project     = "Client A Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Internal"
      Client      = "Client A"
    }
  }
} 