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
  source = "../../../../modules/vpc"
}

# Dependencies (uncomment and configure as needed)
# dependency "kms" {
#   config_path = "../kms"
# }
# 
# dependency "iam" {
#   config_path = "../iam"
# }

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  costcenter  = "ClientB"
  project     = "Production Network Infrastructure"
  
  vpcs = {
    "client-b-prod-main-vpc" = {
      vpc_name = "client-b-prod-main-vpc"
      cidr_block = "10.2.0.0/16"
      
      # VPC Configuration
      enable_dns_hostnames = true
      enable_dns_support = true
      enable_classiclink = false
      enable_classiclink_dns_support = false
      assign_generated_ipv6_cidr_block = false
      instance_tenancy = "default"
      
      # Availability Zones and Subnets
      availability_zones = include.region.locals.region_config.azs
      public_subnets = include.region.locals.region_config.public_subnets
      private_subnets = include.region.locals.region_config.private_subnets
      database_subnets = include.region.locals.region_config.database_subnets
      elasticache_subnets = ["10.2.40.0/24", "10.2.41.0/24", "10.2.42.0/24"]
      redshift_subnets = ["10.2.50.0/24", "10.2.51.0/24", "10.2.52.0/24"]
      intra_subnets = ["10.2.60.0/24", "10.2.61.0/24", "10.2.62.0/24"]
      
      # NAT Gateway Configuration
      enable_nat_gateway = true
      single_nat_gateway = false
      one_nat_gateway_per_az = true
      reuse_nat_ips = false
      external_nat_ip_ids = []
      external_nat_ips = []
      
      # Internet Gateway Configuration
      enable_internet_gateway = true
      
      # VPN Gateway Configuration
      enable_vpn_gateway = true
      enable_vpn_gateway_route_propagation = true
      
      # VPC Endpoints Configuration
      enable_s3_endpoint = true
      enable_dynamodb_endpoint = true
      enable_ssm_endpoint = true
      enable_ssmmessages_endpoint = true
      enable_ec2_endpoint = true
      enable_ec2messages_endpoint = true
      enable_ecr_api_endpoint = true
      enable_ecr_dkr_endpoint = true
      enable_ecs_endpoint = true
      enable_ecs_agent_endpoint = true
      enable_ecs_telemetry_endpoint = true
      enable_sqs_endpoint = true
      enable_sns_endpoint = true
      enable_logs_endpoint = true
      enable_monitoring_endpoint = true
      enable_events_endpoint = true
      enable_elasticloadbalancing_endpoint = true
      enable_access_analyzer_endpoint = true
      
      # Route Tables Configuration
      manage_default_route_table = false
      default_route_table_name = null
      default_route_table_tags = {}
      
      # DHCP Options Configuration
      enable_dhcp_options = false
      dhcp_options_domain_name = null
      dhcp_options_domain_name_servers = []
      dhcp_options_ntp_servers = []
      dhcp_options_netbios_name_servers = []
      dhcp_options_netbios_node_type = null
      
      # Flow Log Configuration
      enable_flow_log = true
      flow_log_traffic_type = "ALL"
      flow_log_destination_type = "cloud-watch-logs"
      flow_log_log_destination = null
      flow_log_destination_arn = null
      flow_log_iam_role_arn = null
      
      # Network ACL Configuration
      manage_default_network_acl = false
      default_network_acl_name = null
      default_network_acl_tags = {}
      
      # Security Groups Configuration
      manage_default_security_group = false
      default_security_group_name = null
      default_security_group_ingress = []
      default_security_group_egress = []
      default_security_group_tags = {}
      
      # Tags
      tags = {
        Purpose = "main-vpc"
        NetworkTier = "main"
        BackupRequired = "true"
        Compliance = "SOX"
      }
      
      public_subnet_tags = {
        Purpose = "public-subnets"
        NetworkTier = "public"
        AutoAssignPublicIp = "true"
        Compliance = "SOX"
      }
      
      private_subnet_tags = {
        Purpose = "private-subnets"
        NetworkTier = "private"
        AutoAssignPublicIp = "false"
        Compliance = "SOX"
      }
      
      database_subnet_tags = {
        Purpose = "database-subnets"
        NetworkTier = "database"
        AutoAssignPublicIp = "false"
        Compliance = "SOX"
      }
      
      elasticache_subnet_tags = {
        Purpose = "elasticache-subnets"
        NetworkTier = "elasticache"
        AutoAssignPublicIp = "false"
        Compliance = "SOX"
      }
      
      redshift_subnet_tags = {
        Purpose = "redshift-subnets"
        NetworkTier = "redshift"
        AutoAssignPublicIp = "false"
        Compliance = "SOX"
      }
      
      intra_subnet_tags = {
        Purpose = "intra-subnets"
        NetworkTier = "intra"
        AutoAssignPublicIp = "false"
        Compliance = "SOX"
      }
    }
    
    "client-b-prod-isolated-vpc" = {
      vpc_name = "client-b-prod-isolated-vpc"
      cidr_block = "10.2.128.0/18"
      
      # VPC Configuration
      enable_dns_hostnames = true
      enable_dns_support = true
      enable_classiclink = false
      enable_classiclink_dns_support = false
      assign_generated_ipv6_cidr_block = false
      instance_tenancy = "default"
      
      # Availability Zones and Subnets (isolated - no public subnets)
      availability_zones = include.region.locals.region_config.azs
      public_subnets = []
      private_subnets = ["10.2.128.0/26", "10.2.128.64/26", "10.2.128.128/26"]
      database_subnets = ["10.2.129.0/26", "10.2.129.64/26", "10.2.129.128/26"]
      elasticache_subnets = ["10.2.130.0/26", "10.2.130.64/26", "10.2.130.128/26"]
      redshift_subnets = []
      intra_subnets = ["10.2.131.0/26", "10.2.131.64/26", "10.2.131.128/26"]
      
      # NAT Gateway Configuration (disabled for isolated VPC)
      enable_nat_gateway = false
      single_nat_gateway = false
      one_nat_gateway_per_az = false
      reuse_nat_ips = false
      external_nat_ip_ids = []
      external_nat_ips = []
      
      # Internet Gateway Configuration (disabled for isolated VPC)
      enable_internet_gateway = false
      
      # VPN Gateway Configuration
      enable_vpn_gateway = false
      enable_vpn_gateway_route_propagation = false
      
      # VPC Endpoints Configuration (minimal for isolated VPC)
      enable_s3_endpoint = true
      enable_dynamodb_endpoint = false
      enable_ssm_endpoint = false
      enable_ssmmessages_endpoint = false
      enable_ec2_endpoint = false
      enable_ec2messages_endpoint = false
      enable_ecr_api_endpoint = false
      enable_ecr_dkr_endpoint = false
      enable_ecs_endpoint = false
      enable_ecs_agent_endpoint = false
      enable_ecs_telemetry_endpoint = false
      enable_sqs_endpoint = false
      enable_sns_endpoint = false
      enable_logs_endpoint = false
      enable_monitoring_endpoint = false
      enable_events_endpoint = false
      enable_elasticloadbalancing_endpoint = false
      enable_access_analyzer_endpoint = false
      
      # Route Tables Configuration
      manage_default_route_table = false
      default_route_table_name = null
      default_route_table_tags = {}
      
      # DHCP Options Configuration
      enable_dhcp_options = false
      dhcp_options_domain_name = null
      dhcp_options_domain_name_servers = []
      dhcp_options_ntp_servers = []
      dhcp_options_netbios_name_servers = []
      dhcp_options_netbios_node_type = null
      
      # Flow Log Configuration
      enable_flow_log = true
      flow_log_traffic_type = "ALL"
      flow_log_destination_type = "cloud-watch-logs"
      flow_log_log_destination = null
      flow_log_destination_arn = null
      flow_log_iam_role_arn = null
      
      # Network ACL Configuration
      manage_default_network_acl = false
      default_network_acl_name = null
      default_network_acl_tags = {}
      
      # Security Groups Configuration
      manage_default_security_group = false
      default_security_group_name = null
      default_security_group_ingress = []
      default_security_group_egress = []
      default_security_group_tags = {}
      
      # Tags
      tags = {
        Purpose = "isolated-vpc"
        NetworkTier = "isolated"
        BackupRequired = "true"
        SecurityLevel = "high"
        Compliance = "SOX"
      }
      
      public_subnet_tags = {}
      
      private_subnet_tags = {
        Purpose = "isolated-private-subnets"
        NetworkTier = "isolated-private"
        AutoAssignPublicIp = "false"
        SecurityLevel = "high"
        Compliance = "SOX"
      }
      
      database_subnet_tags = {
        Purpose = "isolated-database-subnets"
        NetworkTier = "isolated-database"
        AutoAssignPublicIp = "false"
        SecurityLevel = "high"
        Compliance = "SOX"
      }
      
      elasticache_subnet_tags = {
        Purpose = "isolated-elasticache-subnets"
        NetworkTier = "isolated-elasticache"
        AutoAssignPublicIp = "false"
        SecurityLevel = "high"
        Compliance = "SOX"
      }
      
      redshift_subnet_tags = {}
      
      intra_subnet_tags = {
        Purpose = "isolated-intra-subnets"
        NetworkTier = "isolated-intra"
        AutoAssignPublicIp = "false"
        SecurityLevel = "high"
        Compliance = "SOX"
      }
    }
    
    "client-b-prod-dmz-vpc" = {
      vpc_name = "client-b-prod-dmz-vpc"
      cidr_block = "10.2.192.0/20"
      
      # VPC Configuration
      enable_dns_hostnames = true
      enable_dns_support = true
      enable_classiclink = false
      enable_classiclink_dns_support = false
      assign_generated_ipv6_cidr_block = false
      instance_tenancy = "default"
      
      # Availability Zones and Subnets (DMZ - public subnets only)
      availability_zones = include.region.locals.region_config.azs
      public_subnets = ["10.2.192.0/26", "10.2.192.64/26", "10.2.192.128/26"]
      private_subnets = []
      database_subnets = []
      elasticache_subnets = []
      redshift_subnets = []
      intra_subnets = ["10.2.193.0/26", "10.2.193.64/26", "10.2.193.128/26"]
      
      # NAT Gateway Configuration (disabled for DMZ VPC)
      enable_nat_gateway = false
      single_nat_gateway = false
      one_nat_gateway_per_az = false
      reuse_nat_ips = false
      external_nat_ip_ids = []
      external_nat_ips = []
      
      # Internet Gateway Configuration
      enable_internet_gateway = true
      
      # VPN Gateway Configuration
      enable_vpn_gateway = false
      enable_vpn_gateway_route_propagation = false
      
      # VPC Endpoints Configuration (minimal for DMZ VPC)
      enable_s3_endpoint = true
      enable_dynamodb_endpoint = false
      enable_ssm_endpoint = false
      enable_ssmmessages_endpoint = false
      enable_ec2_endpoint = false
      enable_ec2messages_endpoint = false
      enable_ecr_api_endpoint = false
      enable_ecr_dkr_endpoint = false
      enable_ecs_endpoint = false
      enable_ecs_agent_endpoint = false
      enable_ecs_telemetry_endpoint = false
      enable_sqs_endpoint = false
      enable_sns_endpoint = false
      enable_logs_endpoint = false
      enable_monitoring_endpoint = false
      enable_events_endpoint = false
      enable_elasticloadbalancing_endpoint = false
      enable_access_analyzer_endpoint = false
      
      # Route Tables Configuration
      manage_default_route_table = false
      default_route_table_name = null
      default_route_table_tags = {}
      
      # DHCP Options Configuration
      enable_dhcp_options = false
      dhcp_options_domain_name = null
      dhcp_options_domain_name_servers = []
      dhcp_options_ntp_servers = []
      dhcp_options_netbios_name_servers = []
      dhcp_options_netbios_node_type = null
      
      # Flow Log Configuration
      enable_flow_log = true
      flow_log_traffic_type = "ALL"
      flow_log_destination_type = "cloud-watch-logs"
      flow_log_log_destination = null
      flow_log_destination_arn = null
      flow_log_iam_role_arn = null
      
      # Network ACL Configuration
      manage_default_network_acl = false
      default_network_acl_name = null
      default_network_acl_tags = {}
      
      # Security Groups Configuration
      manage_default_security_group = false
      default_security_group_name = null
      default_security_group_ingress = []
      default_security_group_egress = []
      default_security_group_tags = {}
      
      # Tags
      tags = {
        Purpose = "dmz-vpc"
        NetworkTier = "dmz"
        BackupRequired = "true"
        SecurityLevel = "dmz"
        Compliance = "SOX"
      }
      
      public_subnet_tags = {
        Purpose = "dmz-public-subnets"
        NetworkTier = "dmz-public"
        AutoAssignPublicIp = "true"
        SecurityLevel = "dmz"
        Compliance = "SOX"
      }
      
      private_subnet_tags = {}
      
      database_subnet_tags = {}
      
      elasticache_subnet_tags = {}
      
      redshift_subnet_tags = {}
      
      intra_subnet_tags = {
        Purpose = "dmz-intra-subnets"
        NetworkTier = "dmz-intra"
        AutoAssignPublicIp = "false"
        SecurityLevel = "dmz"
        Compliance = "SOX"
      }
    }
  }
} 