# ==============================================================================
# Monitoring Module Configuration for Client B - Production Environment (eu-west-2)
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

terraform {
  source = "https://github.com/catherinevee/tfm-aws-monitoring//?ref=v1.0.0"
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
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # Monitoring Configuration
  monitoring_config = {
    # CloudWatch Log Groups
    log_groups = {
      "application-logs" = {
        name = "/aws/application/client-b-prod"
        retention_in_days = 90
        kms_key_id = "alias/aws/logs"
      }
      
      "security-logs" = {
        name = "/aws/security/client-b-prod"
        retention_in_days = 365
        kms_key_id = "alias/aws/logs"
      }
      
      "vpc-flow-logs" = {
        name = "/aws/vpc/flowlogs/client-b-prod"
        retention_in_days = 90
        kms_key_id = "alias/aws/logs"
      }
      
      "alb-access-logs" = {
        name = "/aws/alb/accesslogs/client-b-prod"
        retention_in_days = 90
        kms_key_id = "alias/aws/logs"
      }
    }
    
    # VPC Flow Logs
    vpc_flow_logs = {
      enabled = true
      vpc_id = dependency.vpc.outputs.vpc_id
      traffic_type = "ALL"
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flowlogs/client-b-prod"
      iam_role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/vpc-flow-logs-role"
    }
    
    # CloudWatch Alarms
    alarms = {
      # CPU Utilization Alarms
      "high-cpu-utilization" = {
        alarm_name = "client-b-prod-high-cpu-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High CPU utilization for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-prod-asg"
        }
      }
      
      # Memory Utilization Alarms
      "high-memory-utilization" = {
        alarm_name = "client-b-prod-high-memory-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "MemoryUtilization"
        namespace = "System/Linux"
        period = 300
        statistic = "Average"
        threshold = 85
        alarm_description = "High memory utilization for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-prod-asg"
        }
      }
      
      # RDS Alarms
      "rds-cpu-utilization" = {
        alarm_name = "client-b-prod-rds-cpu-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High RDS CPU utilization for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          DBInstanceIdentifier = "client-b-prod-mysql"
        }
      }
      
      "rds-connection-count" = {
        alarm_name = "client-b-prod-rds-connection-count"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "DatabaseConnections"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Average"
        threshold = 400
        alarm_description = "High RDS connection count for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          DBInstanceIdentifier = "client-b-prod-mysql"
        }
      }
      
      # ALB Error Rate Alarms
      "alb-5xx-errors" = {
        alarm_name = "client-b-prod-alb-5xx-errors"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "HTTPCode_ELB_5XX_Count"
        namespace = "AWS/ApplicationELB"
        period = 300
        statistic = "Sum"
        threshold = 10
        alarm_description = "High ALB 5XX error rate for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "client-b-prod-alb"
        }
      }
      
      # Target Health Alarms
      "alb-target-health" = {
        alarm_name = "client-b-prod-alb-target-health"
        comparison_operator = "LessThanThreshold"
        evaluation_periods = 1
        metric_name = "HealthyHostCount"
        namespace = "AWS/ApplicationELB"
        period = 60
        statistic = "Average"
        threshold = 2
        alarm_description = "ALB target health check failed for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "client-b-prod-alb"
          TargetGroup = "client-b-prod-app-tg"
        }
      }
      
      # Response Time Alarms
      "alb-response-time" = {
        alarm_name = "client-b-prod-alb-response-time"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 3
        metric_name = "TargetResponseTime"
        namespace = "AWS/ApplicationELB"
        period = 300
        statistic = "Average"
        threshold = 2.0
        alarm_description = "High ALB response time for production environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["prod-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "client-b-prod-alb"
        }
      }
    }
    
    # CloudWatch Dashboard
    dashboard = {
      dashboard_name = "Client-B-Production-Dashboard"
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
                ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "client-b-prod-asg"],
                [".", "MemoryUtilization", ".", "."]
              ]
              period = 300
              stat = "Average"
              region = include.region.locals.region_name
              title = "EC2 CPU and Memory Utilization"
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
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "client-b-prod-mysql"],
                [".", "DatabaseConnections", ".", "."],
                [".", "FreeableMemory", ".", "."]
              ]
              period = 300
              stat = "Average"
              region = include.region.locals.region_name
              title = "RDS Performance"
            }
          },
          {
            type = "metric"
            x = 0
            y = 6
            width = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "client-b-prod-alb"],
                [".", "TargetResponseTime", ".", "."]
              ]
              period = 300
              stat = "Sum"
              region = include.region.locals.region_name
              title = "ALB Request Count and Response Time"
            }
          },
          {
            type = "metric"
            x = 12
            y = 6
            width = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "client-b-prod-alb"],
                [".", "HTTPCode_ELB_5XX_Count", ".", "."],
                [".", "HTTPCode_Target_4XX_Count", ".", "."],
                [".", "HTTPCode_Target_5XX_Count", ".", "."]
              ]
              period = 300
              stat = "Sum"
              region = include.region.locals.region_name
              title = "ALB Error Rates"
            }
          }
        ]
      })
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Monitoring"
  }
} 