include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = basename(dirname(get_terragrunt_dir()))
  region = basename(get_terragrunt_dir())
  
  # Region-specific settings
  region_config = {
    # Availability zones for this region
    azs = [
      "${locals.region}a",
      "${locals.region}b", 
      "${locals.region}c"
    ]
    
    # Region-specific CIDR blocks
    vpc_cidr = "10.2.0.0/16"  # Different CIDR for client-b-com prod
    
    # Subnet configuration
    public_subnets = [
      "10.2.1.0/24",
      "10.2.2.0/24",
      "10.2.3.0/24"
    ]
    
    private_subnets = [
      "10.2.10.0/24",
      "10.2.20.0/24",
      "10.2.30.0/24"
    ]
    
    database_subnets = [
      "10.2.100.0/24",
      "10.2.200.0/24",
      "10.2.300.0/24"
    ]
  }
} 