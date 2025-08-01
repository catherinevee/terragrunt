# ==============================================================================
# KMS Module Configuration for Client B - Development Environment (eu-west-2)
# ==============================================================================
include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/tfm-aws-kms.git//?ref=v1.0.0"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "KMS Encryption - Development (eu-west-2)"
  
  kms_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "KMS Encryption"
    create_kms_keys = true
    
    kms_keys = {
      "dev-general-key" = {
        description = "General encryption key for ClientB development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "General Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "dev-s3-key" = {
        description = "S3 encryption key for ClientB development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "S3 Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "dev-rds-key" = {
        description = "RDS encryption key for ClientB development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "RDS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "dev-elasticache-key" = {
        description = "ElastiCache encryption key for ClientB development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "ElastiCache Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "dev-cloudwatch-key" = {
        description = "CloudWatch encryption key for ClientB development environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "CloudWatch Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
    }
    
    key_aliases = {
      "dev-general-key" = {
        name = "alias/client-b-dev-general"
        target_key_id = "dev-general-key"
      }
      "dev-s3-key" = {
        name = "alias/client-b-dev-s3"
        target_key_id = "dev-s3-key"
      }
      "dev-rds-key" = {
        name = "alias/client-b-dev-rds"
        target_key_id = "dev-rds-key"
      }
      "dev-elasticache-key" = {
        name = "alias/client-b-dev-elasticache"
        target_key_id = "dev-elasticache-key"
      }
      "dev-cloudwatch-key" = {
        name = "alias/client-b-dev-cloudwatch"
        target_key_id = "dev-cloudwatch-key"
      }
    }
    
    key_policies = {
      "dev-general-key" = {
        key_id = "dev-general-key"
        policy = null  # Use default policy
      }
      "dev-s3-key" = {
        key_id = "dev-s3-key"
        policy = null  # Use default policy
      }
      "dev-rds-key" = {
        key_id = "dev-rds-key"
        policy = null  # Use default policy
      }
      "dev-elasticache-key" = {
        key_id = "dev-elasticache-key"
        policy = null  # Use default policy
      }
      "dev-cloudwatch-key" = {
        key_id = "dev-cloudwatch-key"
        policy = null  # Use default policy
      }
    }
  }
} 