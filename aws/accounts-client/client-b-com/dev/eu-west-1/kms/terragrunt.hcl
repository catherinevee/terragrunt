# ==============================================================================
# KMS Module Configuration for Client B - Development Environment
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
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "KMS Encryption - Development"
  
  # KMS specific configuration for development environment
  kms_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "KMS Encryption"
    
    # KMS keys configuration
    create_kms_keys = true
    kms_keys = {
      # General encryption key for development
      "dev-general-key" = {
        description = "General encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "General Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      # S3 encryption key
      "dev-s3-key" = {
        description = "S3 encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "S3 Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      # EBS encryption key
      "dev-ebs-key" = {
        description = "EBS encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "EBS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      # RDS encryption key
      "dev-rds-key" = {
        description = "RDS encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "RDS Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      # CloudWatch Logs encryption key
      "dev-cloudwatch-key" = {
        description = "CloudWatch Logs encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "CloudWatch Logs Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
      
      # Lambda encryption key
      "dev-lambda-key" = {
        description = "Lambda encryption key for ClientB development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "Lambda Encryption"
          Owner       = "DevOps Team"
          DataClassification = "Internal"
        }
      }
    }
    
    # Key aliases
    create_key_aliases = true
    key_aliases = {
      "alias/dev-general" = {
        target_key_id = "dev-general-key"
      }
      
      "alias/dev-s3" = {
        target_key_id = "dev-s3-key"
      }
      
      "alias/dev-ebs" = {
        target_key_id = "dev-ebs-key"
      }
      
      "alias/dev-rds" = {
        target_key_id = "dev-rds-key"
      }
      
      "alias/dev-cloudwatch" = {
        target_key_id = "dev-cloudwatch-key"
      }
      
      "alias/dev-lambda" = {
        target_key_id = "dev-lambda-key"
      }
    }
    
    # Key policies (optional - will use default if not specified)
    key_policies = {
      # Example of a custom key policy for development
      "dev-general-key" = {
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid = "Enable IAM User Permissions"
              Effect = "Allow"
              Principal = {
                AWS = "arn:aws:iam::${include.account.locals.account_id}:root"
              }
              Action = "kms:*"
              Resource = "*"
            },
            {
              Sid = "Allow CloudTrail to encrypt logs"
              Effect = "Allow"
              Principal = {
                Service = "cloudtrail.amazonaws.com"
              }
              Action = [
                "kms:Decrypt",
                "kms:GenerateDataKey"
              ]
              Resource = "*"
              Condition = {
                StringEquals = {
                  "kms:ViaService" = "cloudtrail.amazonaws.com"
                }
              }
            }
          ]
        })
      }
    }
  }
} 