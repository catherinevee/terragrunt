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

# Dependencies
dependency "kms" {
  config_path = "../kms"
}

dependency "iam" {
  config_path = "../iam"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  costcenter  = "ClientB"
  project     = "Production Storage Infrastructure"
  
  buckets = {
    "client-b-prod-app-data" = {
      bucket_name = "client-b-prod-app-data-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
      # Lifecycle configuration for production data
      lifecycle_rules = [
        {
          id = "prod-data-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 2555  # Keep production data for 7 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 365
          }
          transitions = [
            {
              days = 30
              storage_class = "STANDARD_IA"
            },
            {
              days = 90
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
      
      # CORS configuration for web applications
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "PUT", "POST", "DELETE"]
          allowed_origins = ["https://*.client-b-prod.com"]
          expose_headers = ["ETag"]
          max_age_seconds = 3000
        }
      ]
      
      tags = {
        Purpose = "application-data"
        DataClassification = "internal"
        BackupRequired = "true"
        Compliance = "SOX"
      }
    }
    
    "client-b-prod-logs" = {
      bucket_name = "client-b-prod-logs-${include.account.locals.account_id}"
      bucket_acl = "log-delivery-write"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
      # Lifecycle configuration for logs
      lifecycle_rules = [
        {
          id = "prod-logs-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 2555  # Keep logs for 7 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 365
          }
          transitions = [
            {
              days = 30
              storage_class = "STANDARD_IA"
            },
            {
              days = 90
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
      
      tags = {
        Purpose = "logs"
        DataClassification = "internal"
        RetentionPeriod = "7-years"
        Compliance = "SOX"
      }
    }
    
    "client-b-prod-backups" = {
      bucket_name = "client-b-prod-backups-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
      # Lifecycle configuration for backups
      lifecycle_rules = [
        {
          id = "prod-backups-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 3650  # Keep backups for 10 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 730
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
            mode = "COMPLIANCE"
            years = 7
          }
        }
      }
      
      tags = {
        Purpose = "backups"
        DataClassification = "confidential"
        BackupRequired = "true"
        Compliance = "SOX"
        RetentionPeriod = "10-years"
      }
    }
    
    "client-b-prod-static-website" = {
      bucket_name = "client-b-prod-static-website-${include.account.locals.account_id}"
      bucket_acl = "public-read"
      versioning_enabled = false
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
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
    
    "client-b-prod-archives" = {
      bucket_name = "client-b-prod-archives-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
      # Lifecycle configuration for archives
      lifecycle_rules = [
        {
          id = "prod-archives-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 3650  # Keep archives for 10 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 1095
          }
          transitions = [
            {
              days = 30
              storage_class = "STANDARD_IA"
            },
            {
              days = 90
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
            mode = "COMPLIANCE"
            years = 7
          }
        }
      }
      
      tags = {
        Purpose = "archives"
        DataClassification = "confidential"
        BackupRequired = "true"
        Compliance = "SOX"
        RetentionPeriod = "10-years"
      }
    }
    
    "client-b-prod-disaster-recovery" = {
      bucket_name = "client-b-prod-disaster-recovery-${include.account.locals.account_id}"
      bucket_acl = "private"
      versioning_enabled = true
      encryption_enabled = true
      encryption_algorithm = "aws:kms"
      kms_key_id = dependency.kms.outputs.key_arns["prod-s3-key"]
      
      # Lifecycle configuration for disaster recovery
      lifecycle_rules = [
        {
          id = "prod-dr-lifecycle"
          status = "Enabled"
          enabled = true
          expiration = {
            days = 7300  # Keep DR data for 20 years
          }
          noncurrent_version_expiration = {
            noncurrent_days = 1825
          }
          transitions = [
            {
              days = 90
              storage_class = "STANDARD_IA"
            },
            {
              days = 365
              storage_class = "GLACIER"
            },
            {
              days = 1095
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
            mode = "COMPLIANCE"
            years = 20
          }
        }
      }
      
      tags = {
        Purpose = "disaster-recovery"
        DataClassification = "confidential"
        BackupRequired = "true"
        Compliance = "SOX"
        RetentionPeriod = "20-years"
        Criticality = "high"
      }
    }
  }
} 