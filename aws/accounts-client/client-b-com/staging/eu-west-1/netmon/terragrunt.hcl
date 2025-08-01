# ==============================================================================
# Network Monitoring Module Configuration for Client B - Staging Environment
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
  source = "git::https://github.com/catherinevee/tfm-aws-netmon.git//?ref=v1.0.0"
}

# Dependencies (uncomment and configure as needed)
dependency "network" {
  config_path = "../network"
}

dependency "iam" {
  config_path = "../iam"
}

dependency "sns" {
  config_path = "../sns"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Network Monitoring - Staging"
  
  # Network monitoring specific configuration for staging environment
  netmon_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "Network Monitoring"
    
    # VPC Flow Logs configuration
    vpc_flow_logs = {
      enabled = true
      vpc_id = dependency.network.outputs.vpc_id
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flow-logs/staging"
      traffic_type = "ALL"
      max_aggregation_interval = 60
      log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
      tags = {
        Environment = "Staging"
        Purpose     = "VPC Flow Logs"
        Owner       = "DevOps Team"
      }
    }
    
    # CloudWatch Logs configuration
    cloudwatch_logs = {
      enabled = true
      log_groups = {
        "vpc-flow-logs-staging" = {
          name = "/aws/vpc/flow-logs/staging"
          retention_in_days = 30
          kms_key_id = null
          tags = {
            Environment = "Staging"
            Purpose     = "VPC Flow Logs"
            Owner       = "DevOps Team"
          }
        }
        
        "network-monitoring-staging" = {
          name = "/aws/network/monitoring/staging"
          retention_in_days = 30
          kms_key_id = null
          tags = {
            Environment = "Staging"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        "security-events-staging" = {
          name = "/aws/security/events/staging"
          retention_in_days = 30
          kms_key_id = null
          tags = {
            Environment = "Staging"
            Purpose     = "Security Events"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # CloudWatch Alarms configuration
    cloudwatch_alarms = {
      enabled = true
      alarms = {
        # Network connectivity alarms
        "network-connectivity-staging" = {
          alarm_name = "NetworkConnectivityStaging"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "NetworkConnectivity"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 0
          alarm_description = "Network connectivity issues detected in staging"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          tags = {
            Environment = "Staging"
            Purpose     = "Network Connectivity"
            Owner       = "DevOps Team"
          }
        }
        
        # Bandwidth utilization alarms
        "bandwidth-utilization-staging" = {
          alarm_name = "BandwidthUtilizationStaging"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "BandwidthUtilization"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 80
          alarm_description = "High bandwidth utilization in staging"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          tags = {
            Environment = "Staging"
            Purpose     = "Bandwidth Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        # Packet loss alarms
        "packet-loss-staging" = {
          alarm_name = "PacketLossStaging"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "PacketLoss"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 5
          alarm_description = "High packet loss detected in staging"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          tags = {
            Environment = "Staging"
            Purpose     = "Packet Loss Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        # Latency alarms
        "network-latency-staging" = {
          alarm_name = "NetworkLatencyStaging"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "NetworkLatency"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 100
          alarm_description = "High network latency detected in staging"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-staging"]
          tags = {
            Environment = "Staging"
            Purpose     = "Latency Monitoring"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Network Monitor configuration
    network_monitor = {
      enabled = true
      monitors = {
        "staging-network-monitor" = {
          monitor_name = "StagingNetworkMonitor"
          monitor_type = "INTERNET"
          monitor_specification = {
            source = "10.3.0.0/16"  # Staging VPC CIDR
            destination = "8.8.8.8"
            protocol = "TCP"
            port = 80
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Staging"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        "staging-internal-monitor" = {
          monitor_name = "StagingInternalMonitor"
          monitor_type = "INTERNAL"
          monitor_specification = {
            source = "10.3.10.0/24"  # Private subnet
            destination = "10.3.20.0/24"  # Another private subnet
            protocol = "TCP"
            port = 443
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Staging"
            Purpose     = "Internal Network Monitoring"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Route 53 Health Checks configuration
    route53_health_checks = {
      enabled = true
      health_checks = {
        "staging-web-health-check" = {
          fqdn = "staging.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Staging"
            Purpose     = "Web Health Check"
            Owner       = "DevOps Team"
          }
        }
        
        "staging-api-health-check" = {
          fqdn = "api-staging.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Staging"
            Purpose     = "API Health Check"
            Owner       = "DevOps Team"
          }
        }
      }
    }
    
    # Security monitoring configuration
    security_monitoring = {
      enabled = true
      guardduty = {
        enabled = true
        finding_publishing_frequency = "FIFTEEN_MINUTES"
        tags = {
          Environment = "Staging"
          Purpose     = "Security Monitoring"
          Owner       = "DevOps Team"
        }
      }
      
      vpc_flow_log_analysis = {
        enabled = true
        log_group_name = "/aws/vpc/flow-logs/staging"
        analysis_frequency = "HOURLY"
        alert_on_suspicious_traffic = true
        suspicious_traffic_patterns = [
          "unusual_port_scanning",
          "data_exfiltration",
          "command_and_control"
        ]
        tags = {
          Environment = "Staging"
          Purpose     = "Flow Log Analysis"
          Owner       = "DevOps Team"
        }
      }
      
      network_acl_monitoring = {
        enabled = true
        alert_on_denied_requests = true
        alert_on_unusual_patterns = true
        tags = {
          Environment = "Staging"
          Purpose     = "NACL Monitoring"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Performance monitoring configuration
    performance_monitoring = {
      enabled = true
      metrics = {
        bandwidth_utilization = {
          enabled = true
          collection_interval = 300
          alert_threshold = 80
        }
        
        packet_loss = {
          enabled = true
          collection_interval = 300
          alert_threshold = 5
        }
        
        latency = {
          enabled = true
          collection_interval = 300
          alert_threshold = 100
        }
        
        jitter = {
          enabled = true
          collection_interval = 300
          alert_threshold = 20
        }
      }
      
      dashboards = {
        enabled = true
        dashboard_name = "StagingNetworkDashboard"
        dashboard_body = jsonencode({
          widgets = [
            {
              type = "metric"
              properties = {
                metrics = [
                  ["AWS/NetworkMonitor", "NetworkConnectivity", "Environment", "Staging"],
                  ["AWS/NetworkMonitor", "BandwidthUtilization", "Environment", "Staging"],
                  ["AWS/NetworkMonitor", "PacketLoss", "Environment", "Staging"],
                  ["AWS/NetworkMonitor", "NetworkLatency", "Environment", "Staging"]
                ]
                period = 300
                stat = "Average"
                region = "eu-west-1"
                title = "Staging Network Metrics"
              }
            }
          ]
        })
        tags = {
          Environment = "Staging"
          Purpose     = "Network Dashboard"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Alerting configuration
    alerting = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-network-alerts-staging"
      email_subscribers = [
        "devops@client-b.com",
        "network-team@client-b.com"
      ]
      slack_webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
      pagerduty_integration_key = "your-pagerduty-integration-key"
      
      alert_rules = {
        critical_alerts = {
          network_down = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
          }
          
          high_bandwidth = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
          
          high_packet_loss = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
          }
        }
        
        warning_alerts = {
          high_latency = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
          
          unusual_traffic = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
        }
      }
      
      tags = {
        Environment = "Staging"
        Purpose     = "Network Alerting"
        Owner       = "DevOps Team"
      }
    }
    
    # Logging and retention configuration
    logging = {
      enabled = true
      log_retention_days = 30
      log_encryption = true
      log_compression = true
      
      log_destinations = {
        cloudwatch_logs = {
          enabled = true
          log_group_prefix = "/aws/network/staging"
        }
        
        s3_bucket = {
          enabled = true
          bucket_name = "client-b-network-logs-staging"
          bucket_prefix = "network-logs/"
        }
      }
      
      tags = {
        Environment = "Staging"
        Purpose     = "Network Logging"
        Owner       = "DevOps Team"
      }
    }
  }
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "Network Monitoring"
    CostCenter  = "ClientB"
    Owner       = "DevOps Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Staging Network Monitoring"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    StagingEnvironment = "Yes"
    BusinessImpact = "Medium"
    SecurityLevel = "Medium"
  }
  
  # Staging specific overrides
  staging_overrides = {
    # Network monitoring configuration for staging (moderate monitoring)
    enable_comprehensive_monitoring = true
    enable_security_monitoring = true
    enable_performance_monitoring = true
    enable_alerting = true
    
    # Monitoring intervals (moderate for staging)
    monitoring_intervals = {
      flow_logs_interval = 60
      health_check_interval = 30
      metric_collection_interval = 300
      alert_evaluation_interval = 300
    }
    
    # Alert thresholds (moderate for staging)
    alert_thresholds = {
      bandwidth_utilization = 80
      packet_loss = 5
      latency = 100
      jitter = 20
      connectivity_timeout = 10
    }
    
    # Staging alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_slack_alerts = true
      enable_pagerduty_alerts = false
      
      # Alert recipients for staging
      alert_recipients = {
        critical = ["devops@client-b.com", "network-team@client-b.com"]
        warning = ["devops@client-b.com"]
        info = ["devops@client-b.com"]
      }
    }
    
    # Staging logging configuration
    logging_config = {
      enable_detailed_logging = true
      enable_flow_logs = true
      enable_cloudwatch_logs = true
      enable_s3_logging = true
      
      # Log retention for staging
      log_retention = {
        flow_logs_days = 30
        cloudwatch_logs_days = 30
        s3_logs_days = 90
      }
    }
    
    # Staging performance monitoring
    performance_config = {
      enable_bandwidth_monitoring = true
      enable_latency_monitoring = true
      enable_packet_loss_monitoring = true
      enable_connectivity_monitoring = true
      
      # Performance thresholds for staging
      performance_thresholds = {
        bandwidth_warning = 70
        bandwidth_critical = 90
        latency_warning = 80
        latency_critical = 150
        packet_loss_warning = 3
        packet_loss_critical = 8
      }
    }
    
    # Staging security monitoring
    security_config = {
      enable_guardduty = true
      enable_flow_log_analysis = true
      enable_nacl_monitoring = true
      enable_suspicious_traffic_detection = true
      
      # Security settings for staging
      security_settings = {
        flow_log_analysis_frequency = "HOURLY"
        suspicious_traffic_threshold = 10
        alert_on_denied_requests = true
        alert_on_unusual_patterns = true
      }
    }
    
    # Staging environment variables
    environment_variables = {
      NODE_ENV = "staging"
      DEBUG = "false"
      LOG_LEVEL = "info"
      ENABLE_NETWORK_DEBUGGING = "false"
      ENABLE_PERFORMANCE_MONITORING = "true"
      ENABLE_SECURITY_MONITORING = "true"
      NETWORK_ALERT_ENABLED = "true"
    }
    
    # Staging dashboards
    dashboard_config = {
      enable_network_dashboard = true
      enable_security_dashboard = true
      enable_performance_dashboard = true
      
      # Dashboard settings for staging
      dashboard_settings = {
        refresh_interval = "5_minutes"
        default_time_range = "1_hour"
        enable_auto_refresh = true
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
      enable_network_testing = true
      enable_performance_testing = true
      enable_security_testing = true
      
      # Testing configuration
      testing_config = {
        enable_connectivity_tests = true
        enable_bandwidth_tests = true
        enable_latency_tests = true
        enable_security_scanning = true
        
        # Test intervals for staging
        test_intervals = {
          connectivity_test_interval = "5_minutes"
          bandwidth_test_interval = "15_minutes"
          latency_test_interval = "5_minutes"
          security_scan_interval = "1_hour"
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