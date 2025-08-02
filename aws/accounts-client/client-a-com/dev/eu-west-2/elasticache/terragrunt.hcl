# ==============================================================================
# ElastiCache Module Configuration for Client A - Development Environment (eu-west-2)
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
  source = "git::https://github.com/catherinevee/elasticache.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "ElastiCache - Development (eu-west-2)"
  
  # VPC and subnet references
  vpc_id = dependency.vpc.outputs.vpc_id
  elasticache_subnet_ids = dependency.vpc.outputs.elasticache_subnet_ids
  
  # Security group reference
  elasticache_security_group_id = dependency.security_groups.outputs.elasticache_security_group_id
  
  # KMS key reference for encryption
  kms_key_id = dependency.kms.outputs.elasticache_kms_key_id
  
  # ElastiCache configuration for development environment
  elasticache_config = {
    # Redis cluster
    redis = {
      cluster_id = "client-a-dev-redis"
      engine = "redis"
      engine_version = "7.0"
      node_type = "cache.t3.micro"  # Small instance for dev
      num_cache_nodes = 1  # Single node for dev
      port = 6379
      
      # Network configuration
      subnet_group_name = "client-a-dev-redis-subnet-group"
      security_group_ids = [dependency.security_groups.outputs.elasticache_security_group_id]
      
      # Encryption
      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
      kms_key_id = dependency.kms.outputs.elasticache_kms_key_id
      
      # Backup and maintenance
      snapshot_retention_limit = 7  # 7 days for dev
      snapshot_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      
      # Performance and monitoring
      notification_topic_arn = "arn:aws:sns:${include.region.locals.region_name}:${include.common.locals.account_id}:client-a-dev-monitoring"
      
      # Multi-AZ (disabled for dev to save costs)
      multi_az_enabled = false
      automatic_failover_enabled = false
      
      # Parameter group
      parameter_group_name = "client-a-dev-redis-params"
      parameter_group_family = "redis7"
      
      # Tags
      tags = {
        Name = "client-a-dev-redis"
        Purpose = "Application Cache"
        Environment = "Development"
        Service = "Redis"
      }
    }
    
    # Memcached cluster (optional)
    memcached = {
      cluster_id = "client-a-dev-memcached"
      engine = "memcached"
      engine_version = "1.6.17"
      node_type = "cache.t3.micro"  # Small instance for dev
      num_cache_nodes = 1  # Single node for dev
      port = 11211
      
      # Network configuration
      subnet_group_name = "client-a-dev-memcached-subnet-group"
      security_group_ids = [dependency.security_groups.outputs.elasticache_security_group_id]
      
      # Encryption
      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
      kms_key_id = dependency.kms.outputs.elasticache_kms_key_id
      
      # Maintenance
      maintenance_window = "sun:04:30-sun:05:30"
      
      # Performance and monitoring
      notification_topic_arn = "arn:aws:sns:${include.region.locals.region_name}:${include.common.locals.account_id}:client-a-dev-monitoring"
      
      # Parameter group
      parameter_group_name = "client-a-dev-memcached-params"
      parameter_group_family = "memcached1.6"
      
      # Tags
      tags = {
        Name = "client-a-dev-memcached"
        Purpose = "Application Cache"
        Environment = "Development"
        Service = "Memcached"
      }
    }
  }
  
  # Tags for all ElastiCache resources
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