# ==============================================================================
# Network Firewall Module Configuration for Client B - Production Environment
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
  source = "git::https://github.com/catherinevee/tfm-aws-networkfirewall.git//?ref=v1.0.0"
}

# Dependencies (uncomment and configure as needed)
dependency "vpc" {
  config_path = "../vpc"
}

dependency "iam" {
  config_path = "../iam"
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
  project     = "Network Firewall - Production"
  
  # Network firewall specific configuration for production environment
  network_firewall_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "Network Firewall"
    
    # Network Firewall configuration
    network_firewall = {
      enabled = true
      firewall_name = "ClientBProdNetworkFirewall"
      firewall_policy_arn = "arn:aws:network-firewall:eu-west-1:987654321098:firewall-policy/client-b-prod-firewall-policy"
      
      # VPC configuration
      vpc_id = dependency.vpc.outputs.vpc_id
      vpc_subnets = dependency.vpc.outputs.private_subnet_ids
      
      # Firewall subnet configuration
      firewall_subnets = {
        "firewall-subnet-1" = {
          subnet_id = dependency.vpc.outputs.private_subnet_ids[0]
          availability_zone = include.region.locals.region_config.azs[0]
        }
        "firewall-subnet-2" = {
          subnet_id = dependency.vpc.outputs.private_subnet_ids[1]
          availability_zone = include.region.locals.region_config.azs[1]
        }
        "firewall-subnet-3" = {
          subnet_id = dependency.vpc.outputs.private_subnet_ids[2]
          availability_zone = include.region.locals.region_config.azs[2]
        }
      }
      
      # Firewall policy configuration
      firewall_policy = {
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
        stateful_rule_group_references = [
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateful-rulegroup/client-b-prod-domain-list"
            priority = 1
          },
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateful-rulegroup/client-b-prod-suricata-rules"
            priority = 2
          },
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateful-rulegroup/client-b-prod-threat-intelligence"
            priority = 3
          }
        ]
        stateless_rule_group_references = [
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateless-rulegroup/client-b-prod-custom-rules"
            priority = 1
          }
        ]
      }
      
      # Logging configuration
      logging_configuration = {
        log_destination_configs = [
          {
            log_type = "ALERT"
            log_destination_type = "CloudWatchLogs"
            log_destination = {
              log_group = "/aws/network-firewall/prod/alerts"
            }
          },
          {
            log_type = "FLOW"
            log_destination_type = "CloudWatchLogs"
            log_destination = {
              log_group = "/aws/network-firewall/prod/flows"
            }
          },
          {
            log_type = "TLS"
            log_destination_type = "CloudWatchLogs"
            log_destination = {
              log_group = "/aws/network-firewall/prod/tls"
            }
          }
        ]
      }
      
      tags = {
        Environment = "Production"
        Purpose     = "Network Firewall"
        Owner       = "Security Team"
        Compliance  = "SOC2, PCI-DSS, HIPAA"
        DataClassification = "Confidential"
        Criticality = "High"
        BackupRequired = "Yes"
        DisasterRecovery = "Required"
      }
    }
    
    # Stateful rule groups configuration
    stateful_rule_groups = {
      "domain-list-rule-group" = {
        rule_group_name = "ClientBProdDomainList"
        rule_group_type = "DOMAIN_LIST"
        rules_string = <<EOF
# Allow trusted domains for production
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow trusted domains"; sid:1001; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow AWS services"; sid:1002; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow payment processors"; sid:1003; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow monitoring services"; sid:1004; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow security services"; sid:1005; rev:1;)
EOF
        tags = {
          Environment = "Production"
          Purpose     = "Domain List Rules"
          Owner       = "Security Team"
          Compliance  = "SOC2"
        }
      }
      
      "suricata-rule-group" = {
        rule_group_name = "ClientBProdSuricataRules"
        rule_group_type = "STATEFUL"
        rules_string = <<EOF
# Comprehensive security rules for production
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Suspicious outbound connection"; sid:2001; rev:1;)
alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Suspicious inbound connection"; sid:2002; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 22 (msg:"SSH outbound connection"; sid:2003; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 3389 (msg:"RDP outbound connection"; sid:2004; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 1433 (msg:"SQL Server outbound connection"; sid:2005; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 3306 (msg:"MySQL outbound connection"; sid:2006; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 5432 (msg:"PostgreSQL outbound connection"; sid:2007; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 6379 (msg:"Redis outbound connection"; sid:2008; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 27017 (msg:"MongoDB outbound connection"; sid:2009; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 9200 (msg:"Elasticsearch outbound connection"; sid:2010; rev:1;)
# Allow essential production traffic
PASS tcp $HOME_NET any -> $EXTERNAL_NET 80 (msg:"Allow HTTP for production"; sid:2011; rev:1;)
PASS tcp $HOME_NET any -> $EXTERNAL_NET 443 (msg:"Allow HTTPS for production"; sid:2012; rev:1;)
PASS tcp $HOME_NET any -> $EXTERNAL_NET 53 (msg:"Allow DNS for production"; sid:2013; rev:1;)
PASS udp $HOME_NET any -> $EXTERNAL_NET 53 (msg:"Allow DNS UDP for production"; sid:2014; rev:1;)
EOF
        tags = {
          Environment = "Production"
          Purpose     = "Suricata Rules"
          Owner       = "Security Team"
          Compliance  = "SOC2, PCI-DSS"
        }
      }
      
      "threat-intelligence-rule-group" = {
        rule_group_name = "ClientBProdThreatIntelligence"
        rule_group_type = "STATEFUL"
        rules_string = <<EOF
# Threat intelligence rules for production
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Known malicious IP"; sid:3001; rev:1;)
alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Known malicious IP inbound"; sid:3002; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Suspicious domain access"; sid:3003; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Data exfiltration attempt"; sid:3004; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Command and control traffic"; sid:3005; rev:1;)
EOF
        tags = {
          Environment = "Production"
          Purpose     = "Threat Intelligence"
          Owner       = "Security Team"
          Compliance  = "SOC2, PCI-DSS, HIPAA"
        }
      }
    }
    
    # Stateless rule groups configuration
    stateless_rule_groups = {
      "custom-stateless-rules" = {
        rule_group_name = "ClientBProdCustomStateless"
        rules = [
          {
            priority = 1
            rule_definition = {
              match_attributes = {
                protocols = [6]  # TCP
                source = {
                  address_definition = "10.2.0.0/16"
                }
                destination = {
                  address_definition = "0.0.0.0/0"
                }
                source_ports = [
                  {
                    from_port = 80
                    to_port = 80
                  },
                  {
                    from_port = 443
                    to_port = 443
                  },
                  {
                    from_port = 53
                    to_port = 53
                  }
                ]
              }
              actions = ["aws:forward_to_sfe"]
            }
          },
          {
            priority = 2
            rule_definition = {
              match_attributes = {
                protocols = [17]  # UDP
                source = {
                  address_definition = "10.2.0.0/16"
                }
                destination = {
                  address_definition = "0.0.0.0/0"
                }
                source_ports = [
                  {
                    from_port = 53
                    to_port = 53
                  }
                ]
              }
              actions = ["aws:forward_to_sfe"]
            }
          }
        ]
        tags = {
          Environment = "Production"
          Purpose     = "Custom Stateless Rules"
          Owner       = "Security Team"
          Compliance  = "SOC2"
        }
      }
    }
    
    # CloudWatch Logs configuration
    cloudwatch_logs = {
      enabled = true
      log_groups = {
        "network-firewall-alerts-prod" = {
          name = "/aws/network-firewall/prod/alerts"
          retention_in_days = 90
          kms_key_id = dependency.kms.outputs.kms_key_arn
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall Alerts"
            Owner       = "Security Team"
            Compliance  = "SOC2, PCI-DSS"
            DataRetention = "90 days"
          }
        }
        
        "network-firewall-flows-prod" = {
          name = "/aws/network-firewall/prod/flows"
          retention_in_days = 90
          kms_key_id = dependency.kms.outputs.kms_key_arn
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall Flows"
            Owner       = "Security Team"
            Compliance  = "SOC2, PCI-DSS"
            DataRetention = "90 days"
          }
        }
        
        "network-firewall-tls-prod" = {
          name = "/aws/network-firewall/prod/tls"
          retention_in_days = 90
          kms_key_id = dependency.kms.outputs.kms_key_arn
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall TLS"
            Owner       = "Security Team"
            Compliance  = "SOC2, PCI-DSS"
            DataRetention = "90 days"
          }
        }
      }
    }
    
    # CloudWatch Alarms configuration
    cloudwatch_alarms = {
      enabled = true
      alarms = {
        "network-firewall-alerts-prod" = {
          alarm_name = "NetworkFirewallAlertsProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "AlertCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 5
          alarm_description = "High number of network firewall alerts in production"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"]
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall Monitoring"
            Owner       = "Security Team"
            Criticality = "High"
          }
        }
        
        "network-firewall-dropped-packets-prod" = {
          alarm_name = "NetworkFirewallDroppedPacketsProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "DropCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 50
          alarm_description = "High number of dropped packets by network firewall in production"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"]
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall Monitoring"
            Owner       = "Security Team"
            Criticality = "High"
          }
        }
        
        "network-firewall-threat-detection-prod" = {
          alarm_name = "NetworkFirewallThreatDetectionProd"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "ThreatCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 1
          alarm_description = "Threat detected by network firewall in production"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod", "arn:aws:sns:eu-west-1:987654321098:client-b-emergency-prod"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-prod"]
          tags = {
            Environment = "Production"
            Purpose     = "Network Firewall Threat Detection"
            Owner       = "Security Team"
            Criticality = "Critical"
          }
        }
      }
    }
    
    # IAM roles and policies
    iam_config = {
      firewall_role_name = "ClientBProdNetworkFirewallRole"
      logging_role_name = "ClientBProdNetworkFirewallLoggingRole"
      
      # Firewall role policies
      firewall_role_policies = [
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallServiceRolePolicy"
      ]
      
      # Logging role policies
      logging_role_policies = [
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallLoggingRolePolicy"
      ]
      
      tags = {
        Environment = "Production"
        Purpose     = "Network Firewall IAM"
        Owner       = "Security Team"
        Compliance  = "SOC2"
      }
    }
    
    # Route table configuration
    route_tables = {
      "firewall-route-table" = {
        route_table_name = "ClientBProdFirewallRouteTable"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        routes = [
          {
            destination_cidr_block = "0.0.0.0/0"
            gateway_id = dependency.vpc.outputs.nat_gateway_ids[0]
            target_type = "nat_gateway"
          }
        ]
        
        tags = {
          Environment = "Production"
          Purpose     = "Firewall Route Table"
          Owner       = "Security Team"
          Compliance  = "SOC2"
        }
      }
    }
    
    # Security groups configuration
    security_groups = {
      "firewall-security-group" = {
        name = "ClientBProdFirewallSecurityGroup"
        description = "Security group for Network Firewall in production environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        ingress_rules = [
          {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            description = "Allow HTTP from VPC"
          },
          {
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            description = "Allow HTTPS from VPC"
          },
          {
            from_port = 53
            to_port = 53
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            description = "Allow DNS TCP from VPC"
          },
          {
            from_port = 53
            to_port = 53
            protocol = "udp"
            cidr_blocks = ["10.2.0.0/16"]
            description = "Allow DNS UDP from VPC"
          }
        ]
        
        egress_rules = [
          {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow all outbound traffic"
          }
        ]
        
        tags = {
          Environment = "Production"
          Purpose     = "Firewall Security Group"
          Owner       = "Security Team"
          Compliance  = "SOC2, PCI-DSS"
        }
      }
    }
  }
  
  # Tags for resource management
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Project     = "Network Firewall"
    CostCenter  = "ClientB"
    Owner       = "Security Team"
    ManagedBy   = "Terragrunt"
    Version     = "v1.0.0"
    Purpose     = "Production Network Firewall"
    DataClassification = "Confidential"
    Compliance  = "SOC2, PCI-DSS, HIPAA"
    ProductionEnvironment = "Yes"
    BusinessImpact = "High"
    SecurityLevel = "High"
    Criticality = "High"
    BackupRequired = "Yes"
    DisasterRecovery = "Required"
    ChangeManagement = "Required"
    MaintenanceWindow = "Required"
  }
  
  # Production specific overrides
  production_overrides = {
    # Network firewall configuration for production (comprehensive security)
    enable_comprehensive_firewall = true
    enable_intrusion_prevention = true
    enable_intrusion_detection = true
    enable_ssl_inspection = true
    enable_threat_intelligence = true
    
    # Firewall policy settings for production
    firewall_policy_settings = {
      stateless_default_actions = ["aws:forward_to_sfe"]
      stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      stateful_default_actions = ["aws:drop_strict"]
      
      # Rule priorities for production
      rule_priorities = {
        domain_list_priority = 1
        suricata_rules_priority = 2
        threat_intelligence_priority = 3
        custom_rules_priority = 4
      }
    }
    
    # Logging configuration for production
    logging_config = {
      enable_alert_logging = true
      enable_flow_logging = true
      enable_ssl_logging = true
      
      # Log retention for production
      log_retention = {
        alert_logs_days = 90
        flow_logs_days = 90
        ssl_logs_days = 90
      }
      
      # Log destinations for production
      log_destinations = {
        cloudwatch_logs = true
        s3_bucket = true
        kinesis_firehose = true
      }
    }
    
    # Monitoring and alerting for production
    monitoring_config = {
      enable_cloudwatch_alarms = true
      enable_cloudwatch_dashboards = true
      enable_sns_notifications = true
      
      # Alert thresholds for production (strict)
      alert_thresholds = {
        alert_count_threshold = 5
        dropped_packets_threshold = 50
        blocked_connections_threshold = 10
        threat_detection_threshold = 1
      }
      
      # Notification channels for production
      notification_channels = {
        email = ["security@client-b.com", "ops@client-b.com", "management@client-b.com"]
        slack = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
        pagerduty = "https://events.pagerduty.com/v2/enqueue/service/XXXXXXXXXXXXX"
        sms = ["+1234567890", "+0987654321"]
      }
    }
    
    # Performance configuration for production
    performance_config = {
      firewall_capacity = "CAPACITY_1000"
      enable_auto_scaling = true
      enable_load_balancing = true
      
      # Performance thresholds for production
      performance_thresholds = {
        max_connections = 50000
        max_throughput = 10000  # Mbps
        max_packets_per_second = 100000
      }
    }
    
    # Security configuration for production
    security_config = {
      enable_domain_filtering = true
      enable_url_filtering = true
      enable_file_filtering = true
      enable_ssl_inspection = true
      
      # Security settings for production
      security_settings = {
        domain_list_update_frequency = "hourly"
        threat_intelligence_update_frequency = "hourly"
        rule_update_frequency = "daily"
        enable_automatic_updates = true
      }
    }
    
    # Compliance configuration for production
    compliance_config = {
      enable_audit_logging = true
      enable_compliance_reporting = true
      enable_data_classification = true
      
      # Compliance settings for production
      compliance_settings = {
        enable_gdpr_compliance = true
        enable_soc2_compliance = true
        enable_pci_dss_compliance = true
        enable_hipaa_compliance = true
      }
    }
    
    # Testing and validation for production
    testing_config = {
      enable_penetration_testing = true
      enable_vulnerability_scanning = true
      enable_security_assessment = true
      
      # Testing settings for production
      testing_settings = {
        penetration_test_interval = "quarterly"
        vulnerability_scan_interval = "weekly"
        security_assessment_interval = "monthly"
        enable_automated_testing = true
      }
    }
    
    # Disaster recovery configuration for production
    disaster_recovery_config = {
      enable_backup = true
      enable_replication = true
      enable_failover = true
      
      # Disaster recovery settings
      disaster_recovery_settings = {
        backup_frequency = "daily"
        backup_retention = "365 days"
        replication_frequency = "real-time"
        failover_automation = true
        recovery_time_objective = "4 hours"
        recovery_point_objective = "1 hour"
      }
    }
    
    # High availability configuration for production
    high_availability_config = {
      enable_multi_az = true
      enable_load_balancing = true
      enable_auto_scaling = true
      
      # High availability settings
      high_availability_settings = {
        min_capacity = 2
        max_capacity = 10
        desired_capacity = 3
        health_check_grace_period = 300
        health_check_type = "ELB"
        cooldown_period = 300
      }
    }
    
    # Security monitoring configuration for production
    security_monitoring_config = {
      enable_real_time_monitoring = true
      enable_threat_detection = true
      enable_anomaly_detection = true
      
      # Security monitoring settings
      security_monitoring_settings = {
        monitoring_frequency = "real-time"
        threat_detection_sensitivity = "high"
        anomaly_detection_threshold = "low"
        alert_response_time = "5 minutes"
        incident_response_time = "15 minutes"
      }
    }
    
    # Change management configuration for production
    change_management_config = {
      enable_change_approval = true
      enable_rollback_protection = true
      enable_maintenance_windows = true
      
      # Change management settings
      change_management_settings = {
        change_approval_required = true
        rollback_automation = true
        maintenance_window_duration = "4 hours"
        maintenance_window_frequency = "monthly"
        emergency_change_procedure = true
      }
    }
  }
} 