# ==============================================================================
# Budget Module Configuration for Client B - Development Environment
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
  project     = "Budget Management - Development"
  
  # Budget specific configuration for development environment
  budget_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Budget Management"
    
    # Budget configuration
    create_budgets = true
    budgets = {
      # Monthly development budget
      "monthly-dev-budget" = {
        name = "Monthly Development Budget"
        budget_type = "COST"
        time_unit = "MONTHLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "5000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 80
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 120
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$dev"
        }
        tags = {
          Environment = "Development"
          Purpose     = "Monthly Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Quarterly development budget
      "quarterly-dev-budget" = {
        name = "Quarterly Development Budget"
        budget_type = "COST"
        time_unit = "QUARTERLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "15000.00"
          unit   = "USD"
        }
        notifications = [
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
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$dev"
        }
        tags = {
          Environment = "Development"
          Purpose     = "Quarterly Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Annual development budget
      "annual-dev-budget" = {
        name = "Annual Development Budget"
        budget_type = "COST"
        time_unit = "ANNUALLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "60000.00"
          unit   = "USD"
        }
        notifications = [
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
          TagKeyValue = "Environment$$dev"
        }
        tags = {
          Environment = "Development"
          Purpose     = "Annual Budget Tracking"
          Owner       = "DevOps Team"
        }
      }
      
      # Usage budget for development
      "usage-dev-budget" = {
        name = "Development Usage Budget"
        budget_type = "USAGE"
        time_unit = "MONTHLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "1000"
          unit   = "GB-Mo"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 80
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$dev"
        }
        tags = {
          Environment = "Development"
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
        "Service"
      ]
    }
    
    # Cost anomaly detection
    cost_anomaly_detection = {
      enabled = true
      monitor_arn = "arn:aws:ce::987654321098:anomalymonitor/dev-anomaly-monitor"
      frequency = "DAILY"
      threshold = 10.0  # 10% threshold for development
      subscribers = [
        {
          address = "devops@client-b.com"
          type    = "EMAIL"
        }
      ]
      tags = {
        Environment = "Development"
        Purpose     = "Cost Anomaly Detection"
        Owner       = "DevOps Team"
      }
    }
    
    # Savings plans recommendations
    savings_plans_recommendations = {
      enabled = true
      lookback_period = "THIRTY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      tags = {
        Environment = "Development"
        Purpose     = "Savings Plans Recommendations"
        Owner       = "DevOps Team"
      }
    }
    
    # Reserved instances recommendations
    reserved_instances_recommendations = {
      enabled = true
      lookback_period = "THIRTY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      offering_class = "STANDARD"
      tags = {
        Environment = "Development"
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
        "PURCHASE_SAVINGS_PLANS"
      ]
      tags = {
        Environment = "Development"
        Purpose     = "Cost Optimization Recommendations"
        Owner       = "DevOps Team"
      }
    }
    
    # Budget reports configuration
    budget_reports = {
      enabled = true
      reports = {
        "monthly-dev-report" = {
          report_name = "Monthly Development Cost Report"
          time_unit = "MONTHLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-dev"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Development"
            Purpose     = "Monthly Cost Reporting"
            Owner       = "DevOps Team"
          }
        }
        
        "quarterly-dev-report" = {
          report_name = "Quarterly Development Cost Report"
          time_unit = "QUARTERLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-dev"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Development"
            Purpose     = "Quarterly Cost Reporting"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Cost categories configuration
    cost_categories = {
      enabled = true
      categories = {
        "development-cost-category" = {
          name = "Development Cost Category"
          rule_version = "CostCategoryExpression.v1"
          rules = [
            {
              value = "Development"
              rule = {
                dimension = {
                  key = "LINKED_ACCOUNT"
                  values = ["987654321098"]
                }
              }
            },
            {
              value = "Development"
              rule = {
                tags = {
                  key = "Environment"
                  values = ["dev"]
                }
              }
            }
          ]
          tags = {
            Environment = "Development"
            Purpose     = "Cost Categorization"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Budget alerts configuration
    budget_alerts = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-budget-alerts-dev"
      email_subscribers = [
        "devops@client-b.com",
        "finance@client-b.com"
      ]
      tags = {
        Environment = "Development"
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
    Purpose     = "Development Budget Management"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    DevelopmentEnvironment = "Yes"
    TestingEnvironment = "Yes"
    BusinessImpact = "Low"
    SecurityLevel = "Low"
  }
  
  # Development specific overrides
  dev_overrides = {
    # Budget configuration for development (less strict)
    enable_strict_budget_controls = false
    enable_automatic_budget_actions = false
    enable_cost_optimization = true
    enable_anomaly_detection = true
    
    # Alerting configuration (basic for development)
    enable_budget_alerts = true
    enable_cost_alerts = true
    enable_usage_alerts = true
    enable_anomaly_alerts = true
    
    # Reporting configuration (basic for development)
    enable_detailed_reporting = false
    enable_automated_reporting = true
    enable_cost_analysis = true
    enable_optimization_recommendations = true
    
    # Development budget thresholds (higher for development)
    budget_thresholds = {
      warning_threshold = 80  # Higher than production
      critical_threshold = 100
      emergency_threshold = 120
      anomaly_threshold = 10.0  # 10% for development
    }
    
    # Development alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_sns_alerts = true
      enable_slack_alerts = false
      enable_pagerduty_alerts = false
      
      # Alert recipients for development
      alert_recipients = {
        warning = ["devops@client-b.com"]
        critical = ["devops@client-b.com", "finance@client-b.com"]
        emergency = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
      }
    }
    
    # Development reporting configuration
    reporting_config = {
      enable_monthly_reports = true
      enable_quarterly_reports = true
      enable_annual_reports = true
      enable_usage_reports = true
      
      # Report formats for development
      report_formats = {
        primary_format = "Parquet"
        compression = "GZIP"
        additional_artifacts = ["ATHENA"]
      }
    }
    
    # Development cost optimization
    cost_optimization_config = {
      enable_rightsizing_recommendations = true
      enable_scheduling_recommendations = true
      enable_reserved_instances_recommendations = true
      enable_savings_plans_recommendations = true
      
      # Optimization settings for development
      optimization_settings = {
        lookback_period = "THIRTY_DAYS"
        term_in_years = 1
        payment_option = "NO_UPFRONT"
        offering_class = "STANDARD"
      }
    }
    
    # Development environment variables
    environment_variables = {
      NODE_ENV = "development"
      DEBUG = "true"
      LOG_LEVEL = "debug"
      ENABLE_BUDGET_DEBUGGING = "true"
      ENABLE_COST_OPTIMIZATION = "true"
      ENABLE_ANOMALY_DETECTION = "true"
      BUDGET_ALERT_ENABLED = "true"
    }
    
    # Development monitoring
    monitoring_config = {
      enable_cloudwatch_metrics = true
      enable_cloudwatch_alarms = false
      enable_cost_dashboards = true
      enable_budget_dashboards = true
      
      # Monitoring settings for development
      monitoring_settings = {
        metric_namespace = "AWS/Budgets"
        alarm_evaluation_periods = 1
        alarm_period = 300
        alarm_threshold = 80
      }
    }
    
    # Development cost categories
    cost_categories_config = {
      enable_cost_categorization = true
      enable_cost_allocation = true
      enable_cost_attribution = true
      
      # Category settings for development
      category_settings = {
        primary_category = "Environment"
        secondary_category = "Project"
        tertiary_category = "Service"
      }
    }
  }
  
  # Compliance and governance (basic for development)
  compliance_config = {
    enable_audit_logging = false
    enable_compliance_reporting = false
    enable_data_classification = false
    enable_privacy_protection = false
    
    # GDPR compliance (basic)
    gdpr_compliance = {
      enable_data_access_controls = false
      enable_data_retention_policies = false
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
} 