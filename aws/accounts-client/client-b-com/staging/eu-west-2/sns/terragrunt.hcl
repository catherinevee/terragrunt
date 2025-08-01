# ==============================================================================
# SNS Module Configuration for Client B - Staging Environment (eu-west-2)
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
  source = "https://github.com/catherinevee/tfm-aws-sns//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # SNS Topics Configuration
  topics = {
    "staging-general-alerts" = {
      display_name = "Client B Staging General Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "devops@client-b.com"
        }
      ]
    }
    
    "staging-security-alerts" = {
      display_name = "Client B Staging Security Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "security@client-b.com"
        }
      ]
    }
    
    "staging-ecommerce-alerts" = {
      display_name = "Client B Staging E-commerce Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "ecommerce@client-b.com"
        }
      ]
    }
    
    "staging-monitoring-alerts" = {
      display_name = "Client B Staging Monitoring Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "monitoring@client-b.com"
        }
      ]
    }
    
    "staging-application-alerts" = {
      display_name = "Client B Staging Application Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "app-support@client-b.com"
        }
      ]
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Notifications"
  }
} 