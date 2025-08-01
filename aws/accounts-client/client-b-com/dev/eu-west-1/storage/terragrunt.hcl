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

terraform {
  source = "../../../../modules/s3"
}

# Dependencies (uncomment and configure as needed)
# dependency "kms" {
#   config_path = "../kms"
# }
# 
# dependency "iam" {
#   config_path = "../iam"
# }

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  costcenter  = "ClientB"
  project     = "Development Storage Infrastructure"
  
  buckets = {
    "client-b-dev-app-data" = {
      bucket_name = "client-b-dev-app-data-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "AES256"
      
      # Lifecycle configuration for development data
      lifecycle_rules = [
        {
          id = "dev-data-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 90  # Keep development data for 90 days
          }
          noncurrent_version_expiration = {
            noncurrent_days = 30
          }
          transitions = [
            {
              days = 30
              storage_class = "STANDARD_IA"
            },
            {
              days = 60
              storage_class = "GLACIER"
            }
          ]
        }
      ]
      
      # Public access block settings
      block_public_acls = true
      block_public_policy = true
      ignore_public_acls = true
      restrict_public_buckets = true
      
      # CORS configuration for web applications
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "PUT", "POST", "DELETE"]
          allowed_origins = ["https://*.client-b-dev.com"]
          expose_headers = ["ETag"]
          max_age_seconds = 3000
        }
      ]
      
      tags = {
        Purpose = "application-data"
        DataClassification = "internal"
        BackupRequired = "true"
      }
    }
    
    "client-b-dev-logs" = {
      bucket_name = "client-b-dev-logs-${include.account.locals.account_id}"
      bucket_acl = "log-delivery-write"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "AES256"
      
      # Lifecycle configuration for logs
      lifecycle_rules = [
        {
          id = "logs-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 365  # Keep logs for 1 year
          }
          noncurrent_version_expiration = {
            noncurrent_days = 90
          }
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
        }
      ]
      
      # Public access block settings
      block_public_acls = true
      block_public_policy = true
      ignore_public_acls = true
      restrict_public_buckets = true
      
      tags = {
        Purpose = "logs"
        DataClassification = "internal"
        RetentionPeriod = "1-year"
      }
    }
    
    "client-b-dev-backups" = {
      bucket_name = "client-b-dev-backups-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "AES256"
      
      # Lifecycle configuration for backups
      lifecycle_rules = [
        {
          id = "backups-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 730  # Keep backups for 2 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 180
          }
          transitions = [
            {
              days = 90
              storage_class = "STANDARD_IA"
            },
            {
              days = 180
              storage_class = "GLACIER"
            },
            {
              days = 365
              storage_class = "DEEP_ARCHIVE"
            }
          ]
        }
      ]
      
      # Public access block settings
      block_public_acls = true
      block_public_policy = true
      ignore_public_acls = true
      restrict_public_buckets = true
      
      # Object lock for compliance
      object_lock_configuration = {
        object_lock_enabled = "Enabled"
        rule = {
          default_retention = {
            mode = "GOVERNANCE"
            days = 30
          }
        }
      }
      
      tags = {
        Purpose = "backups"
        DataClassification = "confidential"
        BackupRequired = "true"
        Compliance = "SOX"
      }
    }
    
    "client-b-dev-static-website" = {
      bucket_name = "client-b-dev-static-website-${include.account.locals.account_id}"
      bucket_acl = "public-read"
      versioning_enabled = false
      encryption_enabled = true
      encryption_algorithm = "AES256"
      
      # Website configuration
      website_configuration = {
        index_document = "index.html"
        error_document = "error.html"
      }
      
      # Public access block settings (less restrictive for static website)
      block_public_acls = false
      block_public_policy = false
      ignore_public_acls = false
      restrict_public_buckets = false
      
      # CORS configuration for static website
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["*"]
          expose_headers = ["ETag"]
          max_age_seconds = 3000
        }
      ]
      
      tags = {
        Purpose = "static-website"
        DataClassification = "public"
        WebsiteEnabled = "true"
      }
    }
  }
} 