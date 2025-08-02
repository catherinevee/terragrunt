# ==============================================================================
# KMS Module Configuration for Client A - Production Environment (eu-west-2)
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
  project     = "KMS Encryption - Production (eu-west-2)"
  
  # KMS configuration for production environment
  kms_config = {
    # General KMS settings (Production)
    enable_key_rotation = true
    deletion_window_in_days = 30  # Longer deletion window for production
    
    # KMS keys configuration
    keys = {
      # General encryption key
      general = {
        description = "General encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "General Encryption"
          Environment = "Production"
          Service = "General"
          Compliance = "PCI-DSS"
        }
      }
      
      # S3 encryption key
      s3 = {
        description = "S3 encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "S3 Encryption"
          Environment = "Production"
          Service = "S3"
          Compliance = "PCI-DSS"
        }
      }
      
      # RDS encryption key
      rds = {
        description = "RDS encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "RDS Encryption"
          Environment = "Production"
          Service = "RDS"
          Compliance = "PCI-DSS"
        }
      }
      
      # ElastiCache encryption key
      elasticache = {
        description = "ElastiCache encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "ElastiCache Encryption"
          Environment = "Production"
          Service = "ElastiCache"
          Compliance = "PCI-DSS"
        }
      }
      
      # CloudWatch encryption key
      cloudwatch = {
        description = "CloudWatch encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "CloudWatch Encryption"
          Environment = "Production"
          Service = "CloudWatch"
          Compliance = "PCI-DSS"
        }
      }
      
      # Application encryption key
      application = {
        description = "Application encryption key for Client A production environment (eu-west-2)"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 30
        tags = {
          Purpose = "Application Encryption"
          Environment = "Production"
          Service = "Application"
          Compliance = "PCI-DSS"
        }
      }
    }
    
    # Key policies (Production - more restrictive)
    key_policies = {
      general = {
        version = "2012-10-17"
        statement = [
          {
            sid = "Enable IAM User Permissions"
            effect = "Allow"
            principal = {
              AWS = "arn:aws:iam::${include.common.locals.account_id}:root"
            }
            action = "kms:*"
            resource = "*"
          },
          {
            sid = "Allow CloudWatch Logs"
            effect = "Allow"
            principal = {
              Service = "logs.${include.region.locals.region_name}.amazonaws.com"
            }
            action = [
              "kms:Encrypt*",
              "kms:Decrypt*",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:Describe*"
            ]
            resource = "*"
            condition = {
              test = "ArnEquals"
              variable = "kms:EncryptionContext:aws:logs:arn"
              values = ["arn:aws:logs:${include.region.locals.region_name}:${include.common.locals.account_id}:*"]
            }
          }
        ]
      }
    }
    
    # Tags for all KMS resources
    tags = {
      Environment = "Production"
      Project     = "Client A Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Confidential"
      Client      = "Client A"
      Compliance  = "PCI-DSS"
    }
  }
} 