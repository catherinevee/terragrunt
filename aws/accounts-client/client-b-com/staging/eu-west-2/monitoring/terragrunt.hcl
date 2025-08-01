# ==============================================================================
# Monitoring Module Configuration for Client B - Staging Environment (eu-west-2)
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
        name = "/aws/application/client-b-staging"
        retention_in_days = 30
        kms_key_id = "alias/aws/logs"
      }
      
      "security-logs" = {
        name = "/aws/security/client-b-staging"
        retention_in_days = 90
        kms_key_id = "alias/aws/logs"
      }
      
      "vpc-flow-logs" = {
        name = "/aws/vpc/flowlogs/client-b-staging"
        retention_in_days = 30
        kms_key_id = "alias/aws/logs"
      }
      
      "alb-access-logs" = {
        name = "/aws/alb/accesslogs/client-b-staging"
        retention_in_days = 30
        kms_key_id = "alias/aws/logs"
      }
    }
    
    # VPC Flow Logs
    vpc_flow_logs = {
      enabled = true
      vpc_id = dependency.vpc.outputs.vpc_id
      traffic_type = "ALL"
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flowlogs/client-b-staging"
      iam_role_arn = "arn:aws:iam::${include.account.locals.account_id}:role/vpc-flow-logs-role"
    }
    
    # CloudWatch Alarms
    alarms = {
      # CPU Utilization Alarms
      "high-cpu-utilization" = {
        alarm_name = "client-b-staging-high-cpu-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High CPU utilization for staging environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-staging-asg"
        }
      }
      
      # Memory Utilization Alarms
      "high-memory-utilization" = {
        alarm_name = "client-b-staging-high-memory-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "MemoryUtilization"
        namespace = "System/Linux"
        period = 300
        statistic = "Average"
        threshold = 85
        alarm_description = "High memory utilization for staging environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        dimensions = {
          AutoScalingGroupName = "client-b-staging-asg"
        }
      }
      
      # RDS Alarms
      "rds-cpu-utilization" = {
        alarm_name = "client-b-staging-rds-cpu-utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "High RDS CPU utilization for staging environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        dimensions = {
          DBInstanceIdentifier = "client-b-staging-mysql"
        }
      }
      
      # ALB Error Rate Alarms
      "alb-5xx-errors" = {
        alarm_name = "client-b-staging-alb-5xx-errors"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "HTTPCode_ELB_5XX_Count"
        namespace = "AWS/ApplicationELB"
        period = 300
        statistic = "Sum"
        threshold = 10
        alarm_description = "High ALB 5XX error rate for staging environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "client-b-staging-alb"
        }
      }
      
      # Target Health Alarms
      "alb-target-health" = {
        alarm_name = "client-b-staging-alb-target-health"
        comparison_operator = "LessThanThreshold"
        evaluation_periods = 1
        metric_name = "HealthyHostCount"
        namespace = "AWS/ApplicationELB"
        period = 60
        statistic = "Average"
        threshold = 1
        alarm_description = "ALB target health check failed for staging environment"
        alarm_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        ok_actions = [dependency.sns.outputs.topic_arns["staging-monitoring-alerts"]]
        dimensions = {
          LoadBalancer = "client-b-staging-alb"
          TargetGroup = "client-b-staging-app-tg"
        }
      }
    }
    
    # CloudWatch Dashboard
    dashboard = {
      dashboard_name = "Client-B-Staging-Dashboard"
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
                ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "client-b-staging-asg"],
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
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "client-b-staging-mysql"],
                [".", "DatabaseConnections", ".", "."]
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
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "client-b-staging-alb"],
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
                ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "client-b-staging-alb"],
                [".", "HTTPCode_ELB_5XX_Count", ".", "."]
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