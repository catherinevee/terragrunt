include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "common" {
  path= find_in_parent_folders("common.hcl")
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
    vpc_cidr = "10.0.0.0/16"
    
    # Subnet configuration
    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]
    
    private_subnets = [
      "10.0.10.0/24",
      "10.0.20.0/24",
      "10.0.30.0/24"
    ]
    
    database_subnets = [
      "10.0.100.0/24",
      "10.0.200.0/24",
      "10.0.300.0/24"
    ]

}


