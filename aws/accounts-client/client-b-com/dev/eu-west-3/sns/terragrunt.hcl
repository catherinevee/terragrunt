# ==============================================================================
# SNS Module Configuration for Client B - Development Environment (eu-west-3)
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
  source = "git::https://github.com/catherinevee/sns.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "SNS Notifications - Development"
  
  # SNS configuration for development environment
  sns_config = {
    # SNS topics configuration
    topics = {
      # Alerts topic for critical notifications
      alerts = {
        name = "client-b-dev-alerts"
        display_name = "Client B Development Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Critical Alerts"
          Environment = "Development"
          Priority = "High"
        }
        subscriptions = {
          devops_email = {
            protocol = "email"
            endpoint = "devops@clientb.com"
            filter_policy = jsonencode({
              severity = ["critical", "high"]
            })
          }
          dev_team_email = {
            protocol = "email"
            endpoint = "dev-team@clientb.com"
            filter_policy = jsonencode({
              severity = ["critical", "high", "medium"]
            })
          }
        }
      }
      
      # Monitoring topic for general monitoring notifications
      monitoring = {
        name = "client-b-dev-monitoring"
        display_name = "Client B Development Monitoring"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Monitoring Notifications"
          Environment = "Development"
          Priority = "Medium"
        }
        subscriptions = {
          devops_email = {
            protocol = "email"
            endpoint = "devops@clientb.com"
            filter_policy = jsonencode({
              service = ["rds", "elasticache", "alb", "ec2"]
            })
          }
        }
      }
      
      # Budget topic for cost notifications
      budget = {
        name = "client-b-dev-budget"
        display_name = "Client B Development Budget Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Budget Alerts"
          Environment = "Development"
          Priority = "High"
        }
        subscriptions = {
          finance_email = {
            protocol = "email"
            endpoint = "finance@clientb.com"
          }
          devops_email = {
            protocol = "email"
            endpoint = "devops@clientb.com"
          }
        }
      }
      
      # Security topic for security-related notifications
      security = {
        name = "client-b-dev-security"
        display_name = "Client B Development Security Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Security Alerts"
          Environment = "Development"
          Priority = "Critical"
        }
        subscriptions = {
          security_email = {
            protocol = "email"
            endpoint = "security@clientb.com"
          }
          devops_email = {
            protocol = "email"
            endpoint = "devops@clientb.com"
          }
        }
      }
    }
    
    # Tags for all SNS resources
    tags = {
      Environment = "Development"
      Project     = "Client B Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Internal"
    }
  }
} 