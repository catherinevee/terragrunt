# ==============================================================================
# ElastiCache Module Configuration for Client B - Development Environment (eu-west-2)
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
  source = "git::https://github.com/catherinevee/tfm-aws-elasticache.git//?ref=v1.0.0"
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

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "ElastiCache - Development (eu-west-2)"
  
  elasticache_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "ElastiCache"
    create_elasticache_clusters = true
    
    elasticache_clusters = {
      "dev-ecommerce-cache" = {
        cluster_id = "client-b-dev-ecommerce-cache"
        engine = "redis"
        node_type = "cache.t3.micro"
        num_cache_nodes = 1
        parameter_group_name = "default.redis7"
        port = 6379
        
        security_group_ids = [dependency.security_groups.outputs.security_group_ids["cache-sg"]]
        subnet_group_name = dependency.vpc.outputs.elasticache_subnet_group_name
        
        at_rest_encryption_enabled = true
        transit_encryption_enabled = false  # Disabled for dev to reduce complexity
        kms_key_id = dependency.kms.outputs.key_arns["dev-elasticache-key"]
        
        automatic_failover_enabled = false  # Disabled for dev to reduce costs
        multi_az_enabled = false  # Disabled for dev to reduce costs
        
        maintenance_window = "sun:05:00-sun:06:00"
        snapshot_window = "04:00-05:00"
        snapshot_retention_limit = 7
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Cache"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
    
    subnet_groups = {
      "dev-cache-subnet-group" = {
        name = "client-b-dev-cache-subnet-group"
        description = "ElastiCache subnet group for development environment"
        subnet_ids = dependency.vpc.outputs.elasticache_subnet_ids
        tags = {
          Environment = "Development"
          Purpose     = "Cache Subnet Group"
          Owner       = "DevOps Team"
        }
      }
    }
    
    parameter_groups = {
      "dev-redis-params" = {
        name = "client-b-dev-redis-params"
        family = "redis7"
        description = "Redis parameter group for development environment"
        parameters = [
          {
            name = "maxmemory-policy"
            value = "allkeys-lru"
          },
          {
            name = "notify-keyspace-events"
            value = "Ex"
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Redis Parameters"
          Owner       = "DevOps Team"
        }
      }
    }
    
    replication_groups = {
      "dev-ecommerce-replication" = {
        replication_group_id = "client-b-dev-ecommerce-replication"
        description = "Redis replication group for ecommerce development environment"
        node_type = "cache.t3.micro"
        port = 6379
        parameter_group_name = "client-b-dev-redis-params"
        
        security_group_ids = [dependency.security_groups.outputs.security_group_ids["cache-sg"]]
        subnet_group_name = dependency.vpc.outputs.elasticache_subnet_group_name
        
        at_rest_encryption_enabled = true
        transit_encryption_enabled = false
        kms_key_id = dependency.kms.outputs.key_arns["dev-elasticache-key"]
        
        automatic_failover_enabled = false
        multi_az_enabled = false
        
        num_cache_clusters = 1  # Single node for dev
        
        maintenance_window = "sun:05:00-sun:06:00"
        snapshot_window = "04:00-05:00"
        snapshot_retention_limit = 7
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Cache Replication"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 