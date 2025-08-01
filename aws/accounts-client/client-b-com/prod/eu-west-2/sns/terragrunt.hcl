# ==============================================================================
# SNS Module Configuration for Client B - Production Environment (eu-west-2)
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
    "prod-general-alerts" = {
      display_name = "Client B Production General Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "devops@client-b.com"
        },
        {
          protocol = "email"
          endpoint = "oncall@client-b.com"
        }
      ]
    }
    
    "prod-security-alerts" = {
      display_name = "Client B Production Security Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "security@client-b.com"
        },
        {
          protocol = "email"
          endpoint = "incident-response@client-b.com"
        }
      ]
    }
    
    "prod-ecommerce-alerts" = {
      display_name = "Client B Production E-commerce Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "ecommerce@client-b.com"
        },
        {
          protocol = "email"
          endpoint = "business-critical@client-b.com"
        }
      ]
    }
    
    "prod-monitoring-alerts" = {
      display_name = "Client B Production Monitoring Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "monitoring@client-b.com"
        },
        {
          protocol = "email"
          endpoint = "sre@client-b.com"
        }
      ]
    }
    
    "prod-application-alerts" = {
      display_name = "Client B Production Application Alerts"
      kms_master_key_id = "alias/aws/sns"
      subscriptions = [
        {
          protocol = "email"
          endpoint = "app-support@client-b.com"
        },
        {
          protocol = "email"
          endpoint = "engineering@client-b.com"
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