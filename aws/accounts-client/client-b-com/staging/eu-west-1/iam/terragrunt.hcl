# ==============================================================================
# IAM Module Configuration for Client B - Staging Environment
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
  project     = "IAM Management - Staging"
  
  # IAM specific configuration for staging environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # DevOps team users (staging access)
      "devops-admin-staging" = {
        username = "devops-admin-staging"
        path     = "/users/devops/staging/"
        groups   = ["DevOpsAdminsStaging", "SystemOperatorsStaging"]
        tags = {
          Role        = "DevOps Administrator - Staging"
          Department  = "IT"
          AccessLevel = "Admin"
          Environment = "Staging"
        }
      }
      
      "devops-engineer-staging" = {
        username = "devops-engineer-staging"
        path     = "/users/devops/staging/"
        groups   = ["DevOpsEngineersStaging", "SystemOperatorsStaging"]
        tags = {
          Role        = "DevOps Engineer - Staging"
          Department  = "IT"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
      
      # Application users (staging access)
      "app-service-account-staging" = {
        username = "app-service-account-staging"
        path     = "/users/applications/staging/"
        groups   = ["ApplicationUsersStaging", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account - Staging"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      # Testing users
      "test-user-staging" = {
        username = "test-user-staging"
        path     = "/users/testing/staging/"
        groups   = ["TestUsersStaging", "ReadOnlyAccess"]
        tags = {
          Role        = "Test User - Staging"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      # Monitoring users (staging access)
      "monitoring-user-staging" = {
        username = "monitoring-user-staging"
        path     = "/users/monitoring/staging/"
        groups   = ["MonitoringUsersStaging", "CloudWatchUsersStaging"]
        tags = {
          Role        = "Monitoring User - Staging"
          Department  = "IT"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      # Staging administrative groups
      "SystemOperatorsStaging" = {
        group_name = "SystemOperatorsStaging"
        path       = "/groups/operations/staging/"
        policies   = ["ReadOnlyAccess", "CloudWatchFullAccess"]
        tags = {
          Purpose     = "System Operations - Staging"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      "DevOpsAdminsStaging" = {
        group_name = "DevOpsAdminsStaging"
        path       = "/groups/devops/staging/"
        policies   = ["PowerUserAccess", "IAMReadOnlyAccess"]
        tags = {
          Purpose     = "DevOps Administration - Staging"
          AccessLevel = "Power"
          Environment = "Staging"
        }
      }
      
      "DevOpsEngineersStaging" = {
        group_name = "DevOpsEngineersStaging"
        path       = "/groups/devops/staging/"
        policies   = ["PowerUserAccess"]
        tags = {
          Purpose     = "DevOps Engineering - Staging"
          AccessLevel = "Power"
          Environment = "Staging"
        }
      }
      
      # Application groups
      "ApplicationUsersStaging" = {
        group_name = "ApplicationUsersStaging"
        path       = "/groups/applications/staging/"
        policies   = ["ReadOnlyAccess"]
        tags = {
          Purpose     = "Application Access - Staging"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      # Testing groups
      "TestUsersStaging" = {
        group_name = "TestUsersStaging"
        path       = "/groups/testing/staging/"
        policies   = ["ReadOnlyAccess", "AmazonS3ReadOnlyAccess"]
        tags = {
          Purpose     = "Testing Access - Staging"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      # Monitoring groups
      "MonitoringUsersStaging" = {
        group_name = "MonitoringUsersStaging"
        path       = "/groups/monitoring/staging/"
        policies   = ["CloudWatchFullAccess", "CloudWatchLogsFullAccess"]
        tags = {
          Purpose     = "Monitoring Access - Staging"
          AccessLevel = "Monitoring"
          Environment = "Staging"
        }
      }
      
      "CloudWatchUsersStaging" = {
        group_name = "CloudWatchUsersStaging"
        path       = "/groups/monitoring/staging/"
        policies   = ["CloudWatchReadOnlyAccess"]
        tags = {
          Purpose     = "CloudWatch Access - Staging"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
    }
    
    # IAM role configuration
    create_iam_roles = true
    iam_roles = {
      # EC2 instance roles (staging)
      "ec2-instance-role-staging" = {
        role_name = "EC2InstanceRoleStaging"
        path      = "/roles/ec2/staging/"
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
          Purpose     = "EC2 Instance Role - Staging"
          Service     = "EC2"
          AccessLevel = "Instance"
          Environment = "Staging"
        }
      }
      
      # Lambda execution roles (staging)
      "lambda-execution-role-staging" = {
        role_name = "LambdaExecutionRoleStaging"
        path      = "/roles/lambda/staging/"
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
          Purpose     = "Lambda Execution Role - Staging"
          Service     = "Lambda"
          AccessLevel = "Execution"
          Environment = "Staging"
        }
      }
      
      # ECS task roles (staging)
      "ecs-task-role-staging" = {
        role_name = "ECSTaskRoleStaging"
        path      = "/roles/ecs/staging/"
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
          Purpose     = "ECS Task Role - Staging"
          Service     = "ECS"
          AccessLevel = "Task"
          Environment = "Staging"
        }
      }
      
      # Application load balancer role (staging)
      "alb-role-staging" = {
        role_name = "ApplicationLoadBalancerRoleStaging"
        path      = "/roles/alb/staging/"
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
          Purpose     = "ALB Service Role - Staging"
          Service     = "ALB"
          AccessLevel = "Service"
          Environment = "Staging"
        }
      }
      
      # RDS proxy role (staging)
      "rds-proxy-role-staging" = {
        role_name = "RDSProxyRoleStaging"
        path      = "/roles/rds/staging/"
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
          Purpose     = "RDS Proxy Role - Staging"
          Service     = "RDS"
          AccessLevel = "Service"
          Environment = "Staging"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      # Custom application policy (staging)
      "application-access-policy-staging" = {
        policy_name = "ApplicationAccessPolicyStaging"
        path        = "/policies/applications/staging/"
        description = "Custom policy for application access in staging"
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
                "arn:aws:s3:::client-b-app-bucket-staging",
                "arn:aws:s3:::client-b-app-bucket-staging/*"
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
              Resource = "arn:aws:dynamodb:eu-west-1:987654321098:table/client-b-app-table-staging"
            },
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
              ]
              Resource = "arn:aws:sqs:eu-west-1:987654321098:client-b-app-queue-staging"
            }
          ]
        }
        tags = {
          Purpose     = "Application Access - Staging"
          Service     = "Custom"
          AccessLevel = "Application"
          Environment = "Staging"
        }
      }
      
      # Database access policy (staging)
      "database-access-policy-staging" = {
        policy_name = "DatabaseAccessPolicyStaging"
        path        = "/policies/database/staging/"
        description = "Custom policy for database access in staging"
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
              Resource = "arn:aws:rds-db:eu-west-1:987654321098:dbuser:*/client-b-app-user-staging"
            }
          ]
        }
        tags = {
          Purpose     = "Database Access - Staging"
          Service     = "RDS"
          AccessLevel = "Database"
          Environment = "Staging"
        }
      }
      
      # Monitoring policy (staging)
      "monitoring-policy-staging" = {
        policy_name = "MonitoringPolicyStaging"
        path        = "/policies/monitoring/staging/"
        description = "Custom policy for monitoring and alerting in staging"
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
              Resource = "arn:aws:logs:eu-west-1:987654321098:log-group:/aws/application/staging/*"
            },
            {
              Effect = "Allow"
              Action = [
                "sns:Publish",
                "sns:Subscribe",
                "sns:ListSubscriptions"
              ]
              Resource = "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"
            }
          ]
        }
        tags = {
          Purpose     = "Monitoring Access - Staging"
          Service     = "CloudWatch"
          AccessLevel = "Monitoring"
          Environment = "Staging"
        }
      }
      
      # Testing policy (staging)
      "testing-policy-staging" = {
        policy_name = "TestingPolicyStaging"
        path        = "/policies/testing/staging/"
        description = "Custom policy for testing activities in staging"
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
                "arn:aws:s3:::client-b-test-bucket-staging",
                "arn:aws:s3:::client-b-test-bucket-staging/*"
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
              Resource = "arn:aws:dynamodb:eu-west-1:987654321098:table/client-b-test-table-staging"
            }
          ]
        }
        tags = {
          Purpose     = "Testing Access - Staging"
          Service     = "Custom"
          AccessLevel = "Testing"
          Environment = "Staging"
        }
      }
    }
    
    # Password policy configuration (staging - less strict than production)
    password_policy = {
      minimum_password_length = 10
      require_symbols = true
      require_numbers = true
      require_uppercase_characters = true
      require_lowercase_characters = true
      allow_users_to_change_password = true
      max_password_age = 120  # Longer than production
      password_reuse_prevention = 12  # Less strict than production
      hard_expiry = false
    }
    
    # Account alias configuration
    account_alias = "client-b-staging"
    
    # MFA configuration
    require_mfa = true
    mfa_policy_name = "MFAPolicyStaging"
    
    # Access key rotation
    enable_access_key_rotation = true
    access_key_rotation_days = 120  # Longer than production
    
    # Session duration
    max_session_duration = 7200  # 2 hours for staging (longer than production)
    
    # Security configurations
    enable_advanced_security_features = true
    enable_credential_report = true
    enable_access_analyzer = true
    enable_organizations_srp = false  # Disabled for staging
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
    Purpose     = "Staging IAM Management"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    StagingEnvironment = "Yes"
    TestingEnvironment = "Yes"
    BusinessImpact = "Medium"
    SecurityLevel = "Medium"
  }
  
  # Staging specific overrides
  staging_overrides = {
    # Security for staging (less strict than production)
    enable_strict_password_policy = false
    enable_mfa_enforcement = true
    enable_session_timeout = true
    enable_least_privilege_access = true
    
    # Audit and compliance (basic for staging)
    enable_detailed_audit_logging = true
    enable_access_reviews = true
    enable_privilege_escalation_monitoring = false
    enable_anomaly_detection = false
    
    # Monitoring and alerting (basic for staging)
    enable_iam_monitoring = true
    enable_access_key_monitoring = true
    enable_role_assumption_monitoring = false
    enable_policy_changes_monitoring = true
    
    # Security hardening (basic for staging)
    enable_credential_rotation = true
    enable_session_management = true
    enable_emergency_access = false
    enable_break_glass_procedures = false
    
    # Compliance configurations (basic for staging)
    compliance_config = {
      enable_sox_compliance = false
      enable_pci_compliance = false
      enable_hipaa_compliance = false
      enable_gdpr_compliance = true
      
      # GDPR compliance (basic)
      gdpr_compliance = {
        enable_data_access_controls = true
        enable_data_retention_policies = true
        enable_right_to_be_forgotten = false
        enable_data_portability = false
        enable_privacy_by_design = true
      }
    }
    
    # Access review configuration (less frequent for staging)
    access_reviews = {
      enable_automated_reviews = true
      review_frequency_days = 180  # Less frequent than production
      review_scope = "users"
      review_notification_days = 14
      
      # Review criteria (less strict for staging)
      review_criteria = {
        inactive_users_days = 180  # Longer than production
        unused_roles_days = 365
        unused_policies_days = 730
        excessive_permissions_threshold = 20  # Higher threshold
      }
    }
    
    # Monitoring and alerting configuration (basic for staging)
    monitoring_config = {
      enable_cloudwatch_alarms = true
      enable_sns_notifications = true
      enable_opsgenie_integration = false
      enable_pagerduty_integration = false
      
      # Basic IAM alarms for staging
      critical_alarms = [
        "RootAccountUsage",
        "MFAViolation",
        "AccessKeyCreation"
      ]
      
      # Alert thresholds (higher for staging)
      alert_thresholds = {
        failed_login_attempts = 10  # Higher than production
        unusual_access_patterns = 5
        policy_changes_per_day = 20
        role_assumptions_per_hour = 100
      }
    }
    
    # Security automation (basic for staging)
    security_automation = {
      enable_automated_remediation = false
      enable_automated_response = false
      enable_automated_cleanup = true
      
      # Automated actions (basic for staging)
      automated_actions = {
        disable_inactive_users = true
        rotate_access_keys = true
        revoke_excessive_permissions = false
        notify_security_team = false
      }
    }
    
    # Testing and development features
    testing_features = {
      enable_test_user_creation = true
      enable_test_role_assumption = true
      enable_test_policy_creation = true
      enable_test_data_access = true
      
      # Test environment variables
      test_environment_variables = {
        NODE_ENV = "staging"
        DEBUG = "true"
        LOG_LEVEL = "debug"
        ENABLE_TEST_FEATURES = "true"
        SKIP_SSL_VERIFICATION = "true"
        ENABLE_PERFORMANCE_MONITORING = "false"
        ENABLE_ERROR_TRACKING = "false"
      }
    }
    
    # Performance testing configuration
    performance_testing = {
      enable_load_testing = true
      enable_stress_testing = true
      enable_capacity_testing = true
      test_data_size = "medium"
      
      # Test user provisioning
      test_user_provisioning = {
        enable_auto_provisioning = true
        max_test_users = 10
        test_user_lifetime_days = 30
        enable_test_user_cleanup = true
      }
    }
    
    # Security testing configuration
    security_testing = {
      enable_vulnerability_scanning = true
      enable_penetration_testing = true
      enable_compliance_scanning = true
      
      # Test security policies
      test_security_policies = {
        enable_test_mfa_bypass = true
        enable_test_permission_escalation = true
        enable_test_access_key_creation = true
        enable_test_role_assumption = true
      }
    }
  }
  
  # Compliance and governance (basic for staging)
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = false
    enable_data_classification = true
    enable_privacy_protection = true
    
    # GDPR compliance (basic)
    gdpr_compliance = {
      enable_data_access_controls = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = false
      enable_data_portability = false
      enable_privacy_by_design = true
    }
    
    # Security compliance (basic)
    security_compliance = {
      enable_iso27001_compliance = false
      enable_soc2_compliance = false
      enable_pci_dss_compliance = false
      enable_hipaa_compliance = false
    }
  }
} 