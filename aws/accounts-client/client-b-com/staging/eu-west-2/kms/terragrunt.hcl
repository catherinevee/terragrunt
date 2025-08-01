# ==============================================================================
# KMS Module Configuration for Client B - Staging Environment (eu-west-2)
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
    "staging-general-key" = {
      description = "General purpose KMS key for staging environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 7
      alias = "alias/client-b-staging-general"
    }
    
    "staging-s3-key" = {
      description = "KMS key for S3 encryption in staging environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 7
      alias = "alias/client-b-staging-s3"
    }
    
    "staging-rds-key" = {
      description = "KMS key for RDS encryption in staging environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 7
      alias = "alias/client-b-staging-rds"
    }
    
    "staging-elasticache-key" = {
      description = "KMS key for ElastiCache encryption in staging environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 7
      alias = "alias/client-b-staging-elasticache"
    }
    
    "staging-cloudwatch-key" = {
      description = "KMS key for CloudWatch logs encryption in staging environment"
      key_usage = "ENCRYPT_DECRYPT"
      customer_master_key_spec = "SYMMETRIC_DEFAULT"
      enable_key_rotation = true
      deletion_window_in_days = 7
      alias = "alias/client-b-staging-cloudwatch"
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