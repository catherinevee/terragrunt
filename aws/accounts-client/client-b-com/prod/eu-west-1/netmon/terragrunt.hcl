# ==============================================================================
# Network Monitoring Module Configuration for Client B - Production Environment
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
  project     = "Network Monitoring - Production"
  
  # Network monitoring specific configuration for production environment
  netmon_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "Network Monitoring"
    
    # VPC Flow Logs configuration
    vpc_flow_logs = {
      enabled = true
      vpc_id = dependency.network.outputs.vpc_id
      log_destination_type = "cloud-watch-logs"
      log_group_name = "/aws/vpc/flow-logs/prod"
      traffic_type = "ALL"
      max_aggregation_interval = 60
      log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
      tags = {
        Environment = "Production"
        Purpose     = "VPC Flow Logs"
        Owner       = "DevOps Team"
        Compliance  = "SOC2"
        DataClassification = "Confidential"
      }
    }
    
    # CloudWatch Logs configuration
    cloudwatch_logs = {
      enabled = true
      log_groups = {
        "vpc-flow-logs-prod" = {
          name = "/aws/vpc/flow-logs/prod"
          retention_in_days = 90
          kms_key_id = "arn:aws:kms:eu-west-1:987654321098:key/prod-network-logs-key"
          tags = {
            Environment = "Production"
            Purpose     = "VPC Flow Logs"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            DataClassification = "Confidential"
          }
        }
        
        "network-monitoring-prod" = {
          name = "/aws/network/monitoring/prod"
          retention_in_days = 90
          kms_key_id = "arn:aws:kms:eu-west-1:987654321098:key/prod-network-logs-key"
          tags = {
            Environment = "Production"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            DataClassification = "Confidential"
          }
        }
        
        "security-events-prod" = {
          name = "/aws/security/events/prod"
          retention_in_days = 90
          kms_key_id = "arn:aws:kms:eu-west-1:987654321098:key/prod-network-logs-key"
          tags = {
            Environment = "Production"
            Purpose     = "Security Events"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            DataClassification = "Confidential"
          }
        }
        
        "audit-logs-prod" = {
          name = "/aws/audit/logs/prod"
          retention_in_days = 2555  # 7 years for compliance
          kms_key_id = "arn:aws:kms:eu-west-1:987654321098:key/prod-network-logs-key"
          tags = {
            Environment = "Production"
            Purpose     = "Audit Logs"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            DataClassification = "Confidential"
          }
        }
      }
    }
    
    # CloudWatch Alarms configuration
    cloudwatch_alarms = {
      enabled = true
      alarms = {
        # Network connectivity alarms
        "network-connectivity-prod" = {
          alarm_name = "NetworkConnectivityProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "NetworkConnectivity"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Average"
          threshold = 0
          alarm_description = "Network connectivity issues detected in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod",
            "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Network Connectivity"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        # Bandwidth utilization alarms
        "bandwidth-utilization-prod" = {
          alarm_name = "BandwidthUtilizationProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "BandwidthUtilization"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Average"
          threshold = 80
          alarm_description = "High bandwidth utilization in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod",
            "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Bandwidth Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        # Packet loss alarms
        "packet-loss-prod" = {
          alarm_name = "PacketLossProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "PacketLoss"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Average"
          threshold = 5
          alarm_description = "High packet loss detected in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod",
            "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Packet Loss Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        # Latency alarms
        "network-latency-prod" = {
          alarm_name = "NetworkLatencyProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "NetworkLatency"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Average"
          threshold = 100
          alarm_description = "High network latency detected in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod",
            "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Latency Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        # Jitter alarms
        "network-jitter-prod" = {
          alarm_name = "NetworkJitterProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "NetworkJitter"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Average"
          threshold = 20
          alarm_description = "High network jitter detected in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-alerts-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Jitter Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Medium"
          }
        }
        
        # Security threat alarms
        "security-threat-prod" = {
          alarm_name = "SecurityThreatProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "SecurityThreats"
          namespace = "AWS/NetworkMonitor"
          period = 60
          statistic = "Sum"
          threshold = 0
          alarm_description = "Security threats detected in production"
          alarm_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-security-prod",
            "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"
          ]
          ok_actions = [
            "arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"
          ]
          tags = {
            Environment = "Production"
            Purpose     = "Security Monitoring"
            Owner       = "Security Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
          }
        }
      }
    }
    
    # Network Monitor configuration
    network_monitor = {
      enabled = true
      monitors = {
        "prod-network-monitor" = {
          monitor_name = "ProdNetworkMonitor"
          monitor_type = "INTERNET"
          monitor_specification = {
            source = "10.0.0.0/16"  # Production VPC CIDR
            destination = "8.8.8.8"
            protocol = "TCP"
            port = 80
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Production"
            Purpose     = "Network Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        "prod-internal-monitor" = {
          monitor_name = "ProdInternalMonitor"
          monitor_type = "INTERNAL"
          monitor_specification = {
            source = "10.0.10.0/24"  # Private subnet
            destination = "10.0.20.0/24"  # Another private subnet
            protocol = "TCP"
            port = 443
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Production"
            Purpose     = "Internal Network Monitoring"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        "prod-database-monitor" = {
          monitor_name = "ProdDatabaseMonitor"
          monitor_type = "INTERNAL"
          monitor_specification = {
            source = "10.0.10.0/24"  # Application subnet
            destination = "10.0.30.0/24"  # Database subnet
            protocol = "TCP"
            port = 5432
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Production"
            Purpose     = "Database Connectivity"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
          }
        }
        
        "prod-load-balancer-monitor" = {
          monitor_name = "ProdLoadBalancerMonitor"
          monitor_type = "INTERNET"
          monitor_specification = {
            source = "0.0.0.0/0"
            destination = "prod.client-b.com"
            protocol = "HTTPS"
            port = 443
            packet_size = 56
            interval_seconds = 30
            timeout_seconds = 10
            threshold_count = 3
          }
          tags = {
            Environment = "Production"
            Purpose     = "Load Balancer Health"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
          }
        }
      }
    }
    
    # Route 53 Health Checks configuration
    route53_health_checks = {
      enabled = true
      health_checks = {
        "prod-web-health-check" = {
          fqdn = "prod.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Production"
            Purpose     = "Web Health Check"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
          }
        }
        
        "prod-api-health-check" = {
          fqdn = "api.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Production"
            Purpose     = "API Health Check"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
          }
        }
        
        "prod-admin-health-check" = {
          fqdn = "admin.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Production"
            Purpose     = "Admin Health Check"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "High"
          }
        }
        
        "prod-payment-health-check" = {
          fqdn = "payment.client-b.com"
          port = 443
          type = "HTTPS"
          resource_path = "/health"
          failure_threshold = 3
          request_interval = 30
          tags = {
            Environment = "Production"
            Purpose     = "Payment Health Check"
            Owner       = "DevOps Team"
            Compliance  = "SOC2"
            BusinessImpact = "Critical"
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
          Environment = "Production"
          Purpose     = "Security Monitoring"
          Owner       = "Security Team"
          Compliance  = "SOC2"
          DataClassification = "Confidential"
        }
      }
      
      vpc_flow_log_analysis = {
        enabled = true
        log_group_name = "/aws/vpc/flow-logs/prod"
        analysis_frequency = "REALTIME"
        alert_on_suspicious_traffic = true
        suspicious_traffic_patterns = [
          "unusual_port_scanning",
          "data_exfiltration",
          "command_and_control",
          "ddos_attack",
          "brute_force_attack",
          "malware_communication"
        ]
        tags = {
          Environment = "Production"
          Purpose     = "Flow Log Analysis"
          Owner       = "Security Team"
          Compliance  = "SOC2"
          DataClassification = "Confidential"
        }
      }
      
      network_acl_monitoring = {
        enabled = true
        alert_on_denied_requests = true
        alert_on_unusual_patterns = true
        tags = {
          Environment = "Production"
          Purpose     = "NACL Monitoring"
          Owner       = "Security Team"
          Compliance  = "SOC2"
          DataClassification = "Confidential"
        }
      }
      
      security_hub = {
        enabled = true
        enable_security_standards = [
          "AWS-Foundational-Security-Best-Practices-v1.0.0",
          "CIS-AWS-Foundations-Benchmark-v1.2.0",
          "PCI-DSS-v3.2.1"
        ]
        tags = {
          Environment = "Production"
          Purpose     = "Security Hub"
          Owner       = "Security Team"
          Compliance  = "SOC2"
          DataClassification = "Confidential"
        }
      }
    }
    
    # Performance monitoring configuration
    performance_monitoring = {
      enabled = true
      metrics = {
        bandwidth_utilization = {
          enabled = true
          collection_interval = 60
          alert_threshold = 80
        }
        
        packet_loss = {
          enabled = true
          collection_interval = 60
          alert_threshold = 5
        }
        
        latency = {
          enabled = true
          collection_interval = 60
          alert_threshold = 100
        }
        
        jitter = {
          enabled = true
          collection_interval = 60
          alert_threshold = 20
        }
        
        throughput = {
          enabled = true
          collection_interval = 60
          alert_threshold = 1000  # Mbps
        }
        
        error_rate = {
          enabled = true
          collection_interval = 60
          alert_threshold = 1  # Percentage
        }
      }
      
      dashboards = {
        enabled = true
        dashboard_name = "ProdNetworkDashboard"
        dashboard_body = jsonencode({
          widgets = [
            {
              type = "metric"
              properties = {
                metrics = [
                  ["AWS/NetworkMonitor", "NetworkConnectivity", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "BandwidthUtilization", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "PacketLoss", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "NetworkLatency", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "NetworkJitter", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "Throughput", "Environment", "Production"],
                  ["AWS/NetworkMonitor", "ErrorRate", "Environment", "Production"]
                ]
                period = 60
                stat = "Average"
                region = "eu-west-1"
                title = "Production Network Metrics"
              }
            },
            {
              type = "metric"
              properties = {
                metrics = [
                  ["AWS/GuardDuty", "Findings", "Environment", "Production"],
                  ["AWS/SecurityHub", "Findings", "Environment", "Production"]
                ]
                period = 300
                stat = "Sum"
                region = "eu-west-1"
                title = "Security Metrics"
              }
            }
          ]
        })
        tags = {
          Environment = "Production"
          Purpose     = "Network Dashboard"
          Owner       = "DevOps Team"
          Compliance  = "SOC2"
          DataClassification = "Confidential"
        }
      }
    }
    
    # Alerting configuration
    alerting = {
      enabled = true
      sns_topic_arn = "arn:aws:sns:eu-west-1:987654321098:client-b-network-alerts-prod"
      email_subscribers = [
        "devops@client-b.com",
        "security@client-b.com",
        "oncall@client-b.com"
      ]
      slack_webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
      pagerduty_integration_key = "your-pagerduty-integration-key"
      
      alert_rules = {
        critical_alerts = {
          network_down = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
            escalation_timeout = "5_minutes"
          }
          
          high_bandwidth = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
            escalation_timeout = "10_minutes"
          }
          
          high_packet_loss = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
            escalation_timeout = "5_minutes"
          }
          
          security_threat = {
            enabled = true
            severity = "CRITICAL"
            notification_channels = ["email", "slack", "pagerduty"]
            escalation_timeout = "1_minute"
          }
        }
        
        warning_alerts = {
          high_latency = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
            escalation_timeout = "15_minutes"
          }
          
          unusual_traffic = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
            escalation_timeout = "30_minutes"
          }
          
          high_jitter = {
            enabled = true
            severity = "WARNING"
            notification_channels = ["email", "slack"]
            escalation_timeout = "15_minutes"
          }
        }
        
        info_alerts = {
          performance_degradation = {
            enabled = true
            severity = "INFO"
            notification_channels = ["email"]
            escalation_timeout = "60_minutes"
          }
          
          maintenance_notification = {
            enabled = true
            severity = "INFO"
            notification_channels = ["email", "slack"]
            escalation_timeout = "120_minutes"
          }
        }
      }
      
      tags = {
        Environment = "Production"
        Purpose     = "Network Alerting"
        Owner       = "DevOps Team"
        Compliance  = "SOC2"
        DataClassification = "Confidential"
      }
    }
    
    # Logging and retention configuration
    logging = {
      enabled = true
      log_retention_days = 90
      log_encryption = true
      log_compression = true
      
      log_destinations = {
        cloudwatch_logs = {
          enabled = true
          log_group_prefix = "/aws/network/prod"
        }
        
        s3_bucket = {
          enabled = true
          bucket_name = "client-b-network-logs-prod"
          bucket_prefix = "network-logs/"
          encryption = true
          versioning = true
          lifecycle_rules = {
            transition_to_ia = 30
            transition_to_glacier = 90
            expiration_days = 2555  # 7 years for compliance
          }
        }
      }
      
      tags = {
        Environment = "Production"
        Purpose     = "Network Logging"
        Owner       = "DevOps Team"
        Compliance  = "SOC2"
        DataClassification = "Confidential"
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
    Purpose     = "Production Network Monitoring"
    DataClassification = "Confidential"
    Compliance  = "SOC2"
    ProductionEnvironment = "Yes"
    BusinessImpact = "Critical"
    SecurityLevel = "High"
    DisasterRecovery = "Enabled"
    BackupRetention = "7Years"
    Encryption = "Enabled"
    Monitoring = "24x7"
    Alerting = "Enabled"
    SLA = "99.9%"
  }
  
  # Production specific overrides
  production_overrides = {
    # Network monitoring configuration for production (comprehensive monitoring)
    enable_comprehensive_monitoring = true
    enable_security_monitoring = true
    enable_performance_monitoring = true
    enable_alerting = true
    enable_compliance_monitoring = true
    
    # Monitoring intervals (aggressive for production)
    monitoring_intervals = {
      flow_logs_interval = 60
      health_check_interval = 30
      metric_collection_interval = 60
      alert_evaluation_interval = 60
      security_scan_interval = 300
    }
    
    # Alert thresholds (strict for production)
    alert_thresholds = {
      bandwidth_utilization = 80
      packet_loss = 5
      latency = 100
      jitter = 20
      connectivity_timeout = 10
      error_rate = 1
    }
    
    # Production alerting configuration
    alerting_config = {
      enable_email_alerts = true
      enable_slack_alerts = true
      enable_pagerduty_alerts = true
      enable_sms_alerts = true
      
      # Alert recipients for production
      alert_recipients = {
        critical = ["devops@client-b.com", "security@client-b.com", "oncall@client-b.com"]
        warning = ["devops@client-b.com", "security@client-b.com"]
        info = ["devops@client-b.com"]
      }
      
      # Escalation policies
      escalation_policies = {
        critical_escalation_timeout = "5_minutes"
        warning_escalation_timeout = "15_minutes"
        info_escalation_timeout = "60_minutes"
      }
    }
    
    # Production logging configuration
    logging_config = {
      enable_detailed_logging = true
      enable_flow_logs = true
      enable_cloudwatch_logs = true
      enable_s3_logging = true
      enable_audit_logging = true
      
      # Log retention for production
      log_retention = {
        flow_logs_days = 90
        cloudwatch_logs_days = 90
        s3_logs_days = 2555  # 7 years for compliance
        audit_logs_days = 2555  # 7 years for compliance
      }
      
      # Log encryption
      log_encryption = {
        enable_kms_encryption = true
        enable_s3_encryption = true
        enable_transit_encryption = true
      }
    }
    
    # Production performance monitoring
    performance_config = {
      enable_bandwidth_monitoring = true
      enable_latency_monitoring = true
      enable_packet_loss_monitoring = true
      enable_connectivity_monitoring = true
      enable_throughput_monitoring = true
      enable_error_rate_monitoring = true
      
      # Performance thresholds for production
      performance_thresholds = {
        bandwidth_warning = 70
        bandwidth_critical = 80
        latency_warning = 80
        latency_critical = 100
        packet_loss_warning = 3
        packet_loss_critical = 5
        error_rate_warning = 0.5
        error_rate_critical = 1
      }
    }
    
    # Production security monitoring
    security_config = {
      enable_guardduty = true
      enable_flow_log_analysis = true
      enable_nacl_monitoring = true
      enable_suspicious_traffic_detection = true
      enable_security_hub = true
      enable_macie = true
      
      # Security settings for production
      security_settings = {
        flow_log_analysis_frequency = "REALTIME"
        suspicious_traffic_threshold = 10
        alert_on_denied_requests = true
        alert_on_unusual_patterns = true
        enable_threat_intelligence = true
        enable_behavioral_analysis = true
      }
    }
    
    # Production environment variables
    environment_variables = {
      NODE_ENV = "production"
      DEBUG = "false"
      LOG_LEVEL = "info"
      ENABLE_NETWORK_DEBUGGING = "false"
      ENABLE_PERFORMANCE_MONITORING = "true"
      ENABLE_SECURITY_MONITORING = "true"
      NETWORK_ALERT_ENABLED = "true"
      COMPLIANCE_MODE = "strict"
      SECURITY_MODE = "high"
    }
    
    # Production dashboards
    dashboard_config = {
      enable_network_dashboard = true
      enable_security_dashboard = true
      enable_performance_dashboard = true
      enable_compliance_dashboard = true
      
      # Dashboard settings for production
      dashboard_settings = {
        refresh_interval = "1_minute"
        default_time_range = "1_hour"
        enable_auto_refresh = true
        enable_real_time_metrics = true
      }
    }
    
    # Production compliance
    compliance_config = {
      enable_audit_logging = true
      enable_compliance_reporting = true
      enable_data_classification = true
      enable_privacy_protection = true
      
      # GDPR compliance (enabled)
      gdpr_compliance = {
        enable_data_access_controls = true
        enable_data_retention_policies = true
        enable_right_to_be_forgotten = true
        enable_data_portability = true
        enable_privacy_by_design = true
      }
      
      # Security compliance (enabled)
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
      enable_replication_monitoring = true
      enable_failover_monitoring = true
      
      # DR settings
      dr_settings = {
        backup_retention_days = 2555  # 7 years
        replication_lag_threshold = 300  # 5 minutes
        failover_time_threshold = 600  # 10 minutes
        enable_automated_failover = true
      }
    }
    
    # Production security features
    security_features = {
      enable_network_segmentation = true
      enable_intrusion_detection = true
      enable_vulnerability_scanning = true
      enable_penetration_testing = true
      
      # Security scanning
      security_scanning = {
        vulnerability_scan_interval = "daily"
        penetration_test_interval = "quarterly"
        security_assessment_interval = "monthly"
        enable_continuous_monitoring = true
      }
    }
    
    # Production performance optimization
    performance_optimization = {
      enable_auto_scaling = true
      enable_load_balancing = true
      enable_caching = true
      enable_cdn = true
      
      # Performance settings
      performance_settings = {
        auto_scaling_cooldown = 300
        load_balancer_health_check_interval = 30
        cache_ttl = 3600
        cdn_cache_behavior = "cache_all"
      }
    }
  }
  
  # Compliance and governance (enabled for production)
  compliance_config = {
    enable_audit_logging = true
    enable_compliance_reporting = true
    enable_data_classification = true
    enable_privacy_protection = true
    
    # GDPR compliance (enabled)
    gdpr_compliance = {
      enable_data_access_controls = true
      enable_data_retention_policies = true
      enable_right_to_be_forgotten = true
      enable_data_portability = true
      enable_privacy_by_design = true
    }
    
    # Security compliance (enabled)
    security_compliance = {
      enable_iso27001_compliance = true
      enable_soc2_compliance = true
      enable_pci_dss_compliance = true
      enable_hipaa_compliance = true
    }
  }
} 