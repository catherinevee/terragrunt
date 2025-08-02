include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  environment = "prod"
  region_name = "eu-west-2"
  
  # Region-specific settings for eu-west-2
  availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  
  # VPC and subnet configurations for eu-west-2 (Production)
  region_config = {
    vpc_cidr = "10.0.0.0/16"
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
    database_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
    elasticache_subnets = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  }
  
  # Environment-specific settings for production
  data_residency = "EU"
  compliance_frameworks = ["GDPR", "ISO27001", "SOC2", "PCI-DSS"]
} 