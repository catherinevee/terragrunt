# Terragrunt configuration for VPC in staging

terraform {
  source = "../../modules//vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project     = "catherinevee"
  environment = "staging"
  region      = "eu-west-1"
  costcenter  = "ITS"
  cidr_block  = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
    Purpose     = "network"
  }
}
