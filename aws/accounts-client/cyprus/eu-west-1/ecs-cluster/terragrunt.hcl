include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  ecs_config   = local.account_vars.locals.ecs_config
  
  # Input validation for ECS cluster module
  validate_cluster_name = length(local.ecs_config.cluster_name) <= 255 ? null : file("ERROR: ECS cluster name must be <= 255 characters")
  validate_cluster_name_format = can(regex("^[a-zA-Z0-9_-]+$", local.ecs_config.cluster_name)) ? null : file("ERROR: ECS cluster name must contain only alphanumeric characters, hyphens, and underscores")
  validate_cluster_name_start = can(regex("^[a-zA-Z]", local.ecs_config.cluster_name)) ? null : file("ERROR: ECS cluster name must start with a letter")
}

terraform {
  source = "tfr://terraform-aws-modules/ecs/aws//modules/cluster?version=5.7.4"
}

inputs = {
  cluster_name = local.ecs_config.cluster_name
  
  # Cluster configuration
  cluster_settings = {
    name  = "containerInsights"
    value = "enabled"
  }
  
  # Capacity providers
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "container-orchestration"
  }
} 