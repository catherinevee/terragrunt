# ==============================================================================
# SNS Module Configuration for Client B - Production Environment
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
  source = "git::https://github.com/catherinevee/tfm-aws-sns.git//?ref=v1.0.0"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "SNS Notifications - Production"
  
  sns_config = {
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "SNS Notifications"
    create_sns_topics = true
    
    sns_topics = {
      "prod-general-notifications" = {
        name = "ClientBProdGeneralNotifications"
        display_name = "ClientB Production General Notifications"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "General Notifications"
          Owner       = "DevOps Team"
        }
      }
      
      "prod-security-alerts" = {
        name = "ClientBProdSecurityAlerts"
        display_name = "ClientB Production Security Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "Security Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "prod-budget-alerts" = {
        name = "ClientBProdBudgetAlerts"
        display_name = "ClientB Production Budget Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "Budget Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "prod-monitoring-alerts" = {
        name = "ClientBProdMonitoringAlerts"
        display_name = "ClientB Production Monitoring Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "Monitoring Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "prod-application-alerts" = {
        name = "ClientBProdApplicationAlerts"
        display_name = "ClientB Production Application Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Production"
          Purpose     = "Application Alerts"
          Owner       = "DevOps Team"
        }
      }
    }
    
    sns_subscriptions = {
      "prod-general-email" = {
        topic_arn = "prod-general-notifications"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "prod-security-email" = {
        topic_arn = "prod-security-alerts"
        protocol = "email"
        endpoint = "security@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "prod-budget-email" = {
        topic_arn = "prod-budget-alerts"
        protocol = "email"
        endpoint = "finance@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "prod-monitoring-email" = {
        topic_arn = "prod-monitoring-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "prod-application-email" = {
        topic_arn = "prod-application-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
    }
    
    topic_policies = {
      "prod-general-notifications" = {
        topic_arn = "prod-general-notifications"
        policy = null  # Use default policy
      }
      "prod-security-alerts" = {
        topic_arn = "prod-security-alerts"
        policy = null  # Use default policy
      }
      "prod-budget-alerts" = {
        topic_arn = "prod-budget-alerts"
        policy = null  # Use default policy
      }
      "prod-monitoring-alerts" = {
        topic_arn = "prod-monitoring-alerts"
        policy = null  # Use default policy
      }
      "prod-application-alerts" = {
        topic_arn = "prod-application-alerts"
        policy = null  # Use default policy
      }
    }
    
    dead_letter_queues = {
      "prod-dlq" = {
        name = "ClientBProdSNSDLQ"
        visibility_timeout_seconds = 30
        message_retention_seconds = 1209600
        delay_seconds = 0
        receive_wait_time_seconds = 0
        tags = {
          Environment = "Production"
          Purpose     = "SNS Dead Letter Queue"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 