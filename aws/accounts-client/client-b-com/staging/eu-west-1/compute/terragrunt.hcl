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

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

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
      vpc_security_group_ids     = [dependency.security_groups.outputs.security_group_ids["web-server-sg"]]
      subnet_id                  = dependency.vpc.outputs.public_subnet_ids[0]
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
      vpc_security_group_ids     = [dependency.security_groups.outputs.security_group_ids["web-server-sg"]]
      subnet_id                  = dependency.vpc.outputs.public_subnet_ids[1]
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
      vpc_security_group_ids     = [dependency.security_groups.outputs.security_group_ids["app-server-sg"]]
      subnet_id                  = dependency.vpc.outputs.private_subnet_ids[0]
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
      vpc_security_group_ids     = [dependency.security_groups.outputs.security_group_ids["app-server-sg"]]
      subnet_id                  = dependency.vpc.outputs.private_subnet_ids[1]
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
      vpc_security_group_ids     = [dependency.security_groups.outputs.security_group_ids["database-sg"]]
      subnet_id                  = dependency.vpc.outputs.database_subnet_ids[0]
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