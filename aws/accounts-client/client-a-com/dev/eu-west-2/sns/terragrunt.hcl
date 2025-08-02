# ==============================================================================
# SNS Module Configuration for Client A - Development Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
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
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "SNS Notifications - Development (eu-west-2)"
  
  # SNS configuration for development environment
  sns_config = {
    # SNS topics configuration
    topics = {
      # Alerts topic for critical notifications
      alerts = {
        name = "client-a-dev-alerts"
        display_name = "Client A Development Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Critical Alerts"
          Environment = "Development"
          Priority = "High"
        }
        subscriptions = {
          devops_email = {
            protocol = "email"
            endpoint = "devops@clienta.com"
            filter_policy = jsonencode({
              severity = ["critical", "high"]
            })
          }
          dev_team_email = {
            protocol = "email"
            endpoint = "dev-team@clienta.com"
            filter_policy = jsonencode({
              severity = ["critical", "high", "medium"]
            })
          }
        }
      }
      
      # Monitoring topic for general monitoring notifications
      monitoring = {
        name = "client-a-dev-monitoring"
        display_name = "Client A Development Monitoring"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Monitoring Notifications"
          Environment = "Development"
          Priority = "Medium"
        }
        subscriptions = {
          devops_email = {
            protocol = "email"
            endpoint = "devops@clienta.com"
            filter_policy = jsonencode({
              service = ["rds", "elasticache", "alb", "ec2"]
            })
          }
        }
      }
      
      # Budget topic for cost notifications
      budget = {
        name = "client-a-dev-budget"
        display_name = "Client A Development Budget Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Budget Alerts"
          Environment = "Development"
          Priority = "High"
        }
        subscriptions = {
          finance_email = {
            protocol = "email"
            endpoint = "finance@clienta.com"
          }
          devops_email = {
            protocol = "email"
            endpoint = "devops@clienta.com"
          }
        }
      }
      
      # Security topic for security-related notifications
      security = {
        name = "client-a-dev-security"
        display_name = "Client A Development Security Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Security Alerts"
          Environment = "Development"
          Priority = "Critical"
        }
        subscriptions = {
          security_email = {
            protocol = "email"
            endpoint = "security@clienta.com"
          }
          devops_email = {
            protocol = "email"
            endpoint = "devops@clienta.com"
          }
        }
      }
    }
    
    # Tags for all SNS resources
    tags = {
      Environment = "Development"
      Project     = "Client A Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Internal"
      Client      = "Client A"
    }
  }
} 