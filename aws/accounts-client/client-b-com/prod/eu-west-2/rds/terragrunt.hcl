# ==============================================================================
# RDS Module Configuration for Client B - Production Environment (eu-west-2)
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

terraform {
  source = "https://github.com/catherinevee/tfm-aws-rds//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # RDS Configuration
  rds_config = {
    # Database instance configuration
    instance_config = {
      identifier = "client-b-prod-mysql"
      engine = "mysql"
      engine_version = "8.0.35"
      instance_class = "db.t3.small"
      allocated_storage = 100
      max_allocated_storage = 1000
      storage_type = "gp3"
      storage_encrypted = true
      kms_key_id = dependency.kms.outputs.key_arns["prod-rds-key"]
      
      # Database credentials
      db_name = "client_b_production"
      username = "admin"
      password = "prod-password-123"  # Should be stored in AWS Secrets Manager
      
      # Network configuration
      vpc_security_group_ids = [dependency.security_groups.outputs.security_group_ids["database-sg"]]
      db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
      
      # Backup and maintenance
      backup_retention_period = 30
      backup_window = "02:00-03:00"
      maintenance_window = "sun:03:00-sun:04:00"
      auto_minor_version_upgrade = true
      
      # Performance and monitoring
      performance_insights_enabled = true
      performance_insights_retention_period = 30
      monitoring_interval = 60
      monitoring_role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/rds-monitoring-role"
      
      # High availability (multi-AZ for production)
      multi_az = true
      publicly_accessible = false
      skip_final_snapshot = false
      final_snapshot_identifier = "client-b-prod-mysql-final-snapshot"
      deletion_protection = true
      
      # Parameter group
      parameter_group_name = "client-b-prod-mysql-8-0"
      parameter_group_family = "mysql8.0"
      
      # Option group
      option_group_name = "client-b-prod-mysql-8-0"
      option_group_description = "Option group for Client B production MySQL 8.0"
    }
    
    # Parameter group settings
    parameter_group_settings = {
      "innodb_buffer_pool_size" = "{DBInstanceClassMemory*3/4}"
      "max_connections" = "500"
      "slow_query_log" = "1"
      "long_query_time" = "1"
      "log_queries_not_using_indexes" = "1"
      "innodb_log_file_size" = "268435456"
      "innodb_log_buffer_size" = "16777216"
    }
    
    # Option group options
    option_group_options = []
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Database"
  }
} 