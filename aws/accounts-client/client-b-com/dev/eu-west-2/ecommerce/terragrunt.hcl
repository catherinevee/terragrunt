# ==============================================================================
# Ecommerce Module Configuration for Client B - Dev Environment
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
  source = "git::https://github.com/catherinevee/tfm-aws-ecommerce.git//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "rds" {
  config_path = "../rds"
}

dependency "elasticache" {
  config_path = "../elasticache"
}

dependency "alb" {
  config_path = "../alb"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

dependency "kms" {
  config_path = "../kms"
}

dependency "sns" {
  config_path = "../sns"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  costcenter  = "ClientB"
  project     = "Ecommerce Platform - Development"
  
  # Ecommerce specific configuration for dev environment
  ecommerce_config = {
    # Application configuration
    app_name = "client-b-ecommerce-dev"
    domain_name = "dev.ecommerce.client-b.com"
    
    # Infrastructure sizing for dev
    instance_type = "t3.medium"
    min_size = 1
    max_size = 3
    desired_capacity = 1
    
    # Database configuration
    db_instance_class = "db.t3.micro"
    db_allocated_storage = 20
    db_storage_type = "gp2"
    db_backup_retention_period = 7
    db_backup_window = "03:00-04:00"
    db_maintenance_window = "sun:04:00-sun:05:00"
    
    # Cache configuration
    cache_node_type = "cache.t3.micro"
    cache_num_cache_nodes = 1
    
    # Load balancer configuration
    alb_internal = false
    alb_deletion_protection = false
    
    # Auto scaling configuration
    scale_up_threshold = 70
    scale_down_threshold = 30
    scale_up_cooldown = 300
    scale_down_cooldown = 300
    
    # SSL/TLS configuration
    certificate_arn = "arn:aws:acm:eu-west-2:987654321098:certificate/dev-cert-id"  # Replace with actual certificate ARN
    
    # Monitoring and logging
    enable_cloudwatch_logs = true
    enable_xray_tracing = true
    log_retention_days = 7
    
    # Security configuration
    enable_waf = false  # Disable WAF for dev to reduce costs
    enable_shield = false  # Disable Shield for dev
    
    # Backup and disaster recovery
    enable_cross_region_backup = false  # Disable for dev
    backup_retention_days = 7
    
    # Performance optimization
    enable_cloudfront = false  # Disable CloudFront for dev
    enable_elasticache = true
    enable_rds_read_replica = false  # Disable read replica for dev
    
    # Development specific settings
    enable_debug_mode = true
    enable_development_features = true
    enable_test_data = true
  }
  
  # VPC and networking configuration (using dependencies)
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  database_subnet_ids = dependency.vpc.outputs.database_subnet_ids
  elasticache_subnet_ids = dependency.vpc.outputs.elasticache_subnet_ids
  
  # Security groups configuration (using dependencies)
  alb_security_group_id = dependency.security_groups.outputs.security_group_ids["alb-sg"]
  app_security_group_id = dependency.security_groups.outputs.security_group_ids["app-sg"]
  db_security_group_id = dependency.security_groups.outputs.security_group_ids["db-sg"]
  cache_security_group_id = dependency.security_groups.outputs.security_group_ids["cache-sg"]
  
  # Database configuration (using dependencies)
  rds_endpoint = dependency.rds.outputs.db_endpoint
  rds_port = dependency.rds.outputs.db_port
  rds_database_name = dependency.rds.outputs.db_name
  
  # Cache configuration (using dependencies)
  elasticache_endpoint = dependency.elasticache.outputs.cache_endpoint
  elasticache_port = dependency.elasticache.outputs.cache_port
  
  # Load balancer configuration (using dependencies)
  alb_dns_name = dependency.alb.outputs.load_balancer_dns_name
  alb_zone_id = dependency.alb.outputs.load_balancer_zone_id
  target_group_arn = dependency.alb.outputs.target_group_arn
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "Ecommerce Platform"
    CostCenter  = "ClientB"
    Owner       = "DevOps Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Development Ecommerce Platform"
    DataClassification = "Internal"
    BackupRequired = "Yes"
    Compliance  = "GDPR"
  }
  
  # Development specific overrides
  dev_overrides = {
    # Reduce costs for development
    enable_auto_scaling = false
    enable_high_availability = false
    enable_multi_az = false
    
    # Enable development features
    enable_debug_logging = true
    enable_development_endpoints = true
    enable_test_data_creation = true
    
    # Simplified monitoring for dev
    enable_detailed_monitoring = false
    enable_advanced_metrics = false
    
    # Development specific environment variables
    environment_variables = {
      NODE_ENV = "development"
      DEBUG = "true"
      LOG_LEVEL = "debug"
      ENABLE_TEST_FEATURES = "true"
      SKIP_SSL_VERIFICATION = "true"
    }
  }
} 