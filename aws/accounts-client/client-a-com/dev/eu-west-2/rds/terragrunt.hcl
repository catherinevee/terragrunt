# ==============================================================================
# RDS Module Configuration for Client A - Development Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
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

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/rds.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "RDS Database - Development (eu-west-2)"
  
  # VPC and subnet references
  vpc_id = dependency.vpc.outputs.vpc_id
  database_subnet_ids = dependency.vpc.outputs.database_subnet_ids
  
  # Security group reference
  database_security_group_id = dependency.security_groups.outputs.database_security_group_id
  
  # KMS key reference for encryption
  kms_key_id = dependency.kms.outputs.rds_kms_key_id
  
  # RDS configuration for development environment
  rds_config = {
    # MySQL database instance
    mysql = {
      identifier = "client-a-dev-mysql"
      engine = "mysql"
      engine_version = "8.0.35"
      instance_class = "db.t3.micro"  # Small instance for dev
      allocated_storage = 20
      max_allocated_storage = 100
      storage_type = "gp3"
      storage_encrypted = true
      kms_key_id = dependency.kms.outputs.rds_kms_key_id
      
      # Database configuration
      db_name = "clienta_dev_db"
      username = "admin"
      password = "dev-password-123"  # Should be managed via Secrets Manager in production
      port = 3306
      
      # Network configuration
      vpc_security_group_ids = [dependency.security_groups.outputs.database_security_group_id]
      db_subnet_group_name = "client-a-dev-db-subnet-group"
      
      # Backup and maintenance
      backup_retention_period = 7  # 7 days for dev
      backup_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      auto_minor_version_upgrade = true
      
      # Performance and monitoring
      performance_insights_enabled = true
      performance_insights_retention_period = 7
      monitoring_interval = 60
      monitoring_role_arn = "arn:aws:iam::${include.common.locals.account_id}:role/client-a-dev-rds-monitoring-role"
      
      # Deletion protection (disabled for dev)
      deletion_protection = false
      skip_final_snapshot = true
      
      # Multi-AZ (disabled for dev to save costs)
      multi_az = false
      
      # Parameter group
      parameter_group_name = "client-a-dev-mysql-params"
      parameter_group_family = "mysql8.0"
      
      # Option group
      option_group_name = "client-a-dev-mysql-options"
      option_group_description = "Option group for Client A development MySQL instance"
      
      # Tags
      tags = {
        Name = "client-a-dev-mysql"
        Purpose = "Application Database"
        Environment = "Development"
        Service = "MySQL"
      }
    }
    
    # PostgreSQL database instance (optional)
    postgresql = {
      identifier = "client-a-dev-postgresql"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.t3.micro"  # Small instance for dev
      allocated_storage = 20
      max_allocated_storage = 100
      storage_type = "gp3"
      storage_encrypted = true
      kms_key_id = dependency.kms.outputs.rds_kms_key_id
      
      # Database configuration
      db_name = "clienta_dev_pg_db"
      username = "postgres_admin"
      password = "dev-password-123"  # Should be managed via Secrets Manager in production
      port = 5432
      
      # Network configuration
      vpc_security_group_ids = [dependency.security_groups.outputs.database_security_group_id]
      db_subnet_group_name = "client-a-dev-pg-subnet-group"
      
      # Backup and maintenance
      backup_retention_period = 7  # 7 days for dev
      backup_window = "03:30-04:30"
      maintenance_window = "sun:04:30-sun:05:30"
      auto_minor_version_upgrade = true
      
      # Performance and monitoring
      performance_insights_enabled = true
      performance_insights_retention_period = 7
      monitoring_interval = 60
      monitoring_role_arn = "arn:aws:iam::${include.common.locals.account_id}:role/client-a-dev-rds-monitoring-role"
      
      # Deletion protection (disabled for dev)
      deletion_protection = false
      skip_final_snapshot = true
      
      # Multi-AZ (disabled for dev to save costs)
      multi_az = false
      
      # Parameter group
      parameter_group_name = "client-a-dev-postgresql-params"
      parameter_group_family = "postgres15"
      
      # Tags
      tags = {
        Name = "client-a-dev-postgresql"
        Purpose = "Application Database"
        Environment = "Development"
        Service = "PostgreSQL"
      }
    }
  }
  
  # Tags for all RDS resources
  tags = {
    Environment = "Development"
    Project     = "Client A Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    Client      = "Client A"
  }
} 