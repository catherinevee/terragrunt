include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  cloudwatch_config = local.account_vars.locals.cloudwatch_config
  
  # Input validation for CloudWatch module
  validate_log_group_name = length("/aws/cyprus/accounts-client") <= 512 ? null : file("ERROR: Log group name must be <= 512 characters")
  validate_log_group_name_format = can(regex("^[a-zA-Z0-9_/.-]+$", "/aws/cyprus/accounts-client")) ? null : file("ERROR: Log group name must contain only alphanumeric characters, underscores, slashes, dots, and hyphens")
  validate_log_retention = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], local.cloudwatch_config.log_retention_days) ? null : file("ERROR: Log retention must be one of the allowed values")
  validate_cpu_threshold = local.cloudwatch_config.cpu_threshold >= 1 && local.cloudwatch_config.cpu_threshold <= 100 ? null : file("ERROR: CPU threshold must be between 1 and 100")
  validate_memory_threshold = local.cloudwatch_config.memory_threshold >= 1 && local.cloudwatch_config.memory_threshold <= 100 ? null : file("ERROR: Memory threshold must be between 1 and 100")
  validate_alarm_name_length = length("cyprus-ecs-cpu-high") <= 255 ? null : file("ERROR: Alarm name must be <= 255 characters")
  validate_alarm_name_format = can(regex("^[a-zA-Z0-9_-]+$", "cyprus-ecs-cpu-high")) ? null : file("ERROR: Alarm name must contain only alphanumeric characters, hyphens, and underscores")
}

terraform {
  source = "tfr://terraform-aws-modules/cloudwatch/aws//modules/log-group?version=4.3.2"
}

inputs = {
  name              = "/aws/cyprus/accounts-client"
  retention_in_days = local.cloudwatch_config.log_retention_days
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "monitoring-logs"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = local.cloudwatch_config.enable_alarms ? 1 : 0
  
  alarm_name          = "cyprus-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = tostring(local.cloudwatch_config.cpu_threshold)
  alarm_description   = "This metric monitors ECS CPU utilization"
  
  dimensions = {
    ClusterName = "cyprus-cluster"
    ServiceName = "accounts-client-service"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "performance-monitoring"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count = local.cloudwatch_config.enable_alarms ? 1 : 0
  
  alarm_name          = "cyprus-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = tostring(local.cloudwatch_config.memory_threshold)
  alarm_description   = "This metric monitors ECS memory utilization"
  
  dimensions = {
    ClusterName = "cyprus-cluster"
    ServiceName = "accounts-client-service"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "performance-monitoring"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = local.cloudwatch_config.enable_alarms ? 1 : 0
  
  alarm_name          = "cyprus-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = tostring(local.cloudwatch_config.cpu_threshold)
  alarm_description   = "This metric monitors RDS CPU utilization"
  
  dimensions = {
    DBInstanceIdentifier = "cyprus-accounts-client"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "database-monitoring"
  }
}

# Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "cyprus-accounts-client-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "cyprus-cluster", "ServiceName", "accounts-client-service"],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-1"
          title  = "ECS Service Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "cyprus-accounts-client"],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeableMemory", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = "eu-west-1"
          title  = "RDS Metrics"
        }
      }
    ]
  })
} 