include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "tfr://terraform-aws-modules/cloudwatch/aws//modules/log-group?version=4.3.2"
}

inputs = {
  name              = "/aws/cyprus/accounts-client"
  retention_in_days = 30
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cyprus-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS CPU utilization"
  
  dimensions = {
    ClusterName = "cyprus-cluster"
    ServiceName = "accounts-client-service"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "cyprus-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS memory utilization"
  
  dimensions = {
    ClusterName = "cyprus-cluster"
    ServiceName = "accounts-client-service"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "cyprus-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  
  dimensions = {
    DBInstanceIdentifier = "cyprus-accounts-client"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
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