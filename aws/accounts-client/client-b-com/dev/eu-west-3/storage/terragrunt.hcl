# ==============================================================================
# Storage Module Configuration for Client B - Development Environment (eu-west-3)
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

# Dependencies
dependency "kms" {
  config_path = "../kms"
}

dependency "iam" {
  config_path = "../iam"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/storage.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Storage Resources - Development"
  
  # KMS key reference for encryption
  kms_key_id = dependency.kms.outputs.s3_kms_key_id
  
  # Storage configuration for development environment
  storage_config = {
    # S3 buckets configuration
    s3_buckets = {
      # Application data bucket
      app_data = {
        bucket_name = "client-b-dev-app-data-${include.account.locals.account_id}"
        versioning_enabled = true
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.s3_kms_key_id
        lifecycle_rules = [
          {
            id = "app-data-lifecycle"
            status = "Enabled"
            transitions = [
              {
                days = 30
                storage_class = "STANDARD_IA"
              },
              {
                days = 90
                storage_class = "GLACIER"
              }
            ]
            expiration = {
              days = 365
            }
          }
        ]
        tags = {
          Name = "client-b-dev-app-data"
          Purpose = "Application Data Storage"
          Environment = "Development"
          DataClass = "Internal"
        }
      }
      
      # Backup bucket
      backups = {
        bucket_name = "client-b-dev-backups-${include.account.locals.account_id}"
        versioning_enabled = true
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.s3_kms_key_id
        lifecycle_rules = [
          {
            id = "backup-lifecycle"
            status = "Enabled"
            transitions = [
              {
                days = 7
                storage_class = "STANDARD_IA"
              },
              {
                days = 30
                storage_class = "GLACIER"
              },
              {
                days = 90
                storage_class = "DEEP_ARCHIVE"
              }
            ]
            expiration = {
              days = 2555  # 7 years
            }
          }
        ]
        tags = {
          Name = "client-b-dev-backups"
          Purpose = "Backup Storage"
          Environment = "Development"
          DataClass = "Backup"
        }
      }
      
      # Logs bucket
      logs = {
        bucket_name = "client-b-dev-logs-${include.account.locals.account_id}"
        versioning_enabled = true
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.s3_kms_key_id
        lifecycle_rules = [
          {
            id = "logs-lifecycle"
            status = "Enabled"
            transitions = [
              {
                days = 7
                storage_class = "STANDARD_IA"
              },
              {
                days = 30
                storage_class = "GLACIER"
              }
            ]
            expiration = {
              days = 90
            }
          }
        ]
        tags = {
          Name = "client-b-dev-logs"
          Purpose = "Log Storage"
          Environment = "Development"
          DataClass = "Logs"
        }
      }
      
      # Static website bucket
      static_website = {
        bucket_name = "client-b-dev-static-website-${include.account.locals.account_id}"
        versioning_enabled = false
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.s3_kms_key_id
        website_configuration = {
          index_document = "index.html"
          error_document = "error.html"
        }
        tags = {
          Name = "client-b-dev-static-website"
          Purpose = "Static Website Hosting"
          Environment = "Development"
          DataClass = "Public"
        }
      }
    }
    
    # EBS volumes configuration (if needed)
    ebs_volumes = {}
    
    # EFS file systems configuration (if needed)
    efs_file_systems = {}
  }
  
  # Tags for all storage resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
  }
} 