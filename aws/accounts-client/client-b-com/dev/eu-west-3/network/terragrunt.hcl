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
      firewall_policy_arn = "arn:aws:network-firewall:eu-west-3:987654321098:firewall-policy/client-b-dev-firewall-policy"
      
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
            resource_arn = "arn:aws:network-firewall:eu-west-3:987654321098:stateful-rulegroup/client-b-dev-domain-list"
            priority = 1
          },
          {
            resource_arn = "arn:aws:network-firewall:eu-west-3:987654321098:stateful-rulegroup/client-b-dev-suricata-rules"
            priority = 2
          }
        ]
        stateless_rule_group_references = [
          {
            resource_arn = "arn:aws:network-firewall:eu-west-3:987654321098:stateless-rulegroup/client-b-dev-custom-rules"
            priority = 1
          }
        ]
      }
      
      # Logging configuration
      logging_configuration = {
        log_destination_configs = [
          {
            log_type = "FLOW"
            log_destination_type = "S3"
            log_destination = {
              bucket_name = "client-b-dev-network-firewall-logs"
              prefix = "network-firewall/flow-logs/"
            }
          },
          {
            log_type = "ALERT"
            log_destination_type = "S3"
            log_destination = {
              bucket_name = "client-b-dev-network-firewall-logs"
              prefix = "network-firewall/alert-logs/"
            }
          }
        ]
      }
      
      # Tags
      tags = {
        Environment = "development"
        Project     = "Network Firewall"
        Client      = "ClientB"
        ManagedBy   = "Terraform"
      }
    }
    
    # Monitoring and alerting configuration
    monitoring = {
      enabled = true
      
      # CloudWatch alarms
      alarms = {
        network_firewall_alerts = {
          enabled = true
          alarm_name = "NetworkFirewallAlertsDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "AlertCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 10
          alarm_description = "Network Firewall alert count exceeded threshold"
        }
        
        dropped_packets = {
          enabled = true
          alarm_name = "NetworkFirewallDroppedPacketsDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 2
          metric_name = "DroppedPackets"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 100
          alarm_description = "Network Firewall dropped packets exceeded threshold"
        }
        
        threat_detection = {
          enabled = true
          alarm_name = "NetworkFirewallThreatDetectionDev"
          comparison_operator = "GreaterThanThreshold"
          evaluation_periods = 1
          metric_name = "ThreatCount"
          namespace = "AWS/NetworkFirewall"
          period = 300
          statistic = "Sum"
          threshold = 1
          alarm_description = "Network Firewall threat detected"
        }
      }
    }
    
    # IAM configuration
    iam = {
      enabled = true
      
      # IAM roles
      roles = {
        firewall_role_name = "ClientBDevNetworkFirewallRole"
        logging_role_name = "ClientBDevNetworkFirewallLoggingRole"
      }
      
      # IAM policies
      policies = [
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallServiceRolePolicy",
        "arn:aws:iam::aws:policy/service-role/AWSNetworkFirewallLoggingRolePolicy"
      ]
    }
    
    # KMS configuration for encryption
    kms = {
      enabled = true
      key_alias = "alias/client-b-dev-network-firewall"
      key_description = "KMS key for Client B Development Network Firewall encryption"
    }
  }
} 