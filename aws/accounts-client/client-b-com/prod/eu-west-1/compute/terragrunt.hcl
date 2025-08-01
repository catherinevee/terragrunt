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
  project     = "Production Compute Infrastructure"
  
  instances = {
    "web-server-prod-1" = {
      name                        = "web-server-prod-1"
      instance_type              = "t3.medium"  # Larger instance for production
      key_name                   = "client-b-prod-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-prod-web-12345678"]  # Replace with actual security group ID
      subnet_id                  = "subnet-prod-web-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = true
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "web-server-prod-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "web-server"
        Tier = "frontend"
        Environment = "production"
      }
    }
    
    "web-server-prod-2" = {
      name                        = "web-server-prod-2"
      instance_type              = "t3.medium"  # Larger instance for production
      key_name                   = "client-b-prod-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-prod-web-12345678"]  # Replace with actual security group ID
      subnet_id                  = "subnet-prod-web-87654321"  # Replace with actual subnet ID
      associate_public_ip_address = true
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "web-server-prod-2"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "web-server"
        Tier = "frontend"
        Environment = "production"
      }
    }
    
    "app-server-prod-1" = {
      name                        = "app-server-prod-1"
      instance_type              = "t3.large"  # Larger instance for production
      key_name                   = "client-b-prod-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-prod-app-87654321"]  # Replace with actual security group ID
      subnet_id                  = "subnet-prod-app-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "app-server-prod-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "app-server"
        Tier = "backend"
        Environment = "production"
      }
    }
    
    "app-server-prod-2" = {
      name                        = "app-server-prod-2"
      instance_type              = "t3.large"  # Larger instance for production
      key_name                   = "client-b-prod-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-prod-app-87654321"]  # Replace with actual security group ID
      subnet_id                  = "subnet-prod-app-87654321"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "app-server-prod-2"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "app-server"
        Tier = "backend"
        Environment = "production"
      }
    }
    
    "db-server-prod-1" = {
      name                        = "db-server-prod-1"
      instance_type              = "t3.xlarge"  # Larger instance for database
      key_name                   = "client-b-prod-key"
      monitoring                 = true
      vpc_security_group_ids     = ["sg-prod-db-11223344"]  # Replace with actual security group ID
      subnet_id                  = "subnet-prod-db-12345678"  # Replace with actual subnet ID
      associate_public_ip_address = false
      user_data = {
        template = "user-data.sh"
        vars = {
          instance_name = "db-server-prod-1"
          environment  = include.account.locals.environment
        }
      }
      tags = {
        Role = "database-server"
        Tier = "database"
        Environment = "production"
      }
    }
  }
} 