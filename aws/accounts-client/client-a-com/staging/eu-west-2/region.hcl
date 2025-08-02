include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  environment = "staging"
  region_name = "eu-west-2"
  
  # Region-specific settings for eu-west-2
  availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  
  # VPC and subnet configurations for eu-west-2 (Staging)
  region_config = {
    vpc_cidr = "10.2.0.0/16"
    public_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
    private_subnets = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
    database_subnets = ["10.2.20.0/24", "10.2.21.0/24", "10.2.22.0/24"]
    elasticache_subnets = ["10.2.30.0/24", "10.2.31.0/24", "10.2.32.0/24"]
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  }
  
  # Environment-specific settings for staging
  data_residency = "EU"
  compliance_frameworks = ["GDPR", "ISO27001", "SOC2"]
} 