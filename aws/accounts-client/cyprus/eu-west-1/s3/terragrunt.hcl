include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  s3_config    = local.account_vars.locals.s3_config
  
  # Input validation for S3 module
  validate_bucket_name = length(local.s3_config.bucket_name) >= 3 && length(local.s3_config.bucket_name) <= 63 ? null : file("ERROR: S3 bucket name must be between 3 and 63 characters")
  validate_bucket_name_format = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", local.s3_config.bucket_name)) ? null : file("ERROR: S3 bucket name must be valid (lowercase, alphanumeric, hyphens)")
  validate_bucket_name_no_double_hyphen = !can(regex("--", local.s3_config.bucket_name)) ? null : file("ERROR: S3 bucket name cannot contain consecutive hyphens")
  validate_bucket_name_no_ip = !can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", local.s3_config.bucket_name)) ? null : file("ERROR: S3 bucket name cannot be formatted as an IP address")
  validate_bucket_name_no_prefix = !can(regex("^xn--", local.s3_config.bucket_name)) ? null : file("ERROR: S3 bucket name cannot start with 'xn--'")
  validate_bucket_name_no_suffix = !can(regex("-s3alias$", local.s3_config.bucket_name)) ? null : file("ERROR: S3 bucket name cannot end with '-s3alias'")
}

terraform {
  source = "tfr://terraform-aws-modules/s3-bucket/aws//?version=4.1.2"
}

inputs = {
  bucket = local.s3_config.bucket_name
  
  # Versioning
  versioning = {
    enabled = local.s3_config.versioning_enabled
  }
  
  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  
  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  # Lifecycle rules
  lifecycle_rule = [
    {
      id      = "backup"
      enabled = local.s3_config.lifecycle_enabled
      
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  ]
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "data-storage"
  }
} 