# ==============================================================================
# Network Firewall Module Configuration for Client B - Development Environment
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
  project     = "Network Firewall - Development"
  
  # Network firewall specific configuration for development environment
  network_firewall_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Network Firewall"
    
    # Network Firewall configuration
    network_firewall = {
      enabled = true
      firewall_name = "ClientBDevNetworkFirewall"
      firewall_policy_arn = "arn:aws:network-firewall:eu-west-1:987654321098:firewall-policy/client-b-dev-firewall-policy"
      
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
      }
      
      # Firewall policy configuration
      firewall_policy = {
        stateless_default_actions = ["aws:forward_to_sfe"]
        stateless_fragment_default_actions = ["aws:forward_to_sfe"]
        stateful_rule_group_references = [
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateful-rulegroup/client-b-dev-domain-list"
            priority = 1
          },
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateful-rulegroup/client-b-dev-suricata-rules"
            priority = 2
          }
        ]
        stateless_rule_group_references = [
          {
            resource_arn = "arn:aws:network-firewall:eu-west-1:987654321098:stateless-rulegroup/client-b-dev-custom-rules"
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
              log_group = "/aws/network-firewall/dev/alerts"
            }
          },
          {
            log_type = "FLOW"
            log_destination_type = "CloudWatchLogs"
            log_destination = {
              log_group = "/aws/network-firewall/dev/flows"
            }
          }
        ]
      }
      
      tags = {
        Environment = "Development"
        Purpose     = "Network Firewall"
        Owner       = "Security Team"
        Compliance  = "Basic"
        DataClassification = "Internal"
      }
    }
    
    # Stateful rule groups configuration
    stateful_rule_groups = {
      "domain-list-rule-group" = {
        rule_group_name = "ClientBDevDomainList"
        rule_group_type = "DOMAIN_LIST"
        rules_string = <<EOF
# Allow trusted domains for development
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow trusted domains"; sid:1001; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow AWS services"; sid:1002; rev:1;)
PASS $HOME_NET any -> $EXTERNAL_NET any (msg:"Allow development tools"; sid:1003; rev:1;)
EOF
        tags = {
          Environment = "Development"
          Purpose     = "Domain List Rules"
          Owner       = "Security Team"
        }
      }
      
      "suricata-rule-group" = {
        rule_group_name = "ClientBDevSuricataRules"
        rule_group_type = "STATEFUL"
        rules_string = <<EOF
# Basic security rules for development (lenient)
alert tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Suspicious outbound connection"; sid:2001; rev:1;)
alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Suspicious inbound connection"; sid:2002; rev:1;)
# Allow development traffic
PASS tcp $HOME_NET any -> $EXTERNAL_NET 22 (msg:"Allow SSH for development"; sid:2003; rev:1;)
PASS tcp $HOME_NET any -> $EXTERNAL_NET 80 (msg:"Allow HTTP for development"; sid:2004; rev:1;)
PASS tcp $HOME_NET any -> $EXTERNAL_NET 443 (msg:"Allow HTTPS for development"; sid:2005; rev:1;)
EOF
        tags = {
          Environment = "Development"
          Purpose     = "Suricata Rules"
          Owner       = "Security Team"
        }
      }
    }
    
    # Stateless rule groups configuration
    stateless_rule_groups = {
      "custom-stateless-rules" = {
        rule_group_name = "ClientBDevCustomStateless"
        rules = [
          {
            priority = 1
            rule_definition = {
              match_attributes = {
                protocols = [6]  # TCP
                source = {
                  address_definition = "10.1.0.0/16"
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
                    from_port = 22
                    to_port = 22
                  },
                  {
                    from_port = 8080
                    to_port = 8080
                  }
                ]
              }
              actions = ["aws:forward_to_sfe"]
            }
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Custom Stateless Rules"
          Owner       = "Security Team"
        }
      }
    }
    
    # CloudWatch Logs configuration
    cloudwatch_logs = {
      enabled = true
      log_groups = {
        "network-firewall-alerts-dev" = {
          name = "/aws/network-firewall/dev/alerts"
          retention_in_days = 7
          kms_key_id = null
          tags = {
            Environment = "Development"
            Purpose     = "Network Firewall Alerts"
            Owner       = "Security Team"
          }
        }
        
        "network-firewall-flows-dev" = {
          name = "/aws/network-firewall/dev/flows"
          retention_in_days = 7
          kms_key_id = null
          tags = {
            Environment = "Development"
            Purpose     = "Network Firewall Flows"
            Owner       = "Security Team"
          }
        }
      }
    }
    
    # CloudWatch Alarms configuration
    cloudwatch_alarms = {
      enabled = true
      alarms = {
        "network-firewall-alerts-dev" = {
          alarm_name = "NetworkFirewallAlertsDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "AlertCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 50
          alarm_description = "High number of network firewall alerts in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-dev"]
          tags = {
            Environment = "Development"
            Purpose     = "Network Firewall Monitoring"
            Owner       = "Security Team"
          }
        }
        
        "network-firewall-dropped-packets-dev" = {
          alarm_name = "NetworkFirewallDroppedPacketsDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "DropCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 500
          alarm_description = "High number of dropped packets by network firewall in development"
          alarm_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-dev"]
          ok_actions = ["arn:aws:sns:eu-west-1:987654321098:client-b-security-dev"]
          tags = {
            Environment = "Development"
            Purpose     = "Network Firewall Monitoring"
            Owner       = "Security Team"
          }
        }
      }
    }
    
    # IAM roles and policies
    iam_config = {
      firewall_role_name = "ClientBDevNetworkFirewallRole"
      logging_role_name = "ClientBDevNetworkFirewallLoggingRole"
      
      # Firewall role policies
      firewall_role_policies = [
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallServiceRolePolicy"
      ]
      
      # Logging role policies
      logging_role_policies = [
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallLoggingRolePolicy"
      ]
      
      tags = {
        Environment = "Development"
        Purpose     = "Network Firewall IAM"
        Owner       = "Security Team"
      }
    }
    
    # Route table configuration
    route_tables = {
      "firewall-route-table" = {
        route_table_name = "ClientBDevFirewallRouteTable"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        routes = [
          {
            destination_cidr_block = "0.0.0.0/0"
            gateway_id = dependency.vpc.outputs.nat_gateway_ids[0]
            target_type = "nat_gateway"
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "Firewall Route Table"
          Owner       = "Security Team"
        }
      }
    }
    
    # Security groups configuration
    security_groups = {
      "firewall-security-group" = {
        name = "ClientBDevFirewallSecurityGroup"
        description = "Security group for Network Firewall in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        ingress_rules = [
          {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["10.1.0.0/16"]
            description = "Allow HTTP from VPC"
          },
          {
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["10.1.0.0/16"]
            description = "Allow HTTPS from VPC"
          },
          {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.1.0.0/16"]
            description = "Allow SSH from VPC"
          },
          {
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            cidr_blocks = ["10.1.0.0/16"]
            description = "Allow development ports from VPC"
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
          Environment = "Development"
          Purpose     = "Firewall Security Group"
          Owner       = "Security Team"
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
    Purpose     = "Development Network Firewall"
    DataClassification = "Internal"
    Compliance  = "Basic"
    DevelopmentEnvironment = "Yes"
    BusinessImpact = "Low"
    SecurityLevel = "Low"
  }
  
  # Development specific overrides
  dev_overrides = {
    # Network firewall configuration for development (basic security)
    enable_comprehensive_firewall = false
    enable_intrusion_prevention = false
    enable_intrusion_detection = true
    enable_ssl_inspection = false
    enable_threat_intelligence = false
    
    # Firewall policy settings for development
    firewall_policy_settings = {
      stateless_default_actions = ["aws:forward_to_sfe"]
      stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      stateful_default_actions = ["aws:alert_strict"]
      
      # Rule priorities for development
      rule_priorities = {
        domain_list_priority = 1
        suricata_rules_priority = 2
        custom_rules_priority = 3
      }
    }
    
    # Logging configuration for development
    logging_config = {
      enable_alert_logging = true
      enable_flow_logging = false
      enable_ssl_logging = false
      
      # Log retention for development
      log_retention = {
        alert_logs_days = 7
        flow_logs_days = 0
        ssl_logs_days = 0
      }
      
      # Log destinations for development
      log_destinations = {
        cloudwatch_logs = true
        s3_bucket = false
        kinesis_firehose = false
      }
    }
    
    # Monitoring and alerting for development
    monitoring_config = {
      enable_cloudwatch_alarms = true
      enable_cloudwatch_dashboards = false
      enable_sns_notifications = true
      
      # Alert thresholds for development (lenient)
      alert_thresholds = {
        alert_count_threshold = 50
        dropped_packets_threshold = 500
        blocked_connections_threshold = 200
      }
      
      # Notification channels for development
      notification_channels = {
        email = ["devops@client-b.com"]
        slack = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
        pagerduty = null
      }
    }
    
    # Performance configuration for development
    performance_config = {
      firewall_capacity = "CAPACITY_100"
      enable_auto_scaling = false
      enable_load_balancing = false
      
      # Performance thresholds for development
      performance_thresholds = {
        max_connections = 5000
        max_throughput = 500  # Mbps
        max_packets_per_second = 5000
      }
    }
    
    # Security configuration for development
    security_config = {
      enable_domain_filtering = false
      enable_url_filtering = false
      enable_file_filtering = false
      enable_ssl_inspection = false
      
      # Security settings for development
      security_settings = {
        domain_list_update_frequency = "weekly"
        threat_intelligence_update_frequency = "weekly"
        rule_update_frequency = "monthly"
        enable_automatic_updates = false
      }
    }
    
    # Compliance configuration for development
    compliance_config = {
      enable_audit_logging = false
      enable_compliance_reporting = false
      enable_data_classification = false
      
      # Compliance settings for development
      compliance_settings = {
        enable_gdpr_compliance = false
        enable_soc2_compliance = false
        enable_pci_dss_compliance = false
        enable_hipaa_compliance = false
      }
    }
    
    # Testing and validation for development
    testing_config = {
      enable_penetration_testing = false
      enable_vulnerability_scanning = false
      enable_security_assessment = false
      
      # Testing settings for development
      testing_settings = {
        penetration_test_interval = "never"
        vulnerability_scan_interval = "never"
        security_assessment_interval = "never"
        enable_automated_testing = false
      }
    }
    
    # Development environment variables
    environment_variables = {
      NODE_ENV = "development"
      DEBUG = "true"
      LOG_LEVEL = "debug"
      ENABLE_NETWORK_DEBUGGING = "true"
      ENABLE_PERFORMANCE_MONITORING = "false"
      ENABLE_SECURITY_MONITORING = "true"
      NETWORK_ALERT_ENABLED = "true"
      COMPLIANCE_MODE = "basic"
      SECURITY_MODE = "low"
    }
    
    # Development debugging features
    debugging_features = {
      enable_network_debugging = true
      enable_performance_debugging = false
      enable_security_debugging = true
      
      # Debugging configuration
      debugging_config = {
        enable_detailed_logging = true
        enable_metric_debugging = false
        enable_alert_debugging = true
        enable_flow_log_debugging = false
        
        # Debug settings for development
        debug_settings = {
          log_level = "debug"
          enable_trace_logging = true
          enable_performance_tracing = false
          enable_network_tracing = true
        }
      }
    }
  }
} 