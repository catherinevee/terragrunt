# ==============================================================================
# KMS Security Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/kms.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "KMS Security - Development"
  
  # KMS security configuration for development environment
  kms_config = {
    # General KMS settings
    enable_key_rotation = true
    deletion_window_in_days = 7  # Shorter for dev environment
    
    # Security-focused KMS keys
    keys = {
      # Global encryption key
      global_encryption = {
        description = "Global encryption key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "Global Encryption"
          Environment = "Development"
          Service = "Global"
          SecurityLevel = "High"
        }
      }
      
      # Secrets management key
      secrets_management = {
        description = "Secrets management key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "Secrets Management"
          Environment = "Development"
          Service = "SecretsManager"
          SecurityLevel = "High"
        }
      }
      
      # CloudTrail encryption key
      cloudtrail_encryption = {
        description = "CloudTrail encryption key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "CloudTrail Encryption"
          Environment = "Development"
          Service = "CloudTrail"
          SecurityLevel = "High"
        }
      }
      
      # Config encryption key
      config_encryption = {
        description = "AWS Config encryption key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "Config Encryption"
          Environment = "Development"
          Service = "Config"
          SecurityLevel = "High"
        }
      }
      
      # GuardDuty encryption key
      guardduty_encryption = {
        description = "GuardDuty encryption key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "GuardDuty Encryption"
          Environment = "Development"
          Service = "GuardDuty"
          SecurityLevel = "High"
        }
      }
      
      # Security Hub encryption key
      security_hub_encryption = {
        description = "Security Hub encryption key for Client B development environment"
        key_usage = "ENCRYPT_DECRYPT"
        customer_master_key_spec = "SYMMETRIC_DEFAULT"
        enable_key_rotation = true
        deletion_window_in_days = 7
        tags = {
          Purpose = "Security Hub Encryption"
          Environment = "Development"
          Service = "SecurityHub"
          SecurityLevel = "High"
        }
      }
    }
    
    # Key policies for security
    key_policies = {
      # Global encryption key policy
      global_encryption = {
        key_id = "global_encryption"
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
              Sid = "Allow Security Administrators"
              Effect = "Allow"
              Principal = {
                AWS = "arn:aws:iam::${include.account.locals.account_id}:role/ClientB-Dev-SecurityAdminRole"
              }
              Action = [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext"
              ]
              Resource = "*"
            },
            {
              Sid = "Allow CloudTrail"
              Effect = "Allow"
              Principal = {
                Service = "cloudtrail.amazonaws.com"
              }
              Action = [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey"
              ]
              Resource = "*"
              Condition = {
                StringEquals = {
                  "aws:SourceAccount" = include.account.locals.account_id
                }
              }
            }
          ]
        })
      }
      
      # Secrets management key policy
      secrets_management = {
        key_id = "secrets_management"
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
              Sid = "Allow Secrets Manager"
              Effect = "Allow"
              Principal = {
                Service = "secretsmanager.amazonaws.com"
              }
              Action = [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey"
              ]
              Resource = "*"
              Condition = {
                StringEquals = {
                  "aws:SourceAccount" = include.account.locals.account_id
                }
              }
            }
          ]
        })
      }
    }
    
    # Alias configurations
    aliases = {
      # Global encryption alias
      global_encryption = {
        name = "alias/client-b-dev-global-encryption"
        target_key_id = "global_encryption"
      }
      
      # Secrets management alias
      secrets_management = {
        name = "alias/client-b-dev-secrets-management"
        target_key_id = "secrets_management"
      }
      
      # CloudTrail encryption alias
      cloudtrail_encryption = {
        name = "alias/client-b-dev-cloudtrail-encryption"
        target_key_id = "cloudtrail_encryption"
      }
      
      # Config encryption alias
      config_encryption = {
        name = "alias/client-b-dev-config-encryption"
        target_key_id = "config_encryption"
      }
      
      # GuardDuty encryption alias
      guardduty_encryption = {
        name = "alias/client-b-dev-guardduty-encryption"
        target_key_id = "guardduty_encryption"
      }
      
      # Security Hub encryption alias
      security_hub_encryption = {
        name = "alias/client-b-dev-security-hub-encryption"
        target_key_id = "security_hub_encryption"
      }
    }
  }
  
  # Tags for all KMS security resources
  tags = {
    Environment = "Development"
    Project     = "Ollie Bacterianos Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    SecurityLevel = "High"
    Client      = "Ollie Bacterianos"
  }
} 