include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  ecs_config   = local.account_vars.locals.ecs_config
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
  }
} 