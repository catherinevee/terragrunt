# ==============================================================================
# Ecommerce Module Configuration for Client B - Staging Environment
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
  project     = "Ecommerce Platform - Staging"
  
  # Ecommerce specific configuration for staging environment
  ecommerce_config = {
    # Application configuration
    app_name = "client-b-ecommerce-staging"
    domain_name = "staging.ecommerce.client-b.com"
    
    # Infrastructure sizing for staging (between dev and prod)
    instance_type = "t3.large"
    min_size = 2
    max_size = 4
    desired_capacity = 2
    
    # Database configuration
    db_instance_class = "db.t3.small"
    db_allocated_storage = 50
    db_storage_type = "gp2"
    db_backup_retention_period = 14
    db_backup_window = "02:00-03:00"
    db_maintenance_window = "sun:03:00-sun:04:00"
    db_multi_az = true  # Enable Multi-AZ for staging
    
    # Cache configuration
    cache_node_type = "cache.t3.small"
    cache_num_cache_nodes = 2  # Multi-node for staging
    
    # Load balancer configuration
    alb_internal = false
    alb_deletion_protection = true  # Enable deletion protection for staging
    
    # Auto scaling configuration
    scale_up_threshold = 75
    scale_down_threshold = 25
    scale_up_cooldown = 300
    scale_down_cooldown = 300
    
    # SSL/TLS configuration
    certificate_arn = "arn:aws:acm:eu-west-2:987654321098:certificate/staging-cert-id"  # Replace with actual certificate ARN
    
    # Monitoring and logging
    enable_cloudwatch_logs = true
    enable_xray_tracing = true
    log_retention_days = 30
    
    # Security configuration
    enable_waf = true  # Enable WAF for staging
    enable_shield = false  # Keep Shield disabled for staging
    
    # Backup and disaster recovery
    enable_cross_region_backup = true  # Enable for staging
    backup_retention_days = 30
    
    # Performance optimization
    enable_cloudfront = true  # Enable CloudFront for staging
    enable_elasticache = true
    enable_rds_read_replica = true  # Enable read replica for staging
    
    # Staging specific settings
    enable_debug_mode = false  # Disable debug mode for staging
    enable_development_features = false
    enable_test_data = false
  }
  
  # VPC and networking configuration
  vpc_config = {
    cidr_block = "10.1.0.0/16"  # Different CIDR for staging
    availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    
    public_subnets = {
      "eu-west-2a" = "10.1.1.0/24"
      "eu-west-2b" = "10.1.2.0/24"
      "eu-west-2c" = "10.1.3.0/24"
    }
    
    private_subnets = {
      "eu-west-2a" = "10.1.10.0/24"
      "eu-west-2b" = "10.1.11.0/24"
      "eu-west-2c" = "10.1.12.0/24"
    }
    
    database_subnets = {
      "eu-west-2a" = "10.1.20.0/24"
      "eu-west-2b" = "10.1.21.0/24"
      "eu-west-2c" = "10.1.22.0/24"
    }
    
    elasticache_subnets = {
      "eu-west-2a" = "10.1.30.0/24"
      "eu-west-2b" = "10.1.31.0/24"
      "eu-west-2c" = "10.1.32.0/24"
    }
  }
  
  # Security groups configuration
  security_groups = {
    alb_sg = {
      name = "client-b-ecommerce-staging-alb-sg"
      description = "Security group for ALB in staging environment"
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
      name = "client-b-ecommerce-staging-app-sg"
      description = "Security group for application servers in staging environment"
      ingress_rules = [
        {
          port = 80
          protocol = "tcp"
          source_security_group_id = "sg-alb-staging-id"  # Replace with actual ALB SG ID
          description = "HTTP from ALB"
        },
        {
          port = 22
          protocol = "tcp"
          cidr_blocks = ["10.1.0.0/16"]
          description = "SSH from VPC"
        }
      ]
    }
    
    db_sg = {
      name = "client-b-ecommerce-staging-db-sg"
      description = "Security group for database in staging environment"
      ingress_rules = [
        {
          port = 3306
          protocol = "tcp"
          source_security_group_id = "sg-app-staging-id"  # Replace with actual App SG ID
          description = "MySQL from application servers"
        }
      ]
    }
    
    cache_sg = {
      name = "client-b-ecommerce-staging-cache-sg"
      description = "Security group for ElastiCache in staging environment"
      ingress_rules = [
        {
          port = 6379
          protocol = "tcp"
          source_security_group_id = "sg-app-staging-id"  # Replace with actual App SG ID
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
    Purpose     = "Staging Ecommerce Platform"
    DataClassification = "Internal"
    BackupRequired = "Yes"
    Compliance  = "GDPR"
    TestingEnvironment = "Yes"
  }
  
  # Staging specific overrides
  staging_overrides = {
    # Enable production-like features for staging
    enable_auto_scaling = true
    enable_high_availability = true
    enable_multi_az = true
    
    # Disable development features
    enable_debug_logging = false
    enable_development_endpoints = false
    enable_test_data_creation = false
    
    # Enhanced monitoring for staging
    enable_detailed_monitoring = true
    enable_advanced_metrics = true
    
    # Staging specific environment variables
    environment_variables = {
      NODE_ENV = "staging"
      DEBUG = "false"
      LOG_LEVEL = "info"
      ENABLE_TEST_FEATURES = "false"
      SKIP_SSL_VERIFICATION = "false"
      ENABLE_PERFORMANCE_MONITORING = "true"
      ENABLE_ERROR_TRACKING = "true"
    }
    
    # Performance testing configuration
    performance_testing = {
      enable_load_testing = true
      enable_stress_testing = true
      enable_capacity_testing = true
      test_data_size = "medium"
    }
    
    # Security testing configuration
    security_testing = {
      enable_vulnerability_scanning = true
      enable_penetration_testing = true
      enable_compliance_scanning = true
    }
    
    # Backup and recovery testing
    backup_testing = {
      enable_backup_verification = true
      enable_restore_testing = true
      backup_test_schedule = "weekly"
    }
  }
  
  # CloudFront configuration for staging
  cloudfront_config = {
    enabled = true
    price_class = "PriceClass_100"  # Use only North America and Europe
    default_root_object = "index.html"
    error_pages = {
      "404" = "/index.html"
      "403" = "/index.html"
    }
    
    # Cache behaviors
    cache_behaviors = {
      "api/*" = {
        target_origin_id = "api-origin"
        viewer_protocol_policy = "https-only"
        cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # CachingDisabled
      }
      "static/*" = {
        target_origin_id = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # CachingOptimized
        compress = true
      }
    }
  }
  
  # WAF configuration for staging
  waf_config = {
    enabled = true
    name = "client-b-ecommerce-staging-waf"
    description = "WAF for staging ecommerce platform"
    
    # WAF rules
    rules = {
      rate_limit = {
        name = "RateLimitRule"
        priority = 1
        action = "block"
        rate_limit = 2000  # Requests per 5 minutes
      }
      
      sql_injection = {
        name = "SQLInjectionRule"
        priority = 2
        action = "block"
        rule_group_reference = "AWSManagedRulesSQLiRuleSet"
      }
      
      xss_protection = {
        name = "XSSProtectionRule"
        priority = 3
        action = "block"
        rule_group_reference = "AWSManagedRulesAnonymousIpList"
      }
    }
  }
} 