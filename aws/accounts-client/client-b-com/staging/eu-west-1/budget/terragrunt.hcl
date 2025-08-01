# ==============================================================================
# Budget Module Configuration for Client B - Staging Environment
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
  source = "git::https://github.com/catherinevee/finops.git//?ref=v1.0.0"
}

# Dependencies (uncomment and configure as needed)
# dependency "iam" {
#   config_path = "../iam"
# }
# 
# dependency "sns" {
#   config_path = "../sns"
# }

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Budget Management - Staging"
  
  # Budget specific configuration for staging environment
  budget_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "Budget Management"
    
    # Budget configuration
    create_budgets = true
    budgets = {
      # Monthly staging budget
      "monthly-staging-budget" = {
        name = "Monthly Staging Budget"
        budget_type = "COST"
        time_unit = "MONTHLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "8000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 70
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 85
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 110
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$staging"
        }
        tags = {
          Environment = "Staging"
          Purpose     = "Monthly Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Quarterly staging budget
      "quarterly-staging-budget" = {
        name = "Quarterly Staging Budget"
        budget_type = "COST"
        time_unit = "QUARTERLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "24000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 75
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 90
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$staging"
        }
        tags = {
          Environment = "Staging"
          Purpose     = "Quarterly Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Annual staging budget
      "annual-staging-budget" = {
        name = "Annual Staging Budget"
        budget_type = "COST"
        time_unit = "ANNUALLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "96000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 80
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 95
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$staging"
        }
        tags = {
          Environment = "Staging"
          Purpose     = "Annual Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Usage budget for staging
      "usage-staging-budget" = {
        name = "Staging Usage Budget"
        budget_type = "USAGE"
        time_unit = "MONTHLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "2000"
          unit   = "GB-Mo"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 70
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 85
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$staging"
        }
        tags = {
          Environment = "Staging"
          Purpose     = "Usage Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Cost allocation tags configuration
    cost_allocation_tags = {
      enabled = true
      tags = [
        "Environment",
        "Project",
        "CostCenter",
        "Owner",
        "Department",
        "Application",
        "Service",
        "DataClassification"
      ]
    }
    
    # Cost anomaly detection
    cost_anomaly_detection = {
      enabled = true
      monitor_arn = "arn:aws:ce::987654321098:anomalymonitor/staging-anomaly-monitor"
      frequency = "DAILY"
      threshold = 8.0  # 8% threshold for staging (more sensitive than dev)
      subscribers = [
        {
          address = "devops@client-b.com"
          type    = "EMAIL"
        },
        {
          address = "finance@client-b.com"
          type    = "EMAIL"
        }
      ]
      tags = {
        Environment = "Staging"
        Purpose     = "Cost Anomaly Detection"
        Owner       = "DevOps Team"
      }
    }
    
    # Savings plans recommendations
    savings_plans_recommendations = {
      enabled = true
      lookback_period = "SIXTY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      tags = {
        Environment = "Staging"
        Purpose     = "Savings Plans Recommendations"
        Owner       = "DevOps Team"
      }
    }
    
    # Reserved instances recommendations
    reserved_instances_recommendations = {
      enabled = true
      lookback_period = "SIXTY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      offering_class = "STANDARD"
      tags = {
        Environment = "Staging"
        Purpose     = "Reserved Instances Recommendations"
        Owner       = "DevOps Team"
      }
    }
    
    # Cost optimization recommendations
    cost_optimization_recommendations = {
      enabled = true
      recommendation_types = [
        "RIGHTSIZE",
        "SCHEDULE",
        "PURCHASE_RESERVED_INSTANCES",
        "PURCHASE_SAVINGS_PLANS",
        "TERMINATE_RESOURCES"
      ]
      tags = {
        Environment = "Staging"
        Purpose     = "Cost Optimization Recommendations"
        Owner       = "DevOps Team"
      }
    }
    
    # Budget reports configuration
    budget_reports = {
      enabled = true
      reports = {
        "monthly-staging-report" = {
          report_name = "Monthly Staging Cost Report"
          time_unit = "MONTHLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-staging"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Staging"
            Purpose     = "Monthly Cost Reporting"
            Owner       = "DevOps Team"
          }
        }
        
        "quarterly-staging-report" = {
          report_name = "Quarterly Staging Cost Report"
          time_unit = "QUARTERLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-staging"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Staging"
            Purpose     = "Quarterly Cost Reporting"
            Owner       = "DevOps Team"
          }
        }
        
        "annual-staging-report" = {
          report_name = "Annual Staging Cost Report"
          time_unit = "ANNUALLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-staging"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Staging"
            Purpose     = "Annual Cost Reporting"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Cost categories configuration
    cost_categories = {
      enabled = true
      categories = {
        "staging-cost-category" = {
          name = "Staging Cost Category"
          rule_version = "CostCategoryExpression.v1"
          rules = [
            {
              value = "Staging"
              rule = {
                dimension = {
                  key = "LINKED_ACCOUNT"
                  values = ["987654321098"]
                }
              }
            },
            {
              value = "Staging"
              rule = {
                tags = {
                  key = "Environment"
                  values = ["staging"]
                }
              }
            }
          ]
          tags = {
            Environment = "Staging"
            Purpose     = "Cost Categorization"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Budget alerts configuration
    budget_alerts = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-budget-alerts-staging"
      email_subscribers = [
        "devops@client-b.com",
        "finance@client-b.com",
        "management@client-b.com"
      ]
      tags = {
        Environment = "Staging"
        Purpose     = "Budget Alerts"
        Owner       = "DevOps Team"
      }
    }
  }
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "Budget Management"
    CostCenter  = "ClientB"
    Owner       = "DevOps Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Staging Budget Management"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    StagingEnvironment = "Yes"
    TestingEnvironment = "Yes"
    BusinessImpact = "Medium"
    SecurityLevel = "Medium"
  }
  
  # Staging specific overrides
  staging_overrides = {
    # Budget configuration for staging (moderate controls)
    enable_strict_budget_controls = true
    enable_automatic_budget_actions = false
    enable_cost_optimization = true
    enable_anomaly_detection = true
    
    # Alerting configuration (moderate for staging)
    enable_budget_alerts = true
    enable_cost_alerts = true
    enable_usage_alerts = true
    enable_anomaly_alerts = true
    
    # Reporting configuration (moderate for staging)
    enable_detailed_reporting = true
    enable_automated_reporting = true
    enable_cost_analysis = true
    enable_optimization_recommendations = true
    
    # Staging budget thresholds (moderate)
    budget_thresholds = {
      warning_threshold = 70  # Lower than dev, higher than prod
      critical_threshold = 85
      emergency_threshold = 100
      anomaly_threshold = 8.0  # 8% for staging
    }
    
    # Staging alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_sns_alerts = true
      enable_slack_alerts = true
      enable_pagerduty_alerts = false
      
      # Alert recipients for staging
      alert_recipients = {
        warning = ["devops@client-b.com"]
        critical = ["devops@client-b.com", "finance@client-b.com"]
        emergency = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
      }
    }
    
    # Staging reporting configuration
    reporting_config = {
      enable_monthly_reports = true
      enable_quarterly_reports = true
      enable_annual_reports = true
      enable_usage_reports = true
      
      # Report formats for staging
      report_formats = {
        primary_format = "Parquet"
        compression = "GZIP"
        additional_artifacts = ["ATHENA"]
      }
    }
    
    # Staging cost optimization
    cost_optimization_config = {
      enable_rightsizing_recommendations = true
      enable_scheduling_recommendations = true
      enable_reserved_instances_recommendations = true
      enable_savings_plans_recommendations = true
      enable_termination_recommendations = true
      
      # Optimization settings for staging
      optimization_settings = {
        lookback_period = "SIXTY_DAYS"
        term_in_years = 1
        payment_option = "NO_UPFRONT"
        offering_class = "STANDARD"
      }
    }
    
    # Staging environment variables
    environment_variables = {
      NODE_ENV = "staging"
      DEBUG = "false"
      LOG_LEVEL = "info"
      ENABLE_BUDGET_DEBUGGING = "false"
      ENABLE_COST_OPTIMIZATION = "true"
      ENABLE_ANOMALY_DETECTION = "true"
      BUDGET_ALERT_ENABLED = "true"
    }
    
    # Staging monitoring
    monitoring_config = {
      enable_cloudwatch_metrics = true
      enable_cloudwatch_alarms = true
      enable_cost_dashboards = true
      enable_budget_dashboards = true
      
      # Monitoring settings for staging
      monitoring_settings = {
        metric_namespace = "AWS/Budgets"
        alarm_evaluation_periods = 2
        alarm_period = 300
        alarm_threshold = 70
      }
    }
    
    # Staging cost categories
    cost_categories_config = {
      enable_cost_categorization = true
      enable_cost_allocation = true
      enable_cost_attribution = true
      
      # Category settings for staging
      category_settings = {
        primary_category = "Environment"
        secondary_category = "Project"
        tertiary_category = "Service"
        quaternary_category = "DataClassification"
      }
    }
    
    # Staging compliance
    compliance_config = {
      enable_audit_logging = true
      enable_compliance_reporting = true
      enable_data_classification = true
      enable_privacy_protection = false
      
      # GDPR compliance (basic)
      gdpr_compliance = {
        enable_data_access_controls = true
        enable_data_retention_policies = true
        enable_right_to_be_forgotten = false
        enable_data_portability = false
        enable_privacy_by_design = false
      }
      
      # Security compliance (basic)
      security_compliance = {
        enable_iso27001_compliance = false
        enable_soc2_compliance = false
        enable_pci_dss_compliance = false
        enable_hipaa_compliance = false
      }
    }
    
    # Staging testing features
    testing_features = {
      enable_load_testing = true
      enable_performance_testing = true
      enable_integration_testing = true
      enable_security_testing = true
      
      # Testing configuration
      testing_config = {
        enable_test_user_creation = true
        enable_test_role_assumption = true
        enable_test_policy_creation = true
        enable_test_data_access = true
        enable_debug_access = false
        enable_development_tools = false
        
        # Test user provisioning
        test_user_provisioning = {
          enable_auto_provisioning = true
          max_test_users = 10  # Lower than dev
          test_user_lifetime_days = 30  # Shorter than dev
          enable_test_user_cleanup = true  # Enabled for staging
        }
      }
    }
  }
  
  # Compliance and governance (moderate for staging)
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = true
    enable_data_classification = true
    enable_privacy_protection = false
    
    # GDPR compliance (moderate)
    gdpr_compliance = {
      enable_data_access_controls = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = false
      enable_data_portability = false
      enable_privacy_by_design = false
    }
    
    # Security compliance (moderate)
    security_compliance = {
      enable_iso27001_compliance = false
      enable_soc2_compliance = false
      enable_pci_dss_compliance = false
      enable_hipaa_compliance = false
    }
  }
} 