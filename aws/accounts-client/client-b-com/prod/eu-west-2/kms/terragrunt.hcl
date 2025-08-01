# ==============================================================================
# KMS Module Configuration for Client B - Production Environment (eu-west-2)
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
  source = "https://github.com/catherinevee/tfm-aws-kms//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # KMS Keys Configuration
  keys = {
    "prod-general-key" = {
      description = "General purpose KMS key for production environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 30
      alias = "alias/client-b-prod-general"
    }
    
    "prod-s3-key" = {
      description = "KMS key for S3 encryption in production environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 30
      alias = "alias/client-b-prod-s3"
    }
    
    "prod-rds-key" = {
      description = "KMS key for RDS encryption in production environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 30
      alias = "alias/client-b-prod-rds"
    }
    
    "prod-elasticache-key" = {
      description = "KMS key for ElastiCache encryption in production environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 30
      alias = "alias/client-b-prod-elasticache"
    }
    
    "prod-cloudwatch-key" = {
      description = "KMS key for CloudWatch logs encryption in production environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 30
      alias = "alias/client-b-prod-cloudwatch"
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Encryption Keys"
  }
} 