# ==============================================================================
# RDS Module Configuration for Client B - Development Environment (eu-west-3)
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
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "RDS Database - Development"
  
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
      identifier = "client-b-dev-mysql"
      engine = "mysql"
      engine_version = "8.0.35"
      instance_class = "db.t3.micro"  # Small instance for dev
      allocated_storage = 20
      max_allocated_storage = 100
      storage_type = "gp3"
      storage_encrypted = true
      kms_key_id = dependency.kms.outputs.rds_kms_key_id
      
      # Database configuration
      db_name = "clientb_dev_db"
      username = "admin"
      password = "dev-password-123"  # Should be managed via Secrets Manager in production
      port = 3306
      
      # Network configuration
      vpc_security_group_ids = [dependency.security_groups.outputs.database_security_group_id]
      db_subnet_group_name = "client-b-dev-db-subnet-group"
      
      # Backup and maintenance
      backup_retention_period = 7  # 7 days for dev
      backup_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      auto_minor_version_upgrade = true
      
      # Performance and monitoring
      performance_insights_enabled = true
      performance_insights_retention_period = 7
      monitoring_interval = 60
      monitoring_role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/rds-monitoring-role"
      
      # Deletion protection (disabled for dev)
      deletion_protection = false
      skip_final_snapshot = true
      
      # Multi-AZ (disabled for dev to save costs)
      multi_az = false
      
      # Parameter group
      parameter_group_name = "client-b-dev-mysql-params"
      parameter_group_family = "mysql8.0"
      
      # Option group
      option_group_name = "client-b-dev-mysql-options"
      option_group_description = "Option group for Client B development MySQL instance"
      
      # Tags
      tags = {
        Name = "client-b-dev-mysql"
        Purpose = "Application Database"
        Environment = "Development"
        Service = "MySQL"
      }
    }
    
    # PostgreSQL database instance (optional)
    postgresql = {
      identifier = "client-b-dev-postgresql"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.t3.micro"  # Small instance for dev
      allocated_storage = 20
      max_allocated_storage = 100
      storage_type = "gp3"
      storage_encrypted = true
      kms_key_id = dependency.kms.outputs.rds_kms_key_id
      
      # Database configuration
      db_name = "clientb_dev_pg_db"
      username = "postgres_admin"
      password = "dev-password-123"  # Should be managed via Secrets Manager in production
      port = 5432
      
      # Network configuration
      vpc_security_group_ids = [dependency.security_groups.outputs.database_security_group_id]
      db_subnet_group_name = "client-b-dev-pg-subnet-group"
      
      # Backup and maintenance
      backup_retention_period = 7  # 7 days for dev
      backup_window = "03:30-04:30"
      maintenance_window = "sun:04:30-sun:05:30"
      auto_minor_version_upgrade = true
      
      # Performance and monitoring
      performance_insights_enabled = true
      performance_insights_retention_period = 7
      monitoring_interval = 60
      monitoring_role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/rds-monitoring-role"
      
      # Deletion protection (disabled for dev)
      deletion_protection = false
      skip_final_snapshot = true
      
      # Multi-AZ (disabled for dev to save costs)
      multi_az = false
      
      # Parameter group
      parameter_group_name = "client-b-dev-postgresql-params"
      parameter_group_family = "postgres15"
      
      # Tags
      tags = {
        Name = "client-b-dev-postgresql"
        Purpose = "Application Database"
        Environment = "Development"
        Service = "PostgreSQL"
      }
    }
  }
  
  # Tags for all RDS resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
  }
} 