# ==============================================================================
# Security Hub Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

# Dependencies
dependency "kms" {
  config_path = "../kms"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/securityhub.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Security Hub - Development"
  
  # Security Hub configuration for development environment
  securityhub_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Security Hub"
    
    # Security Hub configuration
    securityhub = {
      enable_default_standards = true
      enable_default_findings = true
      
      # Tags
      tags = {
        Name = "client-b-dev-securityhub"
        Purpose = "Security Findings Aggregation"
        Environment = "Development"
        Service = "SecurityHub"
      }
    }
    
    # Security standards
    security_standards = {
      # CIS AWS Foundations Benchmark
      cis_aws_foundations = {
        name = "cis-aws-foundations-benchmark"
        description = "CIS AWS Foundations Benchmark v1.4.0"
        enabled = true
        controls_to_disable = [
          "CIS.1.1",  # Disable specific controls if needed
          "CIS.1.2"
        ]
      }
      
      # AWS Foundational Security Best Practices
      aws_foundational_security = {
        name = "aws-foundational-security-best-practices"
        description = "AWS Foundational Security Best Practices v1.0.0"
        enabled = true
        controls_to_disable = []
      }
      
      # PCI DSS
      pci_dss = {
        name = "pci-dss"
        description = "Payment Card Industry Data Security Standard v3.2.1"
        enabled = false  # Disabled for dev environment
        controls_to_disable = []
      }
      
      # SOC 2
      soc_2 = {
        name = "soc-2"
        description = "SOC 2 Type II"
        enabled = false  # Disabled for dev environment
        controls_to_disable = []
      }
    }
    
    # Product integrations
    product_integrations = {
      # GuardDuty integration
      guardduty = {
        product_arn = "arn:aws:securityhub:us-east-1::product/aws/guardduty"
        enable = true
      }
      
      # Inspector integration
      inspector = {
        product_arn = "arn:aws:securityhub:us-east-1::product/aws/inspector"
        enable = true
      }
      
      # Macie integration
      macie = {
        product_arn = "arn:aws:securityhub:us-east-1::product/aws/macie"
        enable = true
      }
      
      # IAM Access Analyzer integration
      iam_access_analyzer = {
        product_arn = "arn:aws:securityhub:us-east-1::product/aws/access-analyzer"
        enable = true
      }
      
      # Systems Manager integration
      systems_manager = {
        product_arn = "arn:aws:securityhub:us-east-1::product/aws/systems-manager"
        enable = true
      }
    }
    
    # Custom actions
    custom_actions = {
      # High severity findings action
      high_severity_action = {
        name = "HighSeverityFindingsAction"
        description = "Custom action for high severity findings"
        action_name = "high-severity-findings-action"
        action_description = "Action to take when high severity findings are detected"
        action_type = "CUSTOM"
      }
      
      # Compliance violation action
      compliance_violation_action = {
        name = "ComplianceViolationAction"
        description = "Custom action for compliance violations"
        action_name = "compliance-violation-action"
        action_description = "Action to take when compliance violations are detected"
        action_type = "CUSTOM"
      }
    }
    
    # SNS topic configuration for findings
    sns_topic = {
      name = "client-b-dev-securityhub-findings"
      display_name = "Client B Development Security Hub Findings"
      kms_master_key_id = dependency.kms.outputs.security_hub_kms_key_id
      
      subscriptions = {
        security_email = {
          protocol = "email"
          endpoint = "security@clientb.com"
        }
        devops_email = {
          protocol = "email"
          endpoint = "devops@clientb.com"
        }
        compliance_email = {
          protocol = "email"
          endpoint = "compliance@clientb.com"
        }
      }
      
      tags = {
        Name = "client-b-dev-securityhub-findings"
        Purpose = "Security Hub Findings"
        Environment = "Development"
        Service = "SecurityHub"
      }
    }
    
    # CloudWatch event rules
    cloudwatch_events = {
      # High severity findings rule
      high_severity_findings = {
        name = "client-b-dev-securityhub-high-severity"
        description = "Triggered when Security Hub detects high severity findings"
        
        event_pattern = jsonencode({
          source = ["aws.securityhub"]
          detail-type = ["Security Hub Findings - Imported"]
          detail = {
            findings = {
              severity = {
                label = ["HIGH"]
              }
            }
          }
        })
        
        target = {
          arn = "arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"
          role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/SecurityHubEventsRole"
        }
      }
      
      # Failed compliance checks rule
      failed_compliance_checks = {
        name = "client-b-dev-securityhub-failed-compliance"
        description = "Triggered when Security Hub detects failed compliance checks"
        
        event_pattern = jsonencode({
          source = ["aws.securityhub"]
          detail-type = ["Security Hub Findings - Imported"]
          detail = {
            findings = {
              compliance = {
                status = ["FAILED"]
              }
            }
          }
        })
        
        target = {
          arn = "arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"
          role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/SecurityHubEventsRole"
        }
      }
    }
    
    # IAM role for CloudWatch Events
    iam_role = {
      name = "SecurityHubEventsRole"
      description = "Role for CloudWatch Events to publish Security Hub findings to SNS"
      
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
            Action = "sts:AssumeRole"
          }
        ]
      })
      
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/CloudWatchEventsBuiltInTargetExecutionAccess"
      ]
      
      tags = {
        Name = "SecurityHubEventsRole"
        Purpose = "Security Hub Events Execution"
        Environment = "Development"
        Service = "SecurityHub"
      }
    }
    
    # CloudWatch alarms
    cloudwatch_alarms = {
      # High severity findings alarm
      high_severity_findings = {
        name = "client-b-dev-securityhub-high-severity-findings"
        description = "Alarm for high severity Security Hub findings"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 1
        metric_name = "HighSeverityFindings"
        namespace = "AWS/SecurityHub"
        period = 300
        statistic = "Sum"
        threshold = 0
        alarm_description = "High severity Security Hub findings detected"
        alarm_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"]
        ok_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"]
        
        tags = {
          Name = "client-b-dev-securityhub-high-severity-findings"
          Purpose = "Security Hub Monitoring"
          Environment = "Development"
          Service = "SecurityHub"
        }
      }
      
      # Failed compliance checks alarm
      failed_compliance_checks = {
        name = "client-b-dev-securityhub-failed-compliance"
        description = "Alarm for failed Security Hub compliance checks"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "FailedComplianceChecks"
        namespace = "AWS/SecurityHub"
        period = 300
        statistic = "Sum"
        threshold = 5
        alarm_description = "Multiple failed Security Hub compliance checks detected"
        alarm_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"]
        ok_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-securityhub-findings"]
        
        tags = {
          Name = "client-b-dev-securityhub-failed-compliance"
          Purpose = "Security Hub Monitoring"
          Environment = "Development"
          Service = "SecurityHub"
        }
      }
    }
    
    # Insights
    insights = {
      # High severity findings insight
      high_severity_insight = {
        name = "HighSeverityFindings"
        description = "Insight for high severity findings"
        filters = {
          severity_label = {
            eq = ["HIGH"]
          }
        }
        group_by_attribute = "severity_label"
      }
      
      # Failed compliance checks insight
      failed_compliance_insight = {
        name = "FailedComplianceChecks"
        description = "Insight for failed compliance checks"
        filters = {
          compliance_status = {
            eq = ["FAILED"]
          }
        }
        group_by_attribute = "compliance_status"
      }
      
      # Resource type insight
      resource_type_insight = {
        name = "FindingsByResourceType"
        description = "Insight for findings by resource type"
        filters = {
          resource_type = {
            neq = [""]
          }
        }
        group_by_attribute = "resource_type"
      }
    }
  }
  
  # Tags for all Security Hub resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    SecurityLevel = "High"
  }
} 