include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
}

terraform {
  source = "../../../../modules/ec2"
}

# Dependencies (uncomment and configure as needed)
# dependency "vpc" {
#   config_path = "../vpc"
# }
# 
# dependency "security_groups" {
#   config_path = "../security-groups"
# }

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  costcenter  = "ClientB"
  project     = "Compute Infrastructure"
  
  instances = {
    "web-server-1" = {
      name                        = "web-server-1"
      instance_type              = "t3.micro"
      key_name                   = "client-b-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-12345678"]  # Replace with actual security group ID
      subnet_id                  = "subnet-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = true
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "web-server-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "web-server"
        Tier = "frontend"
      }
    }
    
    "app-server-1" = {
      name                        = "app-server-1"
      instance_type              = "t3.small"
      key_name                   = "client-b-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-87654321"]  # Replace with actual security group ID
      subnet_id                  = "subnet-87654321"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "app-server-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "app-server"
        Tier = "backend"
      }
    }
  }
} 