# ==============================================================================
# IAM Module Configuration for Client B - Development Environment
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
  project     = "IAM Management - Development"
  
  # IAM specific configuration for development environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # Development team users
      "dev-admin" = {
        username = "dev-admin"
        path     = "/users/dev/"
        groups   = ["DevAdmins", "SystemOperatorsDev"]
        tags = {
          Role        = "Development Administrator"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
      
      "dev-engineer" = {
        username = "dev-engineer"
        path     = "/users/dev/"
        groups   = ["DevEngineers", "SystemOperatorsDev"]
        tags = {
          Role        = "Development Engineer"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "dev-tester" = {
        username = "dev-tester"
        path     = "/users/dev/"
        groups   = ["DevTesters", "ReadOnlyAccess"]
        tags = {
          Role        = "Development Tester"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      # Application users (development access)
      "app-service-account-dev" = {
        username = "app-service-account-dev"
        path     = "/users/applications/dev/"
        groups   = ["ApplicationUsersDev", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account - Dev"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      # Monitoring users (development access)
      "monitoring-user-dev" = {
        username = "monitoring-user-dev"
        path     = "/users/monitoring/dev/"
        groups   = ["MonitoringUsersDev", "CloudWatchUsersDev"]
        tags = {
          Role        = "Monitoring User - Dev"
          Department  = "IT"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      # Development administrative groups
      "DevAdmins" = {
        group_name = "DevAdmins"
        path       = "/groups/dev/"
        policies   = ["PowerUserAccess", "IAMReadOnlyAccess"]
        tags = {
          Purpose     = "Development Administration"
          AccessLevel = "Power"
          Environment = "Development"
        }
      }
      
      "DevEngineers" = {
        group_name = "DevEngineers"
        path       = "/groups/dev/"
        policies   = ["PowerUserAccess"]
        tags = {
          Purpose     = "Development Engineering"
          AccessLevel = "Power"
          Environment = "Development"
        }
      }
      
      "DevTesters" = {
        group_name = "DevTesters"
        path       = "/groups/dev/"
        policies   = ["ReadOnlyAccess", "AmazonS3ReadOnlyAccess"]
        tags = {
          Purpose     = "Development Testing"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      "SystemOperatorsDev" = {
        group_name = "SystemOperatorsDev"
        path       = "/groups/operations/dev/"
        policies   = ["ReadOnlyAccess", "CloudWatchFullAccess"]
        tags = {
          Purpose     = "System Operations - Dev"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      # Application groups
      "ApplicationUsersDev" = {
        group_name = "ApplicationUsersDev"
        path       = "/groups/applications/dev/"
        policies   = ["ReadOnlyAccess"]
        tags = {
          Purpose     = "Application Access - Dev"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      # Monitoring groups
      "MonitoringUsersDev" = {
        group_name = "MonitoringUsersDev"
        path       = "/groups/monitoring/dev/"
        policies   = ["CloudWatchFullAccess", "CloudWatchLogsFullAccess"]
        tags = {
          Purpose     = "Monitoring Access - Dev"
          AccessLevel = "Monitoring"
          Environment = "Development"
        }
      }
      
      "CloudWatchUsersDev" = {
        group_name = "CloudWatchUsersDev"
        path       = "/groups/monitoring/dev/"
        policies   = ["CloudWatchReadOnlyAccess"]
        tags = {
          Purpose     = "CloudWatch Access - Dev"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
    }
    
    # IAM role configuration
    create_iam_roles = true
    iam_roles = {
      # EC2 instance roles (development)
      "ec2-instance-role-dev" = {
        role_name = "EC2InstanceRoleDev"
        path      = "/roles/ec2/dev/"
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
          Purpose     = "EC2 Instance Role - Dev"
          Service     = "EC2"
          AccessLevel = "Instance"
          Environment = "Development"
        }
      }
      
      # Lambda execution roles (development)
      "lambda-execution-role-dev" = {
        role_name = "LambdaExecutionRoleDev"
        path      = "/roles/lambda/dev/"
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
          Purpose     = "Lambda Execution Role - Dev"
          Service     = "Lambda"
          AccessLevel = "Execution"
          Environment = "Development"
        }
      }
      
      # ECS task roles (development)
      "ecs-task-role-dev" = {
        role_name = "ECSTaskRoleDev"
        path      = "/roles/ecs/dev/"
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
          Purpose     = "ECS Task Role - Dev"
          Service     = "ECS"
          AccessLevel = "Task"
          Environment = "Development"
        }
      }
      
      # Application load balancer role (development)
      "alb-role-dev" = {
        role_name = "ApplicationLoadBalancerRoleDev"
        path      = "/roles/alb/dev/"
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
          Purpose     = "ALB Service Role - Dev"
          Service     = "ALB"
          AccessLevel = "Service"
          Environment = "Development"
        }
      }
      
      # RDS proxy role (development)
      "rds-proxy-role-dev" = {
        role_name = "RDSProxyRoleDev"
        path      = "/roles/rds/dev/"
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
          Purpose     = "RDS Proxy Role - Dev"
          Service     = "RDS"
          AccessLevel = "Service"
          Environment = "Development"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      # Custom application policy (development)
      "application-access-policy-dev" = {
        policy_name = "ApplicationAccessPolicyDev"
        path        = "/policies/applications/dev/"
        description = "Custom policy for application access in development"
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
                "arn:aws:s3:::client-b-app-bucket-dev",
                "arn:aws:s3:::client-b-app-bucket-dev/*"
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
              Resource = "arn:aws:dynamodb:eu-west-1:987654321098:table/client-b-app-table-dev"
            },
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
              ]
              Resource = "arn:aws:sqs:eu-west-1:987654321098:client-b-app-queue-dev"
            }
          ]
        }
        tags = {
          Purpose     = "Application Access - Dev"
          Service     = "Custom"
          AccessLevel = "Application"
          Environment = "Development"
        }
      }
      
      # Database access policy (development)
      "database-access-policy-dev" = {
        policy_name = "DatabaseAccessPolicyDev"
        path        = "/policies/database/dev/"
        description = "Custom policy for database access in development"
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
              Resource = "arn:aws:rds-db:eu-west-1:987654321098:dbuser:*/client-b-app-user-dev"
            }
          ]
        }
        tags = {
          Purpose     = "Database Access - Dev"
          Service     = "RDS"
          AccessLevel = "Database"
          Environment = "Development"
        }
      }
      
      # Monitoring policy (development)
      "monitoring-policy-dev" = {
        policy_name = "MonitoringPolicyDev"
        path        = "/policies/monitoring/dev/"
        description = "Custom policy for monitoring and alerting in development"
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
              Resource = "arn:aws:logs:eu-west-1:987654321098:log-group:/aws/application/dev/*"
            },
            {
              Effect = "Allow"
              Action = [
                "sns:Publish",
                "sns:Subscribe",
                "sns:ListSubscriptions"
              ]
              Resource = "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"
            }
          ]
        }
        tags = {
          Purpose     = "Monitoring Access - Dev"
          Service     = "CloudWatch"
          AccessLevel = "Monitoring"
          Environment = "Development"
        }
      }
      
      # Development testing policy
      "development-testing-policy" = {
        policy_name = "DevelopmentTestingPolicy"
        path        = "/policies/testing/dev/"
        description = "Custom policy for development testing activities"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
              ]
              Resource = [
                "arn:aws:s3:::client-b-test-bucket-dev",
                "arn:aws:s3:::client-b-test-bucket-dev/*"
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
              Resource = "arn:aws:dynamodb:eu-west-1:987654321098:table/client-b-test-table-dev"
            },
            {
              Effect = "Allow"
              Action = [
                "ec2:DescribeInstances",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets"
              ]
              Resource = "*"
            }
          ]
        }
        tags = {
          Purpose     = "Development Testing"
          Service     = "Custom"
          AccessLevel = "Testing"
          Environment = "Development"
        }
      }
    }
    
    # Password policy configuration (development - less strict)
    password_policy = {
      minimum_password_length = 8
      require_symbols = true
      require_numbers = true
      require_uppercase_characters = true
      require_lowercase_characters = true
      allow_users_to_change_password = true
      max_password_age = 180  # Longer than staging/production
      password_reuse_prevention = 6  # Less strict than staging/production
      hard_expiry = false
    }
    
    # Account alias configuration
    account_alias = "client-b-dev"
    
    # MFA configuration
    require_mfa = false  # Disabled for development convenience
    mfa_policy_name = "MFAPolicyDev"
    
    # Access key rotation
    enable_access_key_rotation = true
    access_key_rotation_days = 180  # Longer than staging/production
    
    # Session duration
    max_session_duration = 14400  # 4 hours for development (longer than staging/production)
    
    # Security configurations
    enable_advanced_security_features = false  # Disabled for development
    enable_credential_report = false
    enable_access_analyzer = false
    enable_organizations_srp = false
  }
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "IAM Management"
    CostCenter  = "ClientB"
    Owner       = "DevOps Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Development IAM Management"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    DevelopmentEnvironment = "Yes"
    TestingEnvironment = "Yes"
    BusinessImpact = "Low"
    SecurityLevel = "Low"
  }
  
  # Development specific overrides
  dev_overrides = {
    # Security for development (minimal)
    enable_strict_password_policy = false
    enable_mfa_enforcement = false
    enable_session_timeout = false
    enable_least_privilege_access = false
    
    # Audit and compliance (disabled for development)
    enable_detailed_audit_logging = false
    enable_access_reviews = false
    enable_privilege_escalation_monitoring = false
    enable_anomaly_detection = false
    
    # Monitoring and alerting (disabled for development)
    enable_iam_monitoring = false
    enable_access_key_monitoring = false
    enable_role_assumption_monitoring = false
    enable_policy_changes_monitoring = false
    
    # Security hardening (disabled for development)
    enable_credential_rotation = false
    enable_session_management = false
    enable_emergency_access = false
    enable_break_glass_procedures = false
    
    # Compliance configurations (disabled for development)
    compliance_config = {
      enable_sox_compliance = false
      enable_pci_compliance = false
      enable_hipaa_compliance = false
      enable_gdpr_compliance = false
      
      # GDPR compliance (disabled)
      gdpr_compliance = {
        enable_data_access_controls = false
        enable_data_retention_policies = false
        enable_right_to_be_forgotten = false
        enable_data_portability = false
        enable_privacy_by_design = false
      }
    }
    
    # Access review configuration (disabled for development)
    access_reviews = {
      enable_automated_reviews = false
      review_frequency_days = 365  # Never
      review_scope = "none"
      review_notification_days = 0
      
      # Review criteria (disabled)
      review_criteria = {
        inactive_users_days = 365
        unused_roles_days = 730
        unused_policies_days = 1460
        excessive_permissions_threshold = 50  # Very high threshold
      }
    }
    
    # Monitoring and alerting configuration (disabled for development)
    monitoring_config = {
      enable_cloudwatch_alarms = false
      enable_sns_notifications = false
      enable_opsgenie_integration = false
      enable_pagerduty_integration = false
      
      # No IAM alarms for development
      critical_alarms = []
      
      # Alert thresholds (very high for development)
      alert_thresholds = {
        failed_login_attempts = 50  # Very high threshold
        unusual_access_patterns = 20
        policy_changes_per_day = 100
        role_assumptions_per_hour = 500
      }
    }
    
    # Security automation (disabled for development)
    security_automation = {
      enable_automated_remediation = false
      enable_automated_response = false
      enable_automated_cleanup = false
      
      # Automated actions (disabled for development)
      automated_actions = {
        disable_inactive_users = false
        rotate_access_keys = false
        revoke_excessive_permissions = false
        notify_security_team = false
      }
    }
    
    # Development and testing features
    development_features = {
      enable_test_user_creation = true
      enable_test_role_assumption = true
      enable_test_policy_creation = true
      enable_test_data_access = true
      enable_debug_access = true
      enable_development_tools = true
      
      # Development environment variables
      development_environment_variables = {
        NODE_ENV = "development"
        DEBUG = "true"
        LOG_LEVEL = "debug"
        ENABLE_TEST_FEATURES = "true"
        SKIP_SSL_VERIFICATION = "true"
        ENABLE_PERFORMANCE_MONITORING = "false"
        ENABLE_ERROR_TRACKING = "false"
        ENABLE_DEBUG_MODE = "true"
        ENABLE_DEVELOPMENT_TOOLS = "true"
      }
    }
    
    # Testing configuration
    testing_config = {
      enable_unit_testing = true
      enable_integration_testing = true
      enable_load_testing = true
      enable_security_testing = true
      
      # Test user provisioning
      test_user_provisioning = {
        enable_auto_provisioning = true
        max_test_users = 20  # Higher than staging
        test_user_lifetime_days = 60  # Longer than staging
        enable_test_user_cleanup = false  # Disabled for development
      }
      
      # Test security policies
      test_security_policies = {
        enable_test_mfa_bypass = true
        enable_test_permission_escalation = true
        enable_test_access_key_creation = true
        enable_test_role_assumption = true
        enable_test_policy_modification = true
      }
    }
    
    # Performance testing configuration
    performance_testing = {
      enable_load_testing = true
      enable_stress_testing = true
      enable_capacity_testing = true
      test_data_size = "large"  # Larger than staging
      
      # Performance test user provisioning
      performance_test_user_provisioning = {
        enable_auto_provisioning = true
        max_performance_test_users = 50
        performance_test_user_lifetime_days = 90
        enable_performance_test_user_cleanup = false
      }
    }
    
    # Security testing configuration (enabled for development)
    security_testing = {
      enable_vulnerability_scanning = true
      enable_penetration_testing = true
      enable_compliance_scanning = true
      enable_security_auditing = true
      
      # Security test policies
      security_test_policies = {
        enable_security_test_mfa_bypass = true
        enable_security_test_permission_escalation = true
        enable_security_test_access_key_creation = true
        enable_security_test_role_assumption = true
        enable_security_test_policy_modification = true
        enable_security_test_privilege_escalation = true
      }
    }
  }
  
  # Compliance and governance (disabled for development)
  compliance_config = {
    enable_audit_logging = false
    enable_compliance_reporting = false
    enable_data_classification = false
    enable_privacy_protection = false
    
    # GDPR compliance (disabled)
    gdpr_compliance = {
      enable_data_access_controls = false
      enable_data_retention_policies = false
      enable_right_to_be_forgotten = false
      enable_data_portability = false
      enable_privacy_by_design = false
    }
    
    # Security compliance (disabled)
    security_compliance = {
      enable_iso27001_compliance = false
      enable_soc2_compliance = false
      enable_pci_dss_compliance = false
      enable_hipaa_compliance = false
    }
  }
} 