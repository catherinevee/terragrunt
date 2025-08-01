# ==============================================================================
# SNS Module Configuration for Client B - Development Environment (eu-west-2)
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
  project     = "SNS Notifications - Development (eu-west-2)"
  
  sns_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "SNS Notifications"
    create_sns_topics = true
    
    sns_topics = {
      "dev-general-notifications" = {
        name = "ClientBDevGeneralNotifications"
        display_name = "ClientB Development General Notifications"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "General Notifications"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-security-alerts" = {
        name = "ClientBDevSecurityAlerts"
        display_name = "ClientB Development Security Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "Security Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-ecommerce-alerts" = {
        name = "ClientBDevEcommerceAlerts"
        display_name = "ClientB Development Ecommerce Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-monitoring-alerts" = {
        name = "ClientBDevMonitoringAlerts"
        display_name = "ClientB Development Monitoring Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "Monitoring Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-application-alerts" = {
        name = "ClientBDevApplicationAlerts"
        display_name = "ClientB Development Application Alerts"
        kms_master_key_id = null
        delivery_policy = null
        policy = null
        tags = {
          Environment = "Development"
          Purpose     = "Application Alerts"
          Owner       = "DevOps Team"
        }
      }
    }
    
    sns_subscriptions = {
      "dev-general-email" = {
        topic_arn = "dev-general-notifications"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "dev-security-email" = {
        topic_arn = "dev-security-alerts"
        protocol = "email"
        endpoint = "security@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "dev-ecommerce-email" = {
        topic_arn = "dev-ecommerce-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "dev-monitoring-email" = {
        topic_arn = "dev-monitoring-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        delivery_policy = null
        filter_policy = null
        raw_message_delivery = false
        redrive_policy = null
        subscription_role_arn = null
      }
      
      "dev-application-email" = {
        topic_arn = "dev-application-alerts"
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
      "dev-general-notifications" = {
        topic_arn = "dev-general-notifications"
        policy = null  # Use default policy
      }
      "dev-security-alerts" = {
        topic_arn = "dev-security-alerts"
        policy = null  # Use default policy
      }
      "dev-ecommerce-alerts" = {
        topic_arn = "dev-ecommerce-alerts"
        policy = null  # Use default policy
      }
      "dev-monitoring-alerts" = {
        topic_arn = "dev-monitoring-alerts"
        policy = null  # Use default policy
      }
      "dev-application-alerts" = {
        topic_arn = "dev-application-alerts"
        policy = null  # Use default policy
      }
    }
    
    dead_letter_queues = {
      "dev-dlq" = {
        name = "ClientBDevSNSDLQ"
        visibility_timeout_seconds = 30
        message_retention_seconds = 1209600
        delay_seconds = 0
        receive_wait_time_seconds = 0
        tags = {
          Environment = "Development"
          Purpose     = "SNS Dead Letter Queue"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 