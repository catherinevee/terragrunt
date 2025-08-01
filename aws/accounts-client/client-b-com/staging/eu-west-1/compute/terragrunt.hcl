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
  project     = "Staging Compute Infrastructure"
  
  instances = {
    "web-server-staging-1" = {
      name                        = "web-server-staging-1"
      instance_type              = "t3.small"  # Medium instance for staging
      key_name                   = "client-b-staging-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-staging-web-12345678"]  # Replace with actual security group ID
      subnet_id                  = "subnet-staging-web-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = true
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "web-server-staging-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "web-server"
        Tier = "frontend"
        Environment = "staging"
      }
    }
    
    "web-server-staging-2" = {
      name                        = "web-server-staging-2"
      instance_type              = "t3.small"  # Medium instance for staging
      key_name                   = "client-b-staging-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-staging-web-12345678"]  # Replace with actual security group ID
      subnet_id                  = "subnet-staging-web-87654321"  # Replace with actual subnet ID
      associate_public_ip_address = true
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "web-server-staging-2"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "web-server"
        Tier = "frontend"
        Environment = "staging"
      }
    }
    
    "app-server-staging-1" = {
      name                        = "app-server-staging-1"
      instance_type              = "t3.medium"  # Medium instance for staging
      key_name                   = "client-b-staging-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-staging-app-87654321"]  # Replace with actual security group ID
      subnet_id                  = "subnet-staging-app-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "app-server-staging-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "app-server"
        Tier = "backend"
        Environment = "staging"
      }
    }
    
    "app-server-staging-2" = {
      name                        = "app-server-staging-2"
      instance_type              = "t3.medium"  # Medium instance for staging
      key_name                   = "client-b-staging-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-staging-app-87654321"]  # Replace with actual security group ID
      subnet_id                  = "subnet-staging-app-87654321"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "app-server-staging-2"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "app-server"
        Tier = "backend"
        Environment = "staging"
      }
    }
    
    "db-server-staging-1" = {
      name                        = "db-server-staging-1"
      instance_type              = "t3.large"  # Large instance for staging database
      key_name                   = "client-b-staging-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-staging-db-11223344"]  # Replace with actual security group ID
      subnet_id                  = "subnet-staging-db-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "db-server-staging-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "database-server"
        Tier = "database"
        Environment = "staging"
      }
    }
  }
} 