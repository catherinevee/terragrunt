# ==============================================================================
# SNS Module Configuration for Client A - Production Environment (eu-west-2)
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
  project     = "SNS Notifications - Production (eu-west-2)"
  
  # SNS configuration for production environment
  sns_config = {
    # SNS topics configuration
    topics = {
      # Critical alerts topic
      critical_alerts = {
        name = "client-a-prod-critical-alerts"
        display_name = "Client A Production Critical Alerts"
        kms_master_key_id = "alias/aws/sns"  # Will be updated to use KMS module
        tags = {
          Purpose = "Critical Alerts"
          Environment = "Production"
          Priority = "Critical"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          oncall_email = {
            protocol = "email"
            endpoint = "oncall@clienta.com"
            filter_policy = jsonencode({
              severity = ["critical"]
            })
          }
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
            filter_policy = jsonencode({
              severity = ["critical", "high"]
            })
          }
          pagerduty = {
            protocol = "https"
            endpoint = "https://events.pagerduty.com/integration/xxx/xxx"
            filter_policy = jsonencode({
              severity = ["critical"]
            })
          }
        }
      }
      
      # High priority alerts topic
      high_alerts = {
        name = "client-a-prod-high-alerts"
        display_name = "Client A Production High Priority Alerts"
        kms_master_key_id = "alias/aws/sns"
        tags = {
          Purpose = "High Priority Alerts"
          Environment = "Production"
          Priority = "High"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
            filter_policy = jsonencode({
              severity = ["high"]
            })
          }
          dev_team_email = {
            protocol = "email"
            endpoint = "dev@clienta.com"
            filter_policy = jsonencode({
              severity = ["high"]
            })
          }
        }
      }
      
      # Monitoring topic
      monitoring = {
        name = "client-a-prod-monitoring"
        display_name = "Client A Production Monitoring"
        kms_master_key_id = "alias/aws/sns"
        tags = {
          Purpose = "Monitoring Notifications"
          Environment = "Production"
          Priority = "Medium"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
            filter_policy = jsonencode({
              service = ["rds", "elasticache", "alb", "ec2"]
            })
          }
          dev_team_email = {
            protocol = "email"
            endpoint = "dev@clienta.com"
            filter_policy = jsonencode({
              service = ["rds", "elasticache", "alb", "ec2"]
            })
          }
        }
      }
      
      # Budget topic
      budget = {
        name = "client-a-prod-budget"
        display_name = "Client A Production Budget Alerts"
        kms_master_key_id = "alias/aws/sns"
        tags = {
          Purpose = "Budget Alerts"
          Environment = "Production"
          Priority = "High"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          finance_email = {
            protocol = "email"
            endpoint = "finance@clienta.com"
          }
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
          }
          management_email = {
            protocol = "email"
            endpoint = "management@clienta.com"
          }
        }
      }
      
      # Security topic
      security = {
        name = "client-a-prod-security"
        display_name = "Client A Production Security Alerts"
        kms_master_key_id = "alias/aws/sns"
        tags = {
          Purpose = "Security Alerts"
          Environment = "Production"
          Priority = "Critical"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          security_email = {
            protocol = "email"
            endpoint = "security@clienta.com"
          }
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
          }
          pagerduty_security = {
            protocol = "https"
            endpoint = "https://events.pagerduty.com/integration/security/xxx"
            filter_policy = jsonencode({
              severity = ["critical", "high"]
            })
          }
        }
      }
      
      # Compliance topic
      compliance = {
        name = "client-a-prod-compliance"
        display_name = "Client A Production Compliance Alerts"
        kms_master_key_id = "alias/aws/sns"
        tags = {
          Purpose = "Compliance Alerts"
          Environment = "Production"
          Priority = "High"
          Compliance = "PCI-DSS"
        }
        subscriptions = {
          compliance_email = {
            protocol = "email"
            endpoint = "compliance@clienta.com"
          }
          legal_email = {
            protocol = "email"
            endpoint = "legal@clienta.com"
          }
          ops_team_email = {
            protocol = "email"
            endpoint = "ops@clienta.com"
          }
        }
      }
    }
    
    # Tags for all SNS resources
    tags = {
      Environment = "Production"
      Project     = "Client A Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Confidential"
      Client      = "Client A"
      Compliance  = "PCI-DSS"
    }
  }
} 