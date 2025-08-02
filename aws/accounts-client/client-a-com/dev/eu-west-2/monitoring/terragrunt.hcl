# ==============================================================================
# Monitoring Module Configuration for Client A - Development Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
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

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/monitoring.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "Monitoring - Development (eu-west-2)"
  
  # VPC reference
  vpc_id = dependency.vpc.outputs.vpc_id
  
  # SNS topic references
  alerts_topic_arn = dependency.sns.outputs.alerts_topic_arn
  monitoring_topic_arn = dependency.sns.outputs.monitoring_topic_arn
  
  # Monitoring configuration for development environment
  monitoring_config = {
    # CloudWatch Log Groups
    log_groups = {
      # Application logs
      app_logs = {
        name = "/aws/application/client-a-dev"
        retention_in_days = 7  # 7 days for dev
        kms_key_id = "alias/aws/logs"
        tags = {
          Name = "client-a-dev-app-logs"
          Purpose = "Application Logs"
          Environment = "Development"
        }
      }
      
      # System logs
      system_logs = {
        name = "/aws/system/client-a-dev"
        retention_in_days = 7  # 7 days for dev
        kms_key_id = "alias/aws/logs"
        tags = {
          Name = "client-a-dev-system-logs"
          Purpose = "System Logs"
          Environment = "Development"
        }
      }
      
      # Security logs
      security_logs = {
        name = "/aws/security/client-a-dev"
        retention_in_days = 30  # 30 days for security logs
        kms_key_id = "alias/aws/logs"
        tags = {
          Name = "client-a-dev-security-logs"
          Purpose = "Security Logs"
          Environment = "Development"
        }
      }
    }
    
    # CloudWatch Alarms
    alarms = {
      # CPU utilization alarm
      cpu_utilization = {
        name = "client-a-dev-cpu-utilization"
        description = "Alarm for high CPU utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "CPUUtilization"
        namespace = "AWS/EC2"
        period = 300
        statistic = "Average"
        threshold = 80
        alarm_description = "CPU utilization is high"
        alarm_actions = [dependency.sns.outputs.alerts_topic_arn]
        ok_actions = [dependency.sns.outputs.alerts_topic_arn]
        tags = {
          Name = "client-a-dev-cpu-utilization"
          Purpose = "CPU Monitoring"
          Environment = "Development"
        }
      }
      
      # Memory utilization alarm
      memory_utilization = {
        name = "client-a-dev-memory-utilization"
        description = "Alarm for high memory utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "MemoryUtilization"
        namespace = "System/Linux"
        period = 300
        statistic = "Average"
        threshold = 85
        alarm_description = "Memory utilization is high"
        alarm_actions = [dependency.sns.outputs.alerts_topic_arn]
        ok_actions = [dependency.sns.outputs.alerts_topic_arn]
        tags = {
          Name = "client-a-dev-memory-utilization"
          Purpose = "Memory Monitoring"
          Environment = "Development"
        }
      }
      
      # Disk utilization alarm
      disk_utilization = {
        name = "client-a-dev-disk-utilization"
        description = "Alarm for high disk utilization"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "DiskSpaceUtilization"
        namespace = "System/Linux"
        period = 300
        statistic = "Average"
        threshold = 90
        alarm_description = "Disk utilization is high"
        alarm_actions = [dependency.sns.outputs.alerts_topic_arn]
        ok_actions = [dependency.sns.outputs.alerts_topic_arn]
        tags = {
          Name = "client-a-dev-disk-utilization"
          Purpose = "Disk Monitoring"
          Environment = "Development"
        }
      }
      
      # ALB response time alarm
      alb_response_time = {
        name = "client-a-dev-alb-response-time"
        description = "Alarm for high ALB response time"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "TargetResponseTime"
        namespace = "AWS/ApplicationELB"
        period = 300
        statistic = "Average"
        threshold = 5  # 5 seconds
        alarm_description = "ALB response time is high"
        alarm_actions = [dependency.sns.outputs.alerts_topic_arn]
        ok_actions = [dependency.sns.outputs.alerts_topic_arn]
        tags = {
          Name = "client-a-dev-alb-response-time"
          Purpose = "ALB Performance Monitoring"
          Environment = "Development"
        }
      }
      
      # RDS connections alarm
      rds_connections = {
        name = "client-a-dev-rds-connections"
        description = "Alarm for high RDS connections"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods = 2
        metric_name = "DatabaseConnections"
        namespace = "AWS/RDS"
        period = 300
        statistic = "Average"
        threshold = 80  # 80% of max connections
        alarm_description = "RDS database connections are high"
        alarm_actions = [dependency.sns.outputs.alerts_topic_arn]
        ok_actions = [dependency.sns.outputs.alerts_topic_arn]
        tags = {
          Name = "client-a-dev-rds-connections"
          Purpose = "RDS Monitoring"
          Environment = "Development"
        }
      }
    }
    
    # VPC Flow Logs
    vpc_flow_logs = {
      enabled = true
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flow-logs/client-a-dev"
      traffic_type = "ALL"
      retention_in_days = 7  # 7 days for dev
      tags = {
        Name = "client-a-dev-vpc-flow-logs"
        Purpose = "VPC Flow Logs"
        Environment = "Development"
      }
    }
    
    # CloudWatch Dashboard
    dashboard = {
      name = "client-a-dev-dashboard"
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
                ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "client-a-dev-web-asg"],
                [".", ".", ".", "client-a-dev-app-asg"]
              ]
              period = 300
              stat = "Average"
              region = include.region.locals.region_name
              title = "CPU Utilization"
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
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "client-a-dev-alb"],
                [".", "TargetResponseTime", ".", "."]
              ]
              period = 300
              stat = "Sum"
              region = include.region.locals.region_name
              title = "ALB Metrics"
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
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "client-a-dev-mysql"],
                [".", "DatabaseConnections", ".", "."]
              ]
              period = 300
              stat = "Average"
              region = include.region.locals.region_name
              title = "RDS Metrics"
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
                ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "client-a-dev-redis"],
                [".", "CurrConnections", ".", "."]
              ]
              period = 300
              stat = "Average"
              region = include.region.locals.region_name
              title = "ElastiCache Metrics"
            }
          }
        ]
      })
      tags = {
        Name = "client-a-dev-dashboard"
        Purpose = "Development Environment Dashboard"
        Environment = "Development"
      }
    }
  }
  
  # Tags for all monitoring resources
  tags = {
    Environment = "Development"
    Project     = "Client A Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    Client      = "Client A"
  }
} 