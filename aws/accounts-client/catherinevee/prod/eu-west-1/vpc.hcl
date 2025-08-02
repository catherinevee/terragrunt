# Terragrunt configuration for a complete AWS environment in eu-west-1

terraform {
  source = "../modules//vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project     = "catherinevee"
  environment = "prod"
  region      = "eu-west-1"
  costcenter  = "ITS"
  cidr_block  = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  instance_tenancy = "default"
  enable_network_address_usage_metrics = true
  tags = {
    Name        = "vpc-catherinevee-prod-eu-west-1"
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
    CostCenter  = "ITS"
    Terraform   = true
  }
  # Example: add custom DHCP options, flow logs, or additional VPC features here if supported by the module
}
