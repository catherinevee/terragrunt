include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "tfr://terraform-aws-modules/s3-bucket/aws//?version=4.1.2"
}

inputs = {
  bucket = "cyprus-accounts-client-${local.account_vars.locals.aws_account_id}"
  
  # Versioning
  versioning = {
    enabled = true
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
      enabled = true
      
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
  }
} 