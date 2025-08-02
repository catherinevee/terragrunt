include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  environment = "dev"
  region_name = "eu-west-2"
  
  # Region-specific settings for eu-west-2
  availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  
  # VPC and subnet configurations for eu-west-2
  region_config = {
    vpc_cidr = "10.1.0.0/16"
    public_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
    database_subnets = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
    elasticache_subnets = ["10.1.30.0/24", "10.1.31.0/24", "10.1.32.0/24"]
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  }
  
  # Environment-specific settings for development
  data_residency = "EU"
  compliance_frameworks = ["GDPR", "ISO27001"]
}

