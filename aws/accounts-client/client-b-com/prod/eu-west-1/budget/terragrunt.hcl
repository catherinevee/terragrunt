# ==============================================================================
# Budget Module Configuration for Client B - Production Environment
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

# Dependencies
dependency "sns" {
  config_path = "../sns"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Budget Management - Production"
  
  # Budget specific configuration for production environment
  budget_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "Budget Management"
    
    # Budget configuration
    create_budgets = true
    budgets = {
      # Monthly production budget
      "monthly-prod-budget" = {
        name = "Monthly Production Budget"
        budget_type = "COST"
        time_unit = "MONTHLY"
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
            threshold          = 60
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            sns_topic_arn = dependency.sns.outputs.topic_arns["prod-budget-alerts"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 75
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            sns_topic_arn = dependency.sns.outputs.topic_arns["prod-budget-alerts"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 85
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            sns_topic_arn = dependency.sns.outputs.topic_arns["prod-budget-alerts"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 95
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            sns_topic_arn = dependency.sns.outputs.topic_arns["prod-budget-alerts"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            sns_topic_arn = dependency.sns.outputs.topic_arns["prod-budget-alerts"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$prod"
        }
        tags = {
          Environment = "Production"
          Purpose     = "Monthly Budget Tracking"
          Owner       = "DevOps Team"
          Criticality = "High"
        }
      }
      
      # Quarterly production budget
      "quarterly-prod-budget" = {
        name = "Quarterly Production Budget"
        budget_type = "COST"
        time_unit = "QUARTERLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "45000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 65
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 80
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 90
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 100
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com", "emergency@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$prod"
        }
        tags = {
          Environment = "Production"
          Purpose     = "Quarterly Budget Tracking"
          Owner       = "DevOps Team"
          Criticality = "High"
        }
      }
      
      # Annual production budget
      "annual-prod-budget" = {
        name = "Annual Production Budget"
        budget_type = "COST"
        time_unit = "ANNUALLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "180000.00"
          unit   = "USD"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 70
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 85
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
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
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com", "emergency@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$prod"
        }
        tags = {
          Environment = "Production"
          Purpose     = "Annual Budget Tracking"
          Owner       = "DevOps Team"
          Criticality = "High"
        }
      }
      
      # Usage budget for production
      "usage-prod-budget" = {
        name = "Production Usage Budget"
        budget_type = "USAGE"
        time_unit = "MONTHLY"
        time_period = {
          start = "2024-01-01_00:00"
          end   = "2027-12-31_23:59"
        }
        budget_limit = {
          amount = "5000"
          unit   = "GB-Mo"
        }
        notifications = [
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 60
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 75
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com"]
          },
          {
            comparison_operator = "GREATER_THAN"
            threshold          = 85
            threshold_type     = "PERCENTAGE"
            notification_type  = "ACTUAL"
            subscriber_email_addresses = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
          }
        ]
        cost_filters = {
          TagKeyValue = "Environment$$prod"
        }
        tags = {
          Environment = "Production"
          Purpose     = "Usage Budget Tracking"
          Owner       = "DevOps Team"
          Criticality = "High"
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
        "DataClassification",
        "Compliance",
        "Criticality"
      ]
    }
    
    # Cost anomaly detection
    cost_anomaly_detection = {
      enabled = true
      monitor_arn = "arn:aws:ce::987654321098:anomalymonitor/prod-anomaly-monitor"
      frequency = "DAILY"
      threshold = 5.0  # 5% threshold for production (most sensitive)
      subscribers = [
        {
          address = "devops@client-b.com"
          type    = "EMAIL"
        },
        {
          address = "finance@client-b.com"
          type    = "EMAIL"
        },
        {
          address = "management@client-b.com"
          type    = "EMAIL"
        }
      ]
      tags = {
        Environment = "Production"
        Purpose     = "Cost Anomaly Detection"
        Owner       = "DevOps Team"
        Criticality = "High"
      }
    }
    
    # Savings plans recommendations
    savings_plans_recommendations = {
      enabled = true
      lookback_period = "NINETY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      tags = {
        Environment = "Production"
        Purpose     = "Savings Plans Recommendations"
        Owner       = "DevOps Team"
        Criticality = "High"
      }
    }
    
    # Reserved instances recommendations
    reserved_instances_recommendations = {
      enabled = true
      lookback_period = "NINETY_DAYS"
      term_in_years = 1
      payment_option = "NO_UPFRONT"
      offering_class = "STANDARD"
      tags = {
        Environment = "Production"
        Purpose     = "Reserved Instances Recommendations"
        Owner       = "DevOps Team"
        Criticality = "High"
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
        "TERMINATE_RESOURCES",
        "MODIFY_INSTANCES"
      ]
      tags = {
        Environment = "Production"
        Purpose     = "Cost Optimization Recommendations"
        Owner       = "DevOps Team"
        Criticality = "High"
      }
    }
    
    # Budget reports configuration
    budget_reports = {
      enabled = true
      reports = {
        "monthly-prod-report" = {
          report_name = "Monthly Production Cost Report"
          time_unit = "MONTHLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-prod"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Production"
            Purpose     = "Monthly Cost Reporting"
            Owner       = "DevOps Team"
            Criticality = "High"
          }
        }
        
        "quarterly-prod-report" = {
          report_name = "Quarterly Production Cost Report"
          time_unit = "QUARTERLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-prod"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Production"
            Purpose     = "Quarterly Cost Reporting"
            Owner       = "DevOps Team"
            Criticality = "High"
          }
        }
        
        "annual-prod-report" = {
          report_name = "Annual Production Cost Report"
          time_unit = "ANNUALLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-prod"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Production"
            Purpose     = "Annual Cost Reporting"
            Owner       = "DevOps Team"
            Criticality = "High"
          }
        }
        
        "weekly-prod-report" = {
          report_name = "Weekly Production Cost Report"
          time_unit = "WEEKLY"
          format = "Parquet"
          compression = "GZIP"
          additional_schema_elements = ["RESOURCES"]
          s3_bucket = "client-b-cost-reports-prod"
          s3_region = "eu-west-1"
          additional_artifacts = ["ATHENA"]
          refresh_closed_reports = true
          report_versioning = "OVERWRITE_REPORT"
          tags = {
            Environment = "Production"
            Purpose     = "Weekly Cost Reporting"
            Owner       = "DevOps Team"
            Criticality = "High"
          }
        }
      }
    }
    
    # Cost categories configuration
    cost_categories = {
      enabled = true
      categories = {
        "prod-cost-category" = {
          name = "Production Cost Category"
          rule_version = "CostCategoryExpression.v1"
          rules = [
            {
              value = "Production"
              rule = {
                dimension = {
                  key = "LINKED_ACCOUNT"
                  values = ["987654321098"]
                }
              }
            },
            {
              value = "Production"
              rule = {
                tags = {
                  key = "Environment"
                  values = ["prod"]
                }
              }
            }
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Cost Categorization"
            Owner       = "DevOps Team"
            Criticality = "High"
          }
        }
      }
    }
    
    # Budget alerts configuration
    budget_alerts = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-budget-alerts-prod"
      email_subscribers = [
        "devops@client-b.com",
        "finance@client-b.com",
        "management@client-b.com",
        "executives@client-b.com"
      ]
      tags = {
        Environment = "Production"
        Purpose     = "Budget Alerts"
        Owner       = "DevOps Team"
        Criticality = "High"
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
    Purpose     = "Production Budget Management"
    DataClassification = "Confidential"
    Compliance  = "GDPR"
    ProductionEnvironment = "Yes"
    BusinessImpact = "High"
    SecurityLevel = "High"
    Criticality = "High"
    DisasterRecovery = "Required"
    BackupRetention = "7Years"
  }
  
  # Production specific overrides
  production_overrides = {
    # Budget configuration for production (strict controls)
    enable_strict_budget_controls = true
    enable_automatic_budget_actions = true
    enable_cost_optimization = true
    enable_anomaly_detection = true
    
    # Alerting configuration (strict for production)
    enable_budget_alerts = true
    enable_cost_alerts = true
    enable_usage_alerts = true
    enable_anomaly_alerts = true
    
    # Reporting configuration (comprehensive for production)
    enable_detailed_reporting = true
    enable_automated_reporting = true
    enable_cost_analysis = true
    enable_optimization_recommendations = true
    
    # Production budget thresholds (strict)
    budget_thresholds = {
      warning_threshold = 60  # Lower than staging/dev
      critical_threshold = 75
      emergency_threshold = 85
      anomaly_threshold = 5.0  # 5% for production (most sensitive)
    }
    
    # Production alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_sns_alerts = true
      enable_slack_alerts = true
      enable_pagerduty_alerts = true
      
      # Alert recipients for production
      alert_recipients = {
        warning = ["devops@client-b.com"]
        critical = ["devops@client-b.com", "finance@client-b.com"]
        emergency = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com"]
        executive = ["devops@client-b.com", "finance@client-b.com", "management@client-b.com", "executives@client-b.com"]
        emergency_contact = ["emergency@client-b.com"]
      }
    }
    
    # Production reporting configuration
    reporting_config = {
      enable_weekly_reports = true
      enable_monthly_reports = true
      enable_quarterly_reports = true
      enable_annual_reports = true
      enable_usage_reports = true
      
      # Report formats for production
      report_formats = {
        primary_format = "Parquet"
        compression = "GZIP"
        additional_artifacts = ["ATHENA"]
        backup_format = "CSV"
      }
    }
    
    # Production cost optimization
    cost_optimization_config = {
      enable_rightsizing_recommendations = true
      enable_scheduling_recommendations = true
      enable_reserved_instances_recommendations = true
      enable_savings_plans_recommendations = true
      enable_termination_recommendations = true
      enable_modification_recommendations = true
      
      # Optimization settings for production
      optimization_settings = {
        lookback_period = "NINETY_DAYS"
        term_in_years = 1
        payment_option = "NO_UPFRONT"
        offering_class = "STANDARD"
        risk_tolerance = "LOW"
      }
    }
    
    # Production environment variables
    environment_variables = {
      NODE_ENV = "production"
      DEBUG = "false"
      LOG_LEVEL = "warn"
      ENABLE_BUDGET_DEBUGGING = "false"
      ENABLE_COST_OPTIMIZATION = "true"
      ENABLE_ANOMALY_DETECTION = "true"
      BUDGET_ALERT_ENABLED = "true"
      ENABLE_EMERGENCY_ALERTS = "true"
    }
    
    # Production monitoring
    monitoring_config = {
      enable_cloudwatch_metrics = true
      enable_cloudwatch_alarms = true
      enable_cost_dashboards = true
      enable_budget_dashboards = true
      enable_real_time_monitoring = true
      
      # Monitoring settings for production
      monitoring_settings = {
        metric_namespace = "AWS/Budgets"
        alarm_evaluation_periods = 3
        alarm_period = 300
        alarm_threshold = 60
        alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-budget-alerts-prod"]
      }
    }
    
    # Production cost categories
    cost_categories_config = {
      enable_cost_categorization = true
      enable_cost_allocation = true
      enable_cost_attribution = true
      
      # Category settings for production
      category_settings = {
        primary_category = "Environment"
        secondary_category = "Project"
        tertiary_category = "Service"
        quaternary_category = "DataClassification"
        quinary_category = "Compliance"
        senary_category = "Criticality"
      }
    }
    
    # Production compliance
    compliance_config = {
      enable_audit_logging = true
      enable_compliance_reporting = true
      enable_data_classification = true
      enable_privacy_protection = true
      
      # GDPR compliance (strict)
      gdpr_compliance = {
        enable_data_access_controls = true
        enable_data_retention_policies = true
        enable_right_to_be_forgotten = true
        enable_data_portability = true
        enable_privacy_by_design = true
      }
      
      # Security compliance (strict)
      security_compliance = {
        enable_iso27001_compliance = true
        enable_soc2_compliance = true
        enable_pci_dss_compliance = true
        enable_hipaa_compliance = true
      }
    }
    
    # Production disaster recovery
    disaster_recovery_config = {
      enable_backup_monitoring = true
      enable_recovery_testing = true
      enable_business_continuity = true
      enable_incident_response = true
      
      # DR settings
      dr_settings = {
        rto_target = "4_hours"
        rpo_target = "1_hour"
        backup_retention_days = 2555  # 7 years
        cross_region_backup = true
      }
    }
    
    # Production security
    security_config = {
      enable_encryption_at_rest = true
      enable_encryption_in_transit = true
      enable_access_logging = true
      enable_threat_detection = true
      
      # Security settings
      security_settings = {
        encryption_algorithm = "AES256"
        key_rotation_days = 90
        access_log_retention_days = 2555  # 7 years
        threat_detection_sensitivity = "HIGH"
      }
    }
    
    # Production performance
    performance_config = {
      enable_performance_monitoring = true
      enable_capacity_planning = true
      enable_auto_scaling = true
      enable_load_balancing = true
      
      # Performance settings
      performance_settings = {
        monitoring_interval = "1_minute"
        capacity_buffer = "20_percent"
        auto_scaling_cooldown = "300_seconds"
        load_balancer_health_check_interval = "30_seconds"
      }
    }
  }
  
  # Compliance and governance (strict for production)
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = true
    enable_data_classification = true
    enable_privacy_protection = true
    
    # GDPR compliance (strict)
    gdpr_compliance = {
      enable_data_access_controls = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = true
      enable_data_portability = true
      enable_privacy_by_design = true
    }
    
    # Security compliance (strict)
    security_compliance = {
      enable_iso27001_compliance = true
      enable_soc2_compliance = true
      enable_pci_dss_compliance = true
      enable_hipaa_compliance = true
    }
  }
} 