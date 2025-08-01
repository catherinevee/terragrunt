# ==============================================================================
# RDS Module Configuration for Client B - Development Environment (eu-west-2)
# ==============================================================================
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

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/tfm-aws-rds.git//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "kms" {
  config_path = "../kms"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "RDS Database - Development (eu-west-2)"
  
  rds_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "RDS Database"
    create_rds_instances = true
    
    rds_instances = {
      "dev-ecommerce-db" = {
        identifier = "client-b-dev-ecommerce-db"
        engine = "mysql"
        engine_version = "8.0.35"
        instance_class = "db.t3.micro"
        allocated_storage = 20
        max_allocated_storage = 100
        storage_type = "gp2"
        storage_encrypted = true
        kms_key_id = dependency.kms.outputs.key_arns["dev-rds-key"]
        
        db_name = "ecommerce_dev"
        username = "admin"
        password = "dev-password-123"  # Should be managed via AWS Secrets Manager in production
        
        vpc_security_group_ids = [dependency.security_groups.outputs.security_group_ids["db-sg"]]
        db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
        
        backup_retention_period = 7
        backup_window = "03:00-04:00"
        maintenance_window = "sun:04:00-sun:05:00"
        
        multi_az = false  # Disabled for dev to reduce costs
        publicly_accessible = false
        skip_final_snapshot = true  # For dev environment
        
        deletion_protection = false  # For dev environment
        performance_insights_enabled = false  # Disabled for dev to reduce costs
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Database"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
    
    parameter_groups = {
      "dev-mysql-params" = {
        name = "client-b-dev-mysql-params"
        family = "mysql8.0"
        description = "MySQL parameter group for development environment"
        parameters = [
          {
            name = "character_set_server"
            value = "utf8mb4"
          },
          {
            name = "collation_server"
            value = "utf8mb4_unicode_ci"
          },
          {
            name = "max_connections"
            value = "100"
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "MySQL Parameters"
          Owner       = "DevOps Team"
        }
      }
    }
    
    subnet_groups = {
      "dev-db-subnet-group" = {
        name = "client-b-dev-db-subnet-group"
        description = "Database subnet group for development environment"
        subnet_ids = dependency.vpc.outputs.database_subnet_ids
        tags = {
          Environment = "Development"
          Purpose     = "Database Subnet Group"
          Owner       = "DevOps Team"
        }
      }
    }
    
    option_groups = {
      "dev-mysql-options" = {
        name = "client-b-dev-mysql-options"
        engine_name = "mysql"
        major_engine_version = "8.0"
        description = "MySQL option group for development environment"
        options = []
        tags = {
          Environment = "Development"
          Purpose     = "MySQL Options"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 