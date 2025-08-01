include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  region = basename(get_terragrunt_dir())
  region_name = "eu-west-2"
  region_description = "Europe (London)"
  
  # Region-specific configurations
  availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  
  # Region-specific pricing and limits
  pricing_tier = "standard"
  
  # Region-specific compliance and data residency
  data_residency = "EU"
  compliance_frameworks = ["GDPR", "ISO27001"]
  
  # VPC and subnet configurations for eu-west-2
  region_config = {
    vpc_cidr = "10.2.0.0/16"
    public_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
    private_subnets = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
    database_subnets = ["10.2.20.0/24", "10.2.21.0/24", "10.2.22.0/24"]
    elasticache_subnets = ["10.2.30.0/24", "10.2.31.0/24", "10.2.32.0/24"]
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  }
} 