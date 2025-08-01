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

# Dependencies (uncomment and configure as needed)
# dependency "vpc" {
#   config_path = "../vpc"
# }
# 
# dependency "rds" {
#   config_path = "../rds"
# }
# 
# dependency "elasticache" {
#   config_path = "../elasticache"
# }
# 
# dependency "alb" {
#   config_path = "../alb"
# }

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
  
  # VPC and networking configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    availability_zones = ["eu-west-2a", "eu-west-2b"]
    
    public_subnets = {
      "eu-west-2a" = "10.0.1.0/24"
      "eu-west-2b" = "10.0.2.0/24"
    }
    
    private_subnets = {
      "eu-west-2a" = "10.0.10.0/24"
      "eu-west-2b" = "10.0.11.0/24"
    }
    
    database_subnets = {
      "eu-west-2a" = "10.0.20.0/24"
      "eu-west-2b" = "10.0.21.0/24"
    }
    
    elasticache_subnets = {
      "eu-west-2a" = "10.0.30.0/24"
      "eu-west-2b" = "10.0.31.0/24"
    }
  }
  
  # Security groups configuration
  security_groups = {
    alb_sg = {
      name = "client-b-ecommerce-dev-alb-sg"
      description = "Security group for ALB in dev environment"
      ingress_rules = [
        {
          port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access"
        },
        {
          port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS access"
        }
      ]
    }
    
    app_sg = {
      name = "client-b-ecommerce-dev-app-sg"
      description = "Security group for application servers in dev environment"
      ingress_rules = [
        {
          port = 80
          protocol = "tcp"
          source_security_group_id = "sg-alb-dev-id"  # Replace with actual ALB SG ID
          description = "HTTP from ALB"
        },
        {
          port = 22
          protocol = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "SSH from VPC"
        }
      ]
    }
    
    db_sg = {
      name = "client-b-ecommerce-dev-db-sg"
      description = "Security group for database in dev environment"
      ingress_rules = [
        {
          port = 3306
          protocol = "tcp"
          source_security_group_id = "sg-app-dev-id"  # Replace with actual App SG ID
          description = "MySQL from application servers"
        }
      ]
    }
    
    cache_sg = {
      name = "client-b-ecommerce-dev-cache-sg"
      description = "Security group for ElastiCache in dev environment"
      ingress_rules = [
        {
          port = 6379
          protocol = "tcp"
          source_security_group_id = "sg-app-dev-id"  # Replace with actual App SG ID
          description = "Redis from application servers"
        }
      ]
    }
  }
  
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