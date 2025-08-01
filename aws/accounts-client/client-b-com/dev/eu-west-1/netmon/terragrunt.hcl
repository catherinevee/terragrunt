# ==============================================================================
# Network Monitoring Module Configuration for Client B - Development Environment
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

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Network Monitoring - Development"
  
  # Network monitoring specific configuration for development environment
  netmon_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Network Monitoring"
    
    # VPC Flow Logs configuration
    vpc_flow_logs = {
      enabled = true
      vpc_id = dependency.network.outputs.vpc_id
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flow-logs/dev"
      traffic_type = "ALL"
      max_aggregation_interval = 60
      log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
      tags = {
        Environment = "Development"
        Purpose     = "VPC Flow Logs"
        Owner       = "DevOps Team"
      }
    }
    
    # CloudWatch Logs configuration
    cloudwatch_logs = {
      enabled = true
      log_groups = {
        "vpc-flow-logs-dev" = {
          name = "/aws/vpc/flow-logs/dev"
          retention_in_days = 7
          kms_key_id = null
          tags = {
            Environment = "Development"
            Purpose     = "VPC Flow Logs"
            Owner       = "DevOps Team"
          }
        }
        
        "network-monitoring-dev" = {
          name = "/aws/network/monitoring/dev"
          retention_in_days = 7
          kms_key_id = null
          tags = {
            Environment = "Development"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        "security-events-dev" = {
          name = "/aws/security/events/dev"
          retention_in_days = 7
          kms_key_id = null
          tags = {
            Environment = "Development"
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
        "network-connectivity-dev" = {
          alarm_name = "NetworkConnectivityDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "NetworkConnectivity"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 0
          alarm_description = "Network connectivity issues detected in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          tags = {
            Environment = "Development"
            Purpose     = "Network Connectivity"
            Owner       = "DevOps Team"
          }
        }
        
        # Bandwidth utilization alarms
        "bandwidth-utilization-dev" = {
          alarm_name = "BandwidthUtilizationDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "BandwidthUtilization"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 90
          alarm_description = "High bandwidth utilization in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          tags = {
            Environment = "Development"
            Purpose     = "Bandwidth Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        # Packet loss alarms
        "packet-loss-dev" = {
          alarm_name = "PacketLossDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "PacketLoss"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 10
          alarm_description = "High packet loss detected in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          tags = {
            Environment = "Development"
            Purpose     = "Packet Loss Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        # Latency alarms
        "network-latency-dev" = {
          alarm_name = "NetworkLatencyDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "NetworkLatency"
          namespace = "AWS/NetworkMonitor"
          period = 300
          statistic = "Average"
          threshold = 200
          alarm_description = "High network latency detected in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-alerts-dev"]
          tags = {
            Environment = "Development"
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
        "dev-network-monitor" = {
          monitor_name = "DevNetworkMonitor"
          monitor_type = "INTERNET"
          monitor_specification = {
            source = "10.1.0.0/16"  # Development VPC CIDR
            destination = "8.8.8.8"
            protocol = "TCP"
            port = 80
            packet_size = 56
            interval_seconds = 60
            timeout_seconds = 15
            threshold_count = 5
          }
          tags = {
            Environment = "Development"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
          }
        }
        
        "dev-internal-monitor" = {
          monitor_name = "DevInternalMonitor"
          monitor_type = "INTERNAL"
          monitor_specification = {
            source = "10.1.10.0/24"  # Private subnet
            destination = "10.1.20.0/24"  # Another private subnet
            protocol = "TCP"
            port = 443
            packet_size = 56
            interval_seconds = 60
            timeout_seconds = 15
            threshold_count = 5
          }
          tags = {
            Environment = "Development"
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
        "dev-web-health-check" = {
          fqdn = "dev.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 5
          request_interval = 60
          tags = {
            Environment = "Development"
            Purpose     = "Web Health Check"
            Owner       = "DevOps Team"
          }
        }
        
        "dev-api-health-check" = {
          fqdn = "api-dev.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 5
          request_interval = 60
          tags = {
            Environment = "Development"
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
        finding_publishing_frequency = "SIX_HOURS"
        tags = {
          Environment = "Development"
          Purpose     = "Security Monitoring"
          Owner       = "DevOps Team"
        }
      }
      
      vpc_flow_log_analysis = {
        enabled = true
        log_group_name = "/aws/vpc/flow-logs/dev"
        analysis_frequency = "DAILY"
        alert_on_suspicious_traffic = false
        suspicious_traffic_patterns = [
          "unusual_port_scanning",
          "data_exfiltration",
          "command_and_control"
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Flow Log Analysis"
          Owner       = "DevOps Team"
        }
      }
      
      network_acl_monitoring = {
        enabled = true
        alert_on_denied_requests = false
        alert_on_unusual_patterns = false
        tags = {
          Environment = "Development"
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
          collection_interval = 600
          alert_threshold = 90
        }
        
        packet_loss = {
          enabled = true
          collection_interval = 600
          alert_threshold = 10
        }
        
        latency = {
          enabled = true
          collection_interval = 600
          alert_threshold = 200
        }
        
        jitter = {
          enabled = true
          collection_interval = 600
          alert_threshold = 50
        }
      }
      
      dashboards = {
        enabled = true
        dashboard_name = "DevNetworkDashboard"
        dashboard_body = jsonencode({
          widgets = [
            {
              type = "metric"
              properties = {
                metrics = [
                  ["AWS/NetworkMonitor", "NetworkConnectivity", "Environment", "Development"],
                  ["AWS/NetworkMonitor", "BandwidthUtilization", "Environment", "Development"],
                  ["AWS/NetworkMonitor", "PacketLoss", "Environment", "Development"],
                  ["AWS/NetworkMonitor", "NetworkLatency", "Environment", "Development"]
                ]
                period = 300
                stat = "Average"
                region = "eu-west-1"
                title = "Development Network Metrics"
              }
            }
          ]
        })
        tags = {
          Environment = "Development"
          Purpose     = "Network Dashboard"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Alerting configuration
    alerting = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-network-alerts-dev"
      email_subscribers = [
        "devops@client-b.com"
      ]
      slack_webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
      pagerduty_integration_key = "your-pagerduty-integration-key"
      
      alert_rules = {
        critical_alerts = {
          network_down = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack"]
          }
          
          high_bandwidth = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
          
          high_packet_loss = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
        }
        
        warning_alerts = {
          high_latency = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
          }
          
          unusual_traffic = {
            enabled = false
            severity = "INFO"
            notification_channels = ["email"]
          }
        }
      }
      
      tags = {
        Environment = "Development"
        Purpose     = "Network Alerting"
        Owner       = "DevOps Team"
      }
    }
    
    # Logging and retention configuration
    logging = {
      enabled = true
      log_retention_days = 7
      log_encryption = false
      log_compression = false
      
      log_destinations = {
        cloudwatch_logs = {
          enabled = true
          log_group_prefix = "/aws/network/dev"
        }
        
        s3_bucket = {
          enabled = false
          bucket_name = "client-b-network-logs-dev"
          bucket_prefix = "network-logs/"
        }
      }
      
      tags = {
        Environment = "Development"
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
    Purpose     = "Development Network Monitoring"
    DataClassification = "Internal"
    Compliance  = "GDPR"
    DevelopmentEnvironment = "Yes"
    BusinessImpact = "Low"
    SecurityLevel = "Low"
  }
  
  # Development specific overrides
  dev_overrides = {
    # Network monitoring configuration for development (basic monitoring)
    enable_comprehensive_monitoring = false
    enable_security_monitoring = true
    enable_performance_monitoring = true
    enable_alerting = true
    
    # Monitoring intervals (basic for development)
    monitoring_intervals = {
      flow_logs_interval = 60
      health_check_interval = 60
      metric_collection_interval = 600
      alert_evaluation_interval = 300
    }
    
    # Alert thresholds (lenient for development)
    alert_thresholds = {
      bandwidth_utilization = 90
      packet_loss = 10
      latency = 200
      jitter = 50
      connectivity_timeout = 15
    }
    
    # Development alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_slack_alerts = true
      enable_pagerduty_alerts = false
      
      # Alert recipients for development
      alert_recipients = {
        critical = ["devops@client-b.com"]
        warning = ["devops@client-b.com"]
        info = ["devops@client-b.com"]
      }
    }
    
    # Development logging configuration
    logging_config = {
      enable_detailed_logging = false
      enable_flow_logs = true
      enable_cloudwatch_logs = true
      enable_s3_logging = false
      
      # Log retention for development
      log_retention = {
        flow_logs_days = 7
        cloudwatch_logs_days = 7
        s3_logs_days = 0
      }
    }
    
    # Development performance monitoring
    performance_config = {
      enable_bandwidth_monitoring = true
      enable_latency_monitoring = true
      enable_packet_loss_monitoring = true
      enable_connectivity_monitoring = true
      
      # Performance thresholds for development
      performance_thresholds = {
        bandwidth_warning = 80
        bandwidth_critical = 95
        latency_warning = 150
        latency_critical = 300
        packet_loss_warning = 8
        packet_loss_critical = 15
      }
    }
    
    # Development security monitoring
    security_config = {
      enable_guardduty = true
      enable_flow_log_analysis = true
      enable_nacl_monitoring = true
      enable_suspicious_traffic_detection = false
      
      # Security settings for development
      security_settings = {
        flow_log_analysis_frequency = "DAILY"
        suspicious_traffic_threshold = 50
        alert_on_denied_requests = false
        alert_on_unusual_patterns = false
      }
    }
    
    # Development environment variables
    environment_variables = {
      NODE_ENV = "development"
      DEBUG = "true"
      LOG_LEVEL = "debug"
      ENABLE_NETWORK_DEBUGGING = "true"
      ENABLE_PERFORMANCE_MONITORING = "true"
      ENABLE_SECURITY_MONITORING = "true"
      NETWORK_ALERT_ENABLED = "true"
    }
    
    # Development dashboards
    dashboard_config = {
      enable_network_dashboard = true
      enable_security_dashboard = false
      enable_performance_dashboard = true
      
      # Dashboard settings for development
      dashboard_settings = {
        refresh_interval = "10_minutes"
        default_time_range = "2_hours"
        enable_auto_refresh = false
      }
    }
    
    # Development compliance
    compliance_config = {
      enable_audit_logging = false
      enable_compliance_reporting = false
      enable_data_classification = false
      enable_privacy_protection = false
      
      # GDPR compliance (disabled)
      gdpr_compliance = {
        enable_data_access_controls = false
        enable_data_retention_policies = false
        enable_right_to_be_forgotten = false
        enable_data_portability = false
        enable_privacy_by_design = false
      }
      
      # Security compliance (disabled)
      security_compliance = {
        enable_iso27001_compliance = false
        enable_soc2_compliance = false
        enable_pci_dss_compliance = false
        enable_hipaa_compliance = false
      }
    }
    
    # Development testing features
    testing_features = {
      enable_network_testing = true
      enable_performance_testing = true
      enable_security_testing = false
      
      # Testing configuration
      testing_config = {
        enable_connectivity_tests = true
        enable_bandwidth_tests = true
        enable_latency_tests = true
        enable_security_scanning = false
        
        # Test intervals for development
        test_intervals = {
          connectivity_test_interval = "10_minutes"
          bandwidth_test_interval = "30_minutes"
          latency_test_interval = "10_minutes"
          security_scan_interval = "never"
        }
      }
    }
    
    # Development debugging features
    debugging_features = {
      enable_network_debugging = true
      enable_performance_debugging = true
      enable_security_debugging = false
      
      # Debugging configuration
      debugging_config = {
        enable_detailed_logging = true
        enable_metric_debugging = true
        enable_alert_debugging = true
        enable_flow_log_debugging = true
        
        # Debug settings for development
        debug_settings = {
          log_level = "debug"
          enable_trace_logging = true
          enable_performance_tracing = true
          enable_network_tracing = true
        }
      }
    }
  }
  
  # Compliance and governance (disabled for development)
  compliance_config = {
    enable_audit_logging = false
    enable_compliance_reporting = false
    enable_data_classification = false
    enable_privacy_protection = false
    
    # GDPR compliance (disabled)
    gdpr_compliance = {
      enable_data_access_controls = false
      enable_data_retention_policies = false
      enable_right_to_be_forgotten = false
      enable_data_portability = false
      enable_privacy_by_design = false
    }
    
    # Security compliance (disabled)
    security_compliance = {
      enable_iso27001_compliance = false
      enable_soc2_compliance = false
      enable_pci_dss_compliance = false
      enable_hipaa_compliance = false
    }
  }
} 