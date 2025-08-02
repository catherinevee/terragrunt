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
}
