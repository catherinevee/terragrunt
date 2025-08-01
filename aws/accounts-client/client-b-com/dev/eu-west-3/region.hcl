include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = basename(dirname(get_terragrunt_dir()))
  region = basename(get_terragrunt_dir())
  
  # Region-specific settings for eu-west-3
  region_config = {
    # Availability zones for this region
    azs = [
      "${locals.region}a",
      "${locals.region}b", 
      "${locals.region}c"
    ]
    
    # Region-specific CIDR blocks
    vpc_cidr = "10.3.0.0/16"  # Different CIDR for client-b-com dev eu-west-3
    
    # Subnet configuration
    public_subnets = [
      "10.3.1.0/24",
      "10.3.2.0/24",
      "10.3.3.0/24"
    ]
    
    private_subnets = [
      "10.3.10.0/24",
      "10.3.20.0/24",
      "10.3.30.0/24"
    ]
    
    database_subnets = [
      "10.3.100.0/24",
      "10.3.200.0/24",
      "10.3.300.0/24"
    ]
    
    elasticache_subnets = [
      "10.3.110.0/24",
      "10.3.210.0/24",
      "10.3.310.0/24"
    ]
  }
  
  # Environment-specific settings for development
  data_residency = "EU"
  compliance_frameworks = ["GDPR", "ISO27001"]
} 