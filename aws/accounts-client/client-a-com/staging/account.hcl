include "root" {
  path = find_in_parent_folders("root.hcl")
}
include {
  path = find_in_parent_folders("common.tcl")
}


locals {
  account_name = "dev"
  account_id   = "123456789012"
  
  # Environment-specific settings
  environment_config = {
    environment = "dev"
    project_name = "my-project"
    
    # Development-specific configurations
    backup_retention_days = 7
    monitoring_level = "basic"
    cost_allocation_tags = {
      CostCenter = "Engineering"
      Team       = "Platform"
    }
  }
}