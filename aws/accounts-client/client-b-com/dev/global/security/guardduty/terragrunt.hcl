# ==============================================================================
# GuardDuty Security Module Configuration for Client B - Development Environment
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
  source = "git::https://github.com/catherinevee/guardduty.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "GuardDuty Security - Development"
  
  # GuardDuty security configuration for development environment
  guardduty_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "GuardDuty Security"
    
    # GuardDuty detector configuration
    detector = {
      name = "client-b-dev-guardduty"
      enable = true
      
      # Finding publishing frequency
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      
      # Tags
      tags = {
        Name = "client-b-dev-guardduty"
        Purpose = "Threat Detection"
        Environment = "Development"
        Service = "GuardDuty"
      }
    }
    
    # Data sources configuration
    data_sources = {
      # S3 protection
      s3_protection = {
        enable = true
        auto_enable = true
      }
      
      # EKS protection
      eks_protection = {
        enable = true
        auto_enable = true
      }
      
      # Malware protection
      malware_protection = {
        enable = true
        auto_enable = true
        scan_ec2_instance_with_findings = {
          ebs_volumes = {
            enable = true
          }
        }
      }
      
      # RDS protection
      rds_protection = {
        enable = true
        auto_enable = true
      }
      
      # Lambda protection
      lambda_protection = {
        enable = true
        auto_enable = true
      }
    }
    
    # Threat lists configuration
    threat_lists = {
      # Custom threat list
      custom_threat_list = {
        name = "client-b-dev-custom-threats"
        format = "TXT"
        location = "https://clientb.com/threats/custom-threat-list.txt"
        tags = {
          Name = "client-b-dev-custom-threats"
          Purpose = "Custom Threat Intelligence"
          Environment = "Development"
        }
      }
    }
    
    # Filters configuration
    filters = {
      # High severity findings filter
      high_severity = {
        name = "high-severity-findings"
        description = "Filter for high severity findings"
        action = "ARCHIVE"
        rank = 1
        
        finding_criteria = {
          criterion = {
            severity = {
              eq = ["HIGH"]
            }
          }
        }
      }
      
      # False positive filter
      false_positives = {
        name = "false-positive-findings"
        description = "Filter for known false positives"
        action = "ARCHIVE"
        rank = 2
        
        finding_criteria = {
          criterion = {
            finding_type = {
              eq = ["Recon:EC2/PortProbeUnprotectedPort"]
            }
            service_name = {
              eq = ["guardduty"]
            }
          }
        }
      }
    }
    
    # SNS topic configuration for findings
    sns_topic = {
      name = "client-b-dev-guardduty-findings"
      display_name = "Client B Development GuardDuty Findings"
      kms_master_key_id = dependency.kms.outputs.guardduty_kms_key_id
      
      subscriptions = {
        security_email = {
          protocol = "email"
          endpoint = "security@clientb.com"
        }
        devops_email = {
          protocol = "email"
          endpoint = "devops@clientb.com"
        }
        soc_email = {
          protocol = "email"
          endpoint = "soc@clientb.com"
        }
      }
      
      tags = {
        Name = "client-b-dev-guardduty-findings"
        Purpose = "GuardDuty Findings"
        Environment = "Development"
        Service = "GuardDuty"
      }
    }
    
    # CloudWatch event rules
    cloudwatch_events = {
      # High severity findings rule
      high_severity_findings = {
        name = "client-b-dev-guardduty-high-severity"
        description = "Triggered when GuardDuty detects high severity findings"
        
        event_pattern = jsonencode({
          source = ["aws.guardduty"]
          detail-type = ["GuardDuty Finding"]
          detail = {
            severity = ["HIGH"]
          }
        })
        
        target = {
          arn = "arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"
          role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/CloudWatchEventsRole"
        }
      }
      
      # Medium severity findings rule
      medium_severity_findings = {
        name = "client-b-dev-guardduty-medium-severity"
        description = "Triggered when GuardDuty detects medium severity findings"
        
        event_pattern = jsonencode({
          source = ["aws.guardduty"]
          detail-type = ["GuardDuty Finding"]
          detail = {
            severity = ["MEDIUM"]
          }
        })
        
        target = {
          arn = "arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"
          role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/CloudWatchEventsRole"
        }
      }
    }
    
    # IAM role for CloudWatch Events
    iam_role = {
      name = "CloudWatchEventsRole"
      description = "Role for CloudWatch Events to publish to SNS"
      
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
        Name = "CloudWatchEventsRole"
        Purpose = "CloudWatch Events Execution"
        Environment = "Development"
        Service = "GuardDuty"
      }
    }
    
    # CloudWatch alarms
    cloudwatch_alarms = {
      # High severity findings alarm
      high_severity_findings = {
        name = "client-b-dev-guardduty-high-severity-findings"
        description = "Alarm for high severity GuardDuty findings"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 1
        metric_name = "HighSeverityFindings"
        namespace = "AWS/GuardDuty"
        period = 300
        statistic = "Sum"
        threshold = 0
        alarm_description = "High severity GuardDuty findings detected"
        alarm_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"]
        ok_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"]
        
        tags = {
          Name = "client-b-dev-guardduty-high-severity-findings"
          Purpose = "GuardDuty Monitoring"
          Environment = "Development"
          Service = "GuardDuty"
        }
      }
      
      # Total findings alarm
      total_findings = {
        name = "client-b-dev-guardduty-total-findings"
        description = "Alarm for total GuardDuty findings"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "TotalFindings"
        namespace = "AWS/GuardDuty"
        period = 300
        statistic = "Sum"
        threshold = 10
        alarm_description = "High number of GuardDuty findings detected"
        alarm_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"]
        ok_actions = ["arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-guardduty-findings"]
        
        tags = {
          Name = "client-b-dev-guardduty-total-findings"
          Purpose = "GuardDuty Monitoring"
          Environment = "Development"
          Service = "GuardDuty"
        }
      }
    }
  }
  
  # Tags for all GuardDuty security resources
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