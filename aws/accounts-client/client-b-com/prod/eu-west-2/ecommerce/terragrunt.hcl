# ==============================================================================
# Ecommerce Module Configuration for Client B - Production Environment
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
  project     = "Ecommerce Platform - Production"
  
  # Ecommerce specific configuration for production environment
  ecommerce_config = {
    # Application configuration
    app_name = "client-b-ecommerce-prod"
    domain_name = "ecommerce.client-b.com"
    
    # Infrastructure sizing for production (high performance and availability)
    instance_type = "t3.xlarge"
    min_size = 3
    max_size = 10
    desired_capacity = 3
    
    # Database configuration
    db_instance_class = "db.t3.large"
    db_allocated_storage = 200
    db_storage_type = "gp3"  # Use GP3 for better performance
    db_backup_retention_period = 35
    db_backup_window = "01:00-02:00"
    db_maintenance_window = "sun:02:00-sun:03:00"
    db_multi_az = true  # Enable Multi-AZ for production
    db_storage_encrypted = true
    db_performance_insights_enabled = true
    db_performance_insights_retention_period = 7
    
    # Cache configuration
    cache_node_type = "cache.t3.medium"
    cache_num_cache_nodes = 3  # Multi-node cluster for production
    cache_parameter_group_name = "default.redis7"
    cache_automatic_failover_enabled = true
    cache_multi_az_enabled = true
    
    # Load balancer configuration
    alb_internal = false
    alb_deletion_protection = true  # Critical for production
    alb_idle_timeout = 60
    alb_enable_http2 = true
    alb_enable_access_logs = true
    
    # Auto scaling configuration
    scale_up_threshold = 80
    scale_down_threshold = 20
    scale_up_cooldown = 300
    scale_down_cooldown = 600  # Longer cooldown for production
    
    # SSL/TLS configuration
    certificate_arn = "arn:aws:acm:eu-west-2:987654321098:certificate/prod-cert-id"  # Replace with actual certificate ARN
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
    
    # Monitoring and logging
    enable_cloudwatch_logs = true
    enable_xray_tracing = true
    log_retention_days = 90
    
    # Security configuration
    enable_waf = true  # Critical for production
    enable_shield = true  # Enable Shield for production
    enable_guardduty = true
    enable_security_hub = true
    
    # Backup and disaster recovery
    enable_cross_region_backup = true  # Critical for production
    backup_retention_days = 90
    enable_point_in_time_recovery = true
    
    # Performance optimization
    enable_cloudfront = true  # Critical for production performance
    enable_elasticache = true
    enable_rds_read_replica = true  # Multiple read replicas for production
    enable_auto_scaling = true
    enable_spot_instances = false  # Disable spot instances for production stability
    
    # Production specific settings
    enable_debug_mode = false
    enable_development_features = false
    enable_test_data = false
    enable_blue_green_deployment = true
    enable_canary_deployment = true
  }
  
  # VPC and networking configuration
  vpc_config = {
    cidr_block = "10.2.0.0/16"  # Different CIDR for production
    availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    
    public_subnets = {
      "eu-west-2a" = "10.2.1.0/24"
      "eu-west-2b" = "10.2.2.0/24"
      "eu-west-2c" = "10.2.3.0/24"
    }
    
    private_subnets = {
      "eu-west-2a" = "10.2.10.0/24"
      "eu-west-2b" = "10.2.11.0/24"
      "eu-west-2c" = "10.2.12.0/24"
    }
    
    database_subnets = {
      "eu-west-2a" = "10.2.20.0/24"
      "eu-west-2b" = "10.2.21.0/24"
      "eu-west-2c" = "10.2.22.0/24"
    }
    
    elasticache_subnets = {
      "eu-west-2a" = "10.2.30.0/24"
      "eu-west-2b" = "10.2.31.0/24"
      "eu-west-2c" = "10.2.32.0/24"
    }
  }
  
  # Security groups configuration
  security_groups = {
    alb_sg = {
      name = "client-b-ecommerce-prod-alb-sg"
      description = "Security group for ALB in production environment"
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
      name = "client-b-ecommerce-prod-app-sg"
      description = "Security group for application servers in production environment"
      ingress_rules = [
        {
          port = 80
          protocol = "tcp"
          source_security_group_id = "sg-alb-prod-id"  # Replace with actual ALB SG ID
          description = "HTTP from ALB"
        },
        {
          port = 22
          protocol = "tcp"
          cidr_blocks = ["10.2.0.0/16"]
          description = "SSH from VPC"
        }
      ]
    }
    
    db_sg = {
      name = "client-b-ecommerce-prod-db-sg"
      description = "Security group for database in production environment"
      ingress_rules = [
        {
          port = 3306
          protocol = "tcp"
          source_security_group_id = "sg-app-prod-id"  # Replace with actual App SG ID
          description = "MySQL from application servers"
        }
      ]
    }
    
    cache_sg = {
      name = "client-b-ecommerce-prod-cache-sg"
      description = "Security group for ElastiCache in production environment"
      ingress_rules = [
        {
          port = 6379
          protocol = "tcp"
          source_security_group_id = "sg-app-prod-id"  # Replace with actual App SG ID
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
    Purpose     = "Production Ecommerce Platform"
    DataClassification = "Confidential"
    BackupRequired = "Yes"
    Compliance  = "GDPR"
    ProductionEnvironment = "Yes"
    CriticalSystem = "Yes"
    BusinessImpact = "High"
  }
  
  # Production specific overrides
  production_overrides = {
    # Enable all production features
    enable_auto_scaling = true
    enable_high_availability = true
    enable_multi_az = true
    enable_disaster_recovery = true
    
    # Disable development features
    enable_debug_logging = false
    enable_development_endpoints = false
    enable_test_data_creation = false
    
    # Enhanced monitoring for production
    enable_detailed_monitoring = true
    enable_advanced_metrics = true
    enable_custom_metrics = true
    enable_log_aggregation = true
    
    # Production specific environment variables
    environment_variables = {
      NODE_ENV = "production"
      DEBUG = "false"
      LOG_LEVEL = "warn"
      ENABLE_TEST_FEATURES = "false"
      SKIP_SSL_VERIFICATION = "false"
      ENABLE_PERFORMANCE_MONITORING = "true"
      ENABLE_ERROR_TRACKING = "true"
      ENABLE_APM = "true"
      ENABLE_DISTRIBUTED_TRACING = "true"
    }
    
    # Production monitoring and alerting
    monitoring_config = {
      enable_cloudwatch_alarms = true
      enable_sns_notifications = true
      enable_opsgenie_integration = true
      enable_pagerduty_integration = true
      enable_slack_notifications = true
      
      # Critical alarms
      critical_alarms = [
        "HighCPUUtilization",
        "HighMemoryUtilization",
        "DatabaseConnections",
        "ResponseTime",
        "ErrorRate",
        "Availability"
      ]
    }
    
    # Performance optimization
    performance_config = {
      enable_auto_scaling = true
      enable_load_balancing = true
      enable_caching = true
      enable_cdn = true
      enable_database_optimization = true
      enable_application_optimization = true
    }
    
    # Security hardening
    security_config = {
      enable_encryption_at_rest = true
      enable_encryption_in_transit = true
      enable_vpc_flow_logs = true
      enable_cloudtrail = true
      enable_config_rules = true
      enable_security_hub = true
      enable_guardduty = true
      enable_macie = true
    }
  }
  
  # CloudFront configuration for production
  cloudfront_config = {
    enabled = true
    price_class = "PriceClass_All"  # Use all edge locations for production
    default_root_object = "index.html"
    error_pages = {
      "404" = "/index.html"
      "403" = "/index.html"
      "500" = "/error.html"
      "502" = "/error.html"
      "503" = "/error.html"
      "504" = "/error.html"
    }
    
    # Cache behaviors
    cache_behaviors = {
      "api/*" = {
        target_origin_id = "api-origin"
        viewer_protocol_policy = "https-only"
        cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # CachingDisabled
        origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"  # CORS-S3Origin
      }
      "static/*" = {
        target_origin_id = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # CachingOptimized
        compress = true
        min_ttl = 0
        default_ttl = 86400
        max_ttl = 31536000
      }
      "images/*" = {
        target_origin_id = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # CachingOptimized
        compress = true
        min_ttl = 0
        default_ttl = 604800
        max_ttl = 31536000
      }
    }
    
    # Security headers
    security_headers = {
      strict_transport_security = {
        override = true
        include_subdomains = true
        preload = true
        access_control_max_age_sec = 31536000
      }
      content_security_policy = {
        override = true
        content_security_policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
      }
      x_content_type_options = {
        override = true
      }
      x_frame_options = {
        override = true
        frame_option = "SAMEORIGIN"
      }
      x_xss_protection = {
        override = true
        protection = true
        mode_block = true
      }
      referrer_policy = {
        override = true
        referrer_policy = "strict-origin-when-cross-origin"
      }
    }
  }
  
  # WAF configuration for production
  waf_config = {
    enabled = true
    name = "client-b-ecommerce-prod-waf"
    description = "WAF for production ecommerce platform"
    
    # WAF rules
    rules = {
      rate_limit = {
        name = "RateLimitRule"
        priority = 1
        action = "block"
        rate_limit = 5000  # Higher limit for production
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
      
      known_bad_inputs = {
        name = "KnownBadInputsRule"
        priority = 4
        action = "block"
        rule_group_reference = "AWSManagedRulesKnownBadInputsRuleSet"
      }
      
      linux_os = {
        name = "LinuxOSRule"
        priority = 5
        action = "block"
        rule_group_reference = "AWSManagedRulesLinuxRuleSet"
      }
      
      windows_os = {
        name = "WindowsOSRule"
        priority = 6
        action = "block"
        rule_group_reference = "AWSManagedRulesWindowsRuleSet"
      }
      
      ip_reputation = {
        name = "IPReputationRule"
        priority = 7
        action = "block"
        rule_group_reference = "AWSManagedRulesAmazonIpReputationList"
      }
    }
  }
  
  # Disaster recovery configuration
  disaster_recovery_config = {
    enable_cross_region_replication = true
    enable_point_in_time_recovery = true
    enable_automated_backups = true
    backup_retention_period = 90
    enable_cross_account_backup = false  # Configure if needed
    
    # RTO/RPO targets
    rto_target = "4 hours"
    rpo_target = "1 hour"
    
    # Recovery procedures
    recovery_procedures = {
      enable_automated_failover = true
      enable_manual_failover = true
      enable_blue_green_deployment = true
      enable_rollback_procedures = true
    }
  }
  
  # Compliance and governance
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = true
    enable_data_classification = true
    enable_privacy_protection = true
    
    # GDPR compliance
    gdpr_compliance = {
      enable_data_encryption = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = true
      enable_data_portability = true
      enable_privacy_by_design = true
    }
    
    # Security compliance
    security_compliance = {
      enable_iso27001_compliance = true
      enable_soc2_compliance = true
      enable_pci_dss_compliance = true
      enable_hipaa_compliance = false  # Enable if needed
    }
  }
} 