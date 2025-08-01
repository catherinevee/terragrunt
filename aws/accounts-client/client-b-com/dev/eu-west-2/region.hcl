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
} 