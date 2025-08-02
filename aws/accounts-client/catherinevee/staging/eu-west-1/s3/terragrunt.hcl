# Terragrunt config for S3 bucket in staging

terraform {
  source = "../../modules//s3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  bucket_name = "catherinevee-eu-west-1-staging"
  environment = "staging"
  region      = "eu-west-1"
  project     = "catherinevee"
  costcenter  = "ITS"
  versioning  = true
  lifecycle_rules = [
    {
      id      = "expire-logs"
      enabled = true
      prefix  = "logs/"
      expiration = {
        days = 30
      }
    }
  ]
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
    Purpose     = "storage"
  }
}
