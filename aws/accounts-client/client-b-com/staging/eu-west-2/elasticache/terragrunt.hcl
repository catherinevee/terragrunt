# ==============================================================================
# ElastiCache Module Configuration for Client B - Staging Environment (eu-west-2)
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
  source = "https://github.com/catherinevee/tfm-aws-elasticache//?ref=v1.0.0"
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
  
  # ElastiCache Configuration
  elasticache_config = {
    # Redis cluster configuration
    cluster_config = {
      cluster_id = "client-b-staging-redis"
      engine = "redis"
      engine_version = "7.0"
      node_type = "cache.t3.micro"
      num_cache_nodes = 1
      port = 6379
      
      # Network configuration
      security_group_ids = [dependency.security_groups.outputs.security_group_ids["cache-sg"]]
      subnet_group_name = dependency.vpc.outputs.elasticache_subnet_group_name
      
      # Security and encryption
      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
      kms_key_id = dependency.kms.outputs.key_arns["staging-elasticache-key"]
      
      # Backup and maintenance
      snapshot_retention_limit = 7
      snapshot_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      auto_minor_version_upgrade = true
      
      # High availability (multi-AZ for staging)
      multi_az_enabled = true
      automatic_failover_enabled = true
      replication_group_id = "client-b-staging-redis-repl"
      num_cache_clusters = 2
      
      # Parameter group
      parameter_group_name = "client-b-staging-redis-7-0"
      parameter_group_family = "redis7"
    }
    
    # Parameter group settings
    parameter_group_settings = {
      "maxmemory-policy" = "allkeys-lru"
      "notify-keyspace-events" = "Ex"
      "slowlog-log-slower-than" = "10000"
      "slowlog-max-len" = "128"
    }
    
    # Subnet group configuration
    subnet_group_config = {
      name = "client-b-staging-redis-subnet-group"
      description = "Subnet group for Client B staging Redis cluster"
      subnet_ids = dependency.vpc.outputs.elasticache_subnet_ids
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Caching"
  }
} 