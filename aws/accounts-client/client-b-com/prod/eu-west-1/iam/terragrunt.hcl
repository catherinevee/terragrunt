# ==============================================================================
# IAM Module Configuration for Client B - Production Environment
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
  source = "git::https://github.com/catherinevee/iam.git//?ref=v1.0.0"
}

# Dependencies (uncomment and configure as needed)
# dependency "vpc" {
#   config_path = "../network"
# }
# 
# dependency "s3" {
#   config_path = "../storage"
# }

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "IAM Management - Production"
  
  # IAM specific configuration for production environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # DevOps team users
      "devops-admin" = {
        username = "devops-admin"
        path     = "/users/devops/"
        groups   = ["DevOpsAdmins", "SystemAdministrators"]
        tags = {
          Role        = "DevOps Administrator"
          Department  = "IT"
          AccessLevel = "Admin"
        }
      }
      
      "devops-engineer" = {
        username = "devops-engineer"
        path     = "/users/devops/"
        groups   = ["DevOpsEngineers", "SystemOperators"]
        tags = {
          Role        = "DevOps Engineer"
          Department  = "IT"
          AccessLevel = "Operator"
        }
      }
      
      # Application users
      "app-service-account" = {
        username = "app-service-account"
        path     = "/users/applications/"
        groups   = ["ApplicationUsers", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
        }
      }
      
      # Monitoring users
      "monitoring-user" = {
        username = "monitoring-user"
        path     = "/users/monitoring/"
        groups   = ["MonitoringUsers", "CloudWatchUsers"]
        tags = {
          Role        = "Monitoring User"
          Department  = "IT"
          AccessLevel = "ReadOnly"
        }
      }
      
      # Security users
      "security-admin" = {
        username = "security-admin"
        path     = "/users/security/"
        groups   = ["SecurityAdmins", "IAMAdmins"]
        tags = {
          Role        = "Security Administrator"
          Department  = "Security"
          AccessLevel = "Admin"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      # Administrative groups
      "SystemAdministrators" = {
        group_name = "SystemAdministrators"
        path       = "/groups/admin/"
        policies   = ["AdministratorAccess"]
        tags = {
          Purpose     = "System Administration"
          AccessLevel = "Full"
        }
      }
      
      "DevOpsAdmins" = {
        group_name = "DevOpsAdmins"
        path       = "/groups/devops/"
        policies   = ["PowerUserAccess", "IAMReadOnlyAccess"]
        tags = {
          Purpose     = "DevOps Administration"
          AccessLevel = "Power"
        }
      }
      
      "DevOpsEngineers" = {
        group_name = "DevOpsEngineers"
        path       = "/groups/devops/"
        policies   = ["PowerUserAccess"]
        tags = {
          Purpose     = "DevOps Engineering"
          AccessLevel = "Power"
        }
      }
      
      "SystemOperators" = {
        group_name = "SystemOperators"
        path       = "/groups/operations/"
        policies   = ["ReadOnlyAccess", "CloudWatchFullAccess"]
        tags = {
          Purpose     = "System Operations"
          AccessLevel = "ReadOnly"
        }
      }
      
      # Application groups
      "ApplicationUsers" = {
        group_name = "ApplicationUsers"
        path       = "/groups/applications/"
        policies   = ["ReadOnlyAccess"]
        tags = {
          Purpose     = "Application Access"
          AccessLevel = "ReadOnly"
        }
      }
      
      # Monitoring groups
      "MonitoringUsers" = {
        group_name = "MonitoringUsers"
        path       = "/groups/monitoring/"
        policies   = ["CloudWatchFullAccess", "CloudWatchLogsFullAccess"]
        tags = {
          Purpose     = "Monitoring Access"
          AccessLevel = "Monitoring"
        }
      }
      
      "CloudWatchUsers" = {
        group_name = "CloudWatchUsers"
        path       = "/groups/monitoring/"
        policies   = ["CloudWatchReadOnlyAccess"]
        tags = {
          Purpose     = "CloudWatch Access"
          AccessLevel = "ReadOnly"
        }
      }
      
      # Security groups
      "SecurityAdmins" = {
        group_name = "SecurityAdmins"
        path       = "/groups/security/"
        policies   = ["SecurityAudit", "IAMFullAccess"]
        tags = {
          Purpose     = "Security Administration"
          AccessLevel = "Security"
        }
      }
      
      "IAMAdmins" = {
        group_name = "IAMAdmins"
        path       = "/groups/security/"
        policies   = ["IAMFullAccess"]
        tags = {
          Purpose     = "IAM Administration"
          AccessLevel = "IAM"
        }
      }
    }
    
    # IAM role configuration
    create_iam_roles = true
    iam_roles = {
      # EC2 instance roles
      "ec2-instance-role" = {
        role_name = "EC2InstanceRole"
        path      = "/roles/ec2/"
        assume_role_policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "ec2.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        }
        policies = ["CloudWatchAgentServerPolicy", "SSMManagedInstanceCore"]
        tags = {
          Purpose     = "EC2 Instance Role"
          Service     = "EC2"
          AccessLevel = "Instance"
        }
      }
      
      # Lambda execution roles
      "lambda-execution-role" = {
        role_name = "LambdaExecutionRole"
        path      = "/roles/lambda/"
        assume_role_policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "lambda.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        }
        policies = ["AWSLambdaBasicExecutionRole"]
        tags = {
          Purpose     = "Lambda Execution Role"
          Service     = "Lambda"
          AccessLevel = "Execution"
        }
      }
      
      # ECS task roles
      "ecs-task-role" = {
        role_name = "ECSTaskRole"
        path      = "/roles/ecs/"
        assume_role_policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "ecs-tasks.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        }
        policies = ["CloudWatchAgentServerPolicy"]
        tags = {
          Purpose     = "ECS Task Role"
          Service     = "ECS"
          AccessLevel = "Task"
        }
      }
      
      # Application load balancer role
      "alb-role" = {
        role_name = "ApplicationLoadBalancerRole"
        path      = "/roles/alb/"
        assume_role_policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "elasticloadbalancing.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        }
        policies = ["AWSElasticLoadBalancingServiceRolePolicy"]
        tags = {
          Purpose     = "ALB Service Role"
          Service     = "ALB"
          AccessLevel = "Service"
        }
      }
      
      # RDS proxy role
      "rds-proxy-role" = {
        role_name = "RDSProxyRole"
        path      = "/roles/rds/"
        assume_role_policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "rds.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        }
        policies = ["AmazonRDSFullAccess"]
        tags = {
          Purpose     = "RDS Proxy Role"
          Service     = "RDS"
          AccessLevel = "Service"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      # Custom application policy
      "application-access-policy" = {
        policy_name = "ApplicationAccessPolicy"
        path        = "/policies/applications/"
        description = "Custom policy for application access"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
              ]
              Resource = [
                "arn:aws:s3:::client-b-app-bucket",
                "arn:aws:s3:::client-b-app-bucket/*"
              ]
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan"
              ]
              Resource = "arn:aws:dynamodb:eu-west-1:987654321098:table/client-b-app-table"
            },
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
              ]
              Resource = "arn:aws:sqs:eu-west-1:987654321098:client-b-app-queue"
            }
          ]
        }
        tags = {
          Purpose     = "Application Access"
          Service     = "Custom"
          AccessLevel = "Application"
        }
      }
      
      # Database access policy
      "database-access-policy" = {
        policy_name = "DatabaseAccessPolicy"
        path        = "/policies/database/"
        description = "Custom policy for database access"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "rds:DescribeDBInstances",
                "rds:DescribeDBClusters",
                "rds:DescribeDBClusterParameters",
                "rds:DescribeDBParameters"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "rds-db:connect"
              ]
              Resource = "arn:aws:rds-db:eu-west-1:987654321098:dbuser:*/client-b-app-user"
            }
          ]
        }
        tags = {
          Purpose     = "Database Access"
          Service     = "RDS"
          AccessLevel = "Database"
        }
      }
      
      # Monitoring policy
      "monitoring-policy" = {
        policy_name = "MonitoringPolicy"
        path        = "/policies/monitoring/"
        description = "Custom policy for monitoring and alerting"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmHistory"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
              ]
              Resource = "arn:aws:logs:eu-west-1:987654321098:log-group:/aws/application/*"
            },
            {
              Effect = "Allow"
              Action = [
                "sns:Publish",
                "sns:Subscribe",
                "sns:ListSubscriptions"
              ]
              Resource = "arn:aws:sns:eu-west-1:987654321098:client-b-alerts"
            }
          ]
        }
        tags = {
          Purpose     = "Monitoring Access"
          Service     = "CloudWatch"
          AccessLevel = "Monitoring"
        }
      }
    }
    
    # Password policy configuration
    password_policy = {
      minimum_password_length = 12
      require_symbols = true
      require_numbers = true
      require_uppercase_characters = true
      require_lowercase_characters = true
      allow_users_to_change_password = true
      max_password_age = 90
      password_reuse_prevention = 24
      hard_expiry = false
    }
    
    # Account alias configuration
    account_alias = "client-b-prod"
    
    # MFA configuration
    require_mfa = true
    mfa_policy_name = "MFAPolicy"
    
    # Access key rotation
    enable_access_key_rotation = true
    access_key_rotation_days = 90
    
    # Session duration
    max_session_duration = 3600  # 1 hour for production
    
    # Security configurations
    enable_advanced_security_features = true
    enable_credential_report = true
    enable_access_analyzer = true
    enable_organizations_srp = true
  }
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "IAM Management"
    CostCenter  = "ClientB"
    Owner       = "Security Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Production IAM Management"
    DataClassification = "Confidential"
    Compliance  = "SOX"
    ProductionEnvironment = "Yes"
    CriticalSystem = "Yes"
    BusinessImpact = "High"
    SecurityLevel = "High"
  }
  
  # Production specific overrides
  production_overrides = {
    # Enhanced security for production
    enable_strict_password_policy = true
    enable_mfa_enforcement = true
    enable_session_timeout = true
    enable_least_privilege_access = true
    
    # Audit and compliance
    enable_detailed_audit_logging = true
    enable_access_reviews = true
    enable_privilege_escalation_monitoring = true
    enable_anomaly_detection = true
    
    # Monitoring and alerting
    enable_iam_monitoring = true
    enable_access_key_monitoring = true
    enable_role_assumption_monitoring = true
    enable_policy_changes_monitoring = true
    
    # Security hardening
    enable_credential_rotation = true
    enable_session_management = true
    enable_emergency_access = true
    enable_break_glass_procedures = true
    
    # Compliance configurations
    compliance_config = {
      enable_sox_compliance = true
      enable_pci_compliance = true
      enable_hipaa_compliance = false  # Enable if needed
      enable_gdpr_compliance = true
      
      # SOX compliance
      sox_compliance = {
        enable_segregation_of_duties = true
        enable_access_reviews = true
        enable_change_management = true
        enable_audit_trails = true
      }
      
      # PCI compliance
      pci_compliance = {
        enable_least_privilege = true
        enable_regular_access_reviews = true
        enable_strong_authentication = true
        enable_audit_logging = true
      }
    }
    
    # Emergency access configuration
    emergency_access = {
      enable_break_glass_accounts = true
      break_glass_accounts = [
        "emergency-admin-1",
        "emergency-admin-2"
      ]
      emergency_access_procedures = {
        approval_required = true
        time_limit_hours = 4
        notification_required = true
        audit_logging_required = true
      }
    }
    
    # Access review configuration
    access_reviews = {
      enable_automated_reviews = true
      review_frequency_days = 90
      review_scope = "all"
      review_notification_days = 30
      
      # Review criteria
      review_criteria = {
        inactive_users_days = 90
        unused_roles_days = 180
        unused_policies_days = 365
        excessive_permissions_threshold = 10
      }
    }
    
    # Monitoring and alerting configuration
    monitoring_config = {
      enable_cloudwatch_alarms = true
      enable_sns_notifications = true
      enable_opsgenie_integration = true
      enable_pagerduty_integration = true
      
      # Critical IAM alarms
      critical_alarms = [
        "RootAccountUsage",
        "MFAViolation",
        "AccessKeyCreation",
        "PolicyChanges",
        "RoleAssumption",
        "UnusualActivity"
      ]
      
      # Alert thresholds
      alert_thresholds = {
        failed_login_attempts = 5
        unusual_access_patterns = 3
        policy_changes_per_day = 10
        role_assumptions_per_hour = 50
      }
    }
    
    # Security automation
    security_automation = {
      enable_automated_remediation = true
      enable_automated_response = true
      enable_automated_cleanup = true
      
      # Automated actions
      automated_actions = {
        disable_inactive_users = true
        rotate_access_keys = true
        revoke_excessive_permissions = true
        notify_security_team = true
      }
    }
  }
  
  # Compliance and governance
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = true
    enable_data_classification = true
    enable_privacy_protection = true
    
    # SOX compliance
    sox_compliance = {
      enable_segregation_of_duties = true
      enable_access_reviews = true
      enable_change_management = true
      enable_audit_trails = true
      enable_control_testing = true
    }
    
    # PCI DSS compliance
    pci_compliance = {
      enable_least_privilege = true
      enable_regular_access_reviews = true
      enable_strong_authentication = true
      enable_audit_logging = true
      enable_encryption_standards = true
    }
    
    # GDPR compliance
    gdpr_compliance = {
      enable_data_access_controls = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = true
      enable_data_portability = true
      enable_privacy_by_design = true
    }
  }
} 