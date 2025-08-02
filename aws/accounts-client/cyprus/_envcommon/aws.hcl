# Environment common configuration for Cyprus
# This file contains shared configurations across all services in the Cyprus environment

locals {
  # Environment-specific variables
  environment = "cyprus"
  
  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Owner       = "infrastructure-team"
    Purpose     = "application-infrastructure"
  }
  
  # Security configurations
  security_config = {
    # VPC Flow Logs
    enable_flow_logs = true
    flow_log_retention_days = 7
    
    # Encryption
    enable_encryption = true
    kms_key_alias = "alias/cyprus-encryption-key"
    
    # Backup
    backup_retention_days = 7
    enable_deletion_protection = true
    
    # Monitoring
    enable_enhanced_monitoring = true
    monitoring_interval = 60
  }
  
  # Network configurations
  network_config = {
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    
    # Subnet configurations
    public_subnets = {
      "eu-west-1a" = "10.0.1.0/24"
      "eu-west-1b" = "10.0.2.0/24"
      "eu-west-1c" = "10.0.3.0/24"
    }
    
    private_subnets = {
      "eu-west-1a" = "10.0.11.0/24"
      "eu-west-1b" = "10.0.12.0/24"
      "eu-west-1c" = "10.0.13.0/24"
    }
    
    database_subnets = {
      "eu-west-1a" = "10.0.21.0/24"
      "eu-west-1b" = "10.0.22.0/24"
      "eu-west-1c" = "10.0.23.0/24"
    }
  }
  
  # Application configurations
  app_config = {
    # ECS Configuration
    ecs = {
      cluster_name = "cyprus-cluster"
      service_name = "accounts-client-service"
      cpu = 256
      memory = 512
      desired_count = 2
      max_count = 4
      min_count = 1
      container_port = 8080
      health_check_path = "/health"
    }
    
    # RDS Configuration
    rds = {
      instance_class = "db.t3.micro"
      allocated_storage = 20
      engine_version = "15.5"
      family = "postgres15"
      backup_retention_period = 7
      deletion_protection = true
    }
    
    # ALB Configuration
    alb = {
      name = "cyprus-alb"
      internal = false
      enable_https = true
      health_check_path = "/health"
      health_check_port = 8080
    }
  }
  
  # Monitoring configurations
  monitoring_config = {
    # CloudWatch
    log_retention_days = 30
    enable_alarms = true
    
    # Alarms
    cpu_threshold = 80
    memory_threshold = 80
    disk_threshold = 85
    
    # Dashboard
    enable_dashboard = true
    dashboard_name = "cyprus-accounts-client-dashboard"
  }
}

# Common inputs for all modules
inputs = {
  environment = local.environment
  common_tags = local.common_tags
  
  # Security
  security_config = local.security_config
  
  # Network
  network_config = local.network_config
  
  # Application
  app_config = local.app_config
  
  # Monitoring
  monitoring_config = local.monitoring_config
} 