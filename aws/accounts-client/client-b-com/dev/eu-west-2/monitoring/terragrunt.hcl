# ==============================================================================
# Monitoring Module Configuration for Client B - Development Environment (eu-west-2)
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
  source = "git::https://github.com/catherinevee/tfm-aws-monitoring.git//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "sns" {
  config_path = "../sns"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Monitoring - Development (eu-west-2)"
  
  monitoring_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Monitoring"
    create_monitoring_resources = true
    
    cloudwatch_log_groups = {
      "dev-ecommerce-app-logs" = {
        name = "/aws/applicationloadbalancer/client-b-dev-ecommerce"
        retention_in_days = 7
        kms_key_id = null  # Use default encryption for dev
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Application Logs"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-ecommerce-access-logs" = {
        name = "/aws/applicationloadbalancer/client-b-dev-ecommerce-access"
        retention_in_days = 7
        kms_key_id = null
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Access Logs"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-rds-logs" = {
        name = "/aws/rds/instance/client-b-dev-ecommerce-db"
        retention_in_days = 7
        kms_key_id = null
        tags = {
          Environment = "Development"
          Purpose     = "RDS Database Logs"
          Service     = "Database"
          Owner       = "DevOps Team"
        }
      }
    }
    
    cloudwatch_alarms = {
      "dev-ecommerce-cpu-high" = {
        alarm_name = "ClientBDevEcommerceCPUHigh"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High CPU utilization for ecommerce instances"
        alarm_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-dev-ecommerce-asg"
        }
        tags = {
          Environment = "Development"
          Purpose     = "CPU Monitoring"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-ecommerce-memory-high" = {
        alarm_name = "ClientBDevEcommerceMemoryHigh"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "MemoryUtilization"
        namespace = "System/Linux"
        period = 300
        statistic = "Average"
        threshold = 85
        alarm_description = "High memory utilization for ecommerce instances"
        alarm_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-dev-ecommerce-asg"
        }
        tags = {
          Environment = "Development"
          Purpose     = "Memory Monitoring"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-rds-cpu-high" = {
        alarm_name = "ClientBDevRDSCPUHigh"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High CPU utilization for RDS instance"
        alarm_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        dimensions = {
          DBInstanceIdentifier = "client-b-dev-ecommerce-db"
        }
        tags = {
          Environment = "Development"
          Purpose     = "RDS CPU Monitoring"
          Service     = "Database"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-alb-5xx-errors" = {
        alarm_name = "ClientBDevALB5xxErrors"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 1
        metric_name = "HTTPCode_ELB_5XX_Count"
        namespace = "AWS/ApplicationELB"
        period = 300
        statistic = "Sum"
        threshold = 10
        alarm_description = "High number of 5xx errors from ALB"
        alarm_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["dev-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "app/client-b-dev-ecommerce-alb"
        }
        tags = {
          Environment = "Development"
          Purpose     = "ALB Error Monitoring"
          Service     = "Load Balancer"
          Owner       = "DevOps Team"
        }
      }
    }
    
    vpc_flow_logs = {
      "dev-vpc-flow-logs" = {
        name = "ClientBDevVPCFlowLogs"
        vpc_id = dependency.vpc.outputs.vpc_id
        traffic_type = "ALL"
        log_destination_type = "cloud-watch-logs"
        log_group_name = "/aws/vpc/flowlogs/client-b-dev"
        iam_role_arn = null  # Will be created by the module
        tags = {
          Environment = "Development"
          Purpose     = "VPC Flow Logs"
          Owner       = "DevOps Team"
        }
      }
    }
    
    dashboard = {
      "dev-ecommerce-dashboard" = {
        name = "ClientBDevEcommerceDashboard"
        dashboard_body = jsonencode({
          widgets = [
            {
              type = "metric"
              x = 0
              y = 0
              width = 12
              height = 6
              properties = {
                metrics = [
                  ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "client-b-dev-ecommerce-asg"]
                ]
                period = 300
                stat = "Average"
                region = "eu-west-2"
                title = "Ecommerce CPU Utilization"
              }
            },
            {
              type = "metric"
              x = 12
              y = 0
              width = 12
              height = 6
              properties = {
                metrics = [
                  ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "client-b-dev-ecommerce-db"]
                ]
                period = 300
                stat = "Average"
                region = "eu-west-2"
                title = "RDS CPU Utilization"
              }
            }
          ]
        })
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Dashboard"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 