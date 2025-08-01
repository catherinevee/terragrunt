# ==============================================================================
# SNS Module Configuration for Client B - Staging Environment
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
  project     = "SNS Notifications - Staging"
  
  sns_config = {
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "SNS Notifications"
    create_sns_topics = true
    
    sns_topics = {
      "staging-general-notifications" = {
        name = "ClientBStagingGeneralNotifications"
        display_name = "ClientB Staging General Notifications"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "General Notifications"
          Owner       = "DevOps Team"
        }
      }
      
      "staging-security-alerts" = {
        name = "ClientBStagingSecurityAlerts"
        display_name = "ClientB Staging Security Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "Security Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "staging-budget-alerts" = {
        name = "ClientBStagingBudgetAlerts"
        display_name = "ClientB Staging Budget Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "Budget Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "staging-monitoring-alerts" = {
        name = "ClientBStagingMonitoringAlerts"
        display_name = "ClientB Staging Monitoring Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "Monitoring Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "staging-application-alerts" = {
        name = "ClientBStagingApplicationAlerts"
        display_name = "ClientB Staging Application Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Staging"
          Purpose     = "Application Alerts"
          Owner       = "DevOps Team"
        }
      }
    }
    
    sns_subscriptions = {
      "staging-general-email" = {
        topic_arn = "staging-general-notifications"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "staging-security-email" = {
        topic_arn = "staging-security-alerts"
        protocol = "email"
        endpoint = "security@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "staging-budget-email" = {
        topic_arn = "staging-budget-alerts"
        protocol = "email"
        endpoint = "finance@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "staging-monitoring-email" = {
        topic_arn = "staging-monitoring-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "staging-application-email" = {
        topic_arn = "staging-application-alerts"
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
      "staging-general-notifications" = {
        topic_arn = "staging-general-notifications"
        policy = null  # Use default policy
      }
      "staging-security-alerts" = {
        topic_arn = "staging-security-alerts"
        policy = null  # Use default policy
      }
      "staging-budget-alerts" = {
        topic_arn = "staging-budget-alerts"
        policy = null  # Use default policy
      }
      "staging-monitoring-alerts" = {
        topic_arn = "staging-monitoring-alerts"
        policy = null  # Use default policy
      }
      "staging-application-alerts" = {
        topic_arn = "staging-application-alerts"
        policy = null  # Use default policy
      }
    }
    
    dead_letter_queues = {
      "staging-dlq" = {
        name = "ClientBStagingSNSDLQ"
        visibility_timeout_seconds = 30
        message_retention_seconds = 1209600
        delay_seconds = 0
        receive_wait_time_seconds = 0
        tags = {
          Environment = "Staging"
          Purpose     = "SNS Dead Letter Queue"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 