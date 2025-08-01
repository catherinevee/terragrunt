# ==============================================================================
# KMS Module Configuration for Client B - Production Environment
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
  project     = "KMS Encryption - Production"
  
  kms_config = {
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "KMS Encryption"
    create_kms_keys = true
    
    kms_keys = {
      "prod-general-key" = {
        description = "General encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "General Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "prod-s3-key" = {
        description = "S3 encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "S3 Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "prod-ebs-key" = {
        description = "EBS encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "EBS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "prod-rds-key" = {
        description = "RDS encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "RDS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "prod-cloudwatch-key" = {
        description = "CloudWatch encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "CloudWatch Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "prod-lambda-key" = {
        description = "Lambda encryption key for ClientB production environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "Lambda Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
    }
    
    key_aliases = {
      "prod-general-key" = {
        name = "alias/client-b-prod-general"
        target_key_id = "prod-general-key"
      }
      "prod-s3-key" = {
        name = "alias/client-b-prod-s3"
        target_key_id = "prod-s3-key"
      }
      "prod-ebs-key" = {
        name = "alias/client-b-prod-ebs"
        target_key_id = "prod-ebs-key"
      }
      "prod-rds-key" = {
        name = "alias/client-b-prod-rds"
        target_key_id = "prod-rds-key"
      }
      "prod-cloudwatch-key" = {
        name = "alias/client-b-prod-cloudwatch"
        target_key_id = "prod-cloudwatch-key"
      }
      "prod-lambda-key" = {
        name = "alias/client-b-prod-lambda"
        target_key_id = "prod-lambda-key"
      }
    }
    
    key_policies = {
      "prod-general-key" = {
        key_id = "prod-general-key"
        policy = null  # Use default policy
      }
      "prod-s3-key" = {
        key_id = "prod-s3-key"
        policy = null  # Use default policy
      }
      "prod-ebs-key" = {
        key_id = "prod-ebs-key"
        policy = null  # Use default policy
      }
      "prod-rds-key" = {
        key_id = "prod-rds-key"
        policy = null  # Use default policy
      }
      "prod-cloudwatch-key" = {
        key_id = "prod-cloudwatch-key"
        policy = null  # Use default policy
      }
      "prod-lambda-key" = {
        key_id = "prod-lambda-key"
        policy = null  # Use default policy
      }
    }
  }
} 