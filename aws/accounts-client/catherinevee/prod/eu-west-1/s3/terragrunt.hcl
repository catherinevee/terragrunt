# Terragrunt config for S3 bucket

terraform {
  source = "../modules//s3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_name = "catherinevee-eu-west-1-prod"
  environment = "prod"
  region      = "eu-west-1"
  project     = "catherinevee"
  costcenter  = "ITS"
  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  lifecycle_rule = [
    {
      id      = "log"
      enabled = true
      expiration = {
        days = 180
      }
      noncurrent_version_expiration = {
        days = 60
      }
      transition = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 120
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  logging = {
    target_bucket = "catherinevee-logs-eu-west-1-prod"
    target_prefix = "log/"
  }
  tags = {
    Name        = "catherinevee-eu-west-1-prod"
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
    CostCenter  = "ITS"
    Terraform   = true
  }
  # Example: add replication, website, or notification configuration if supported by the module
}
