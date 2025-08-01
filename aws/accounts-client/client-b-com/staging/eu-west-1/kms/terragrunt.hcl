# ==============================================================================
# KMS Module Configuration for Client B - Staging Environment
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
  project     = "KMS Encryption - Staging"
  
  kms_config = {
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "KMS Encryption"
    create_kms_keys = true
    
    kms_keys = {
      "staging-general-key" = {
        description = "General encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "General Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "staging-s3-key" = {
        description = "S3 encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "S3 Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "staging-ebs-key" = {
        description = "EBS encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "EBS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "staging-rds-key" = {
        description = "RDS encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "RDS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "staging-cloudwatch-key" = {
        description = "CloudWatch encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "CloudWatch Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      "staging-lambda-key" = {
        description = "Lambda encryption key for ClientB staging environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "Lambda Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
    }
    
    key_aliases = {
      "staging-general-key" = {
        name = "alias/client-b-staging-general"
        target_key_id = "staging-general-key"
      }
      "staging-s3-key" = {
        name = "alias/client-b-staging-s3"
        target_key_id = "staging-s3-key"
      }
      "staging-ebs-key" = {
        name = "alias/client-b-staging-ebs"
        target_key_id = "staging-ebs-key"
      }
      "staging-rds-key" = {
        name = "alias/client-b-staging-rds"
        target_key_id = "staging-rds-key"
      }
      "staging-cloudwatch-key" = {
        name = "alias/client-b-staging-cloudwatch"
        target_key_id = "staging-cloudwatch-key"
      }
      "staging-lambda-key" = {
        name = "alias/client-b-staging-lambda"
        target_key_id = "staging-lambda-key"
      }
    }
    
    key_policies = {
      "staging-general-key" = {
        key_id = "staging-general-key"
        policy = null  # Use default policy
      }
      "staging-s3-key" = {
        key_id = "staging-s3-key"
        policy = null  # Use default policy
      }
      "staging-ebs-key" = {
        key_id = "staging-ebs-key"
        policy = null  # Use default policy
      }
      "staging-rds-key" = {
        key_id = "staging-rds-key"
        policy = null  # Use default policy
      }
      "staging-cloudwatch-key" = {
        key_id = "staging-cloudwatch-key"
        policy = null  # Use default policy
      }
      "staging-lambda-key" = {
        key_id = "staging-lambda-key"
        policy = null  # Use default policy
      }
    }
  }
} 