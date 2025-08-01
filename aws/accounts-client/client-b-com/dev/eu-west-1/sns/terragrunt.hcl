# ==============================================================================
# SNS Module Configuration for Client B - Development Environment
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
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "SNS Notifications - Development"
  
  # SNS specific configuration for development environment
  sns_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "SNS Notifications"
    
    # SNS topics configuration
    create_sns_topics = true
    sns_topics = {
      # General notifications topic
      "dev-general-notifications" = {
        name = "ClientBDevGeneralNotifications"
        display_name = "ClientB Development General Notifications"
        kms_master_key_id = null  # Will reference KMS key
        delivery_policy = null
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "General Notifications"
          Owner       = "DevOps Team"
        }
      }
      
      # Security alerts topic
      "dev-security-alerts" = {
        name = "ClientBDevSecurityAlerts"
        display_name = "ClientB Development Security Alerts"
        kms_master_key_id = null  # Will reference KMS key
        delivery_policy = null
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "Security Alerts"
          Owner       = "Security Team"
        }
      }
      
      # Budget alerts topic
      "dev-budget-alerts" = {
        name = "ClientBDevBudgetAlerts"
        display_name = "ClientB Development Budget Alerts"
        kms_master_key_id = null  # Will reference KMS key
        delivery_policy = null
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "Budget Alerts"
          Owner       = "Finance Team"
        }
      }
      
      # Monitoring alerts topic
      "dev-monitoring-alerts" = {
        name = "ClientBDevMonitoringAlerts"
        display_name = "ClientB Development Monitoring Alerts"
        kms_master_key_id = null  # Will reference KMS key
        delivery_policy = null
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "Monitoring Alerts"
          Owner       = "DevOps Team"
        }
      }
      
      # Application alerts topic
      "dev-application-alerts" = {
        name = "ClientBDevApplicationAlerts"
        display_name = "ClientB Development Application Alerts"
        kms_master_key_id = null  # Will reference KMS key
        delivery_policy = null
        policy = null  # Will use default policy
        
        tags = {
          Environment = "Development"
          Purpose     = "Application Alerts"
          Owner       = "Development Team"
        }
      }
    }
    
    # SNS subscriptions
    create_sns_subscriptions = true
    sns_subscriptions = {
      # General notifications subscriptions
      "dev-general-email" = {
        topic_arn = "dev-general-notifications"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      # Security alerts subscriptions
      "dev-security-email" = {
        topic_arn = "dev-security-alerts"
        protocol = "email"
        endpoint = "security@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      "dev-security-sms" = {
        topic_arn = "dev-security-alerts"
        protocol = "sms"
        endpoint = "+1234567890"  # Replace with actual phone number
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      # Budget alerts subscriptions
      "dev-budget-email" = {
        topic_arn = "dev-budget-alerts"
        protocol = "email"
        endpoint = "finance@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      "dev-budget-devops-email" = {
        topic_arn = "dev-budget-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      # Monitoring alerts subscriptions
      "dev-monitoring-email" = {
        topic_arn = "dev-monitoring-alerts"
        protocol = "email"
        endpoint = "devops@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
      
      # Application alerts subscriptions
      "dev-app-email" = {
        topic_arn = "dev-application-alerts"
        protocol = "email"
        endpoint = "developers@client-b.com"
        confirmation_timeout_in_minutes = 1
        raw_message_delivery = false
        filter_policy = null
        filter_policy_scope = null
        redrive_policy = null
      }
    }
    
    # Topic policies (optional - will use default if not specified)
    topic_policies = {
      # Example of a custom topic policy for development
      "dev-security-alerts" = {
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid = "AllowCloudWatchAlarms"
              Effect = "Allow"
              Principal = {
                Service = "cloudwatch.amazonaws.com"
              }
              Action = "SNS:Publish"
              Resource = "*"
              Condition = {
                StringEquals = {
                  "AWS:SourceAccount" = include.account.locals.account_id
                }
              }
            },
            {
              Sid = "AllowBudgetAlerts"
              Effect = "Allow"
              Principal = {
                Service = "budgets.amazonaws.com"
              }
              Action = "SNS:Publish"
              Resource = "*"
              Condition = {
                StringEquals = {
                  "AWS:SourceAccount" = include.account.locals.account_id
                }
              }
            }
          ]
        })
      }
    }
    
    # Dead letter queues (optional)
    create_dead_letter_queues = false
    dead_letter_queues = {}
  }
} 