module "vpc" {
  source = "github.com/catherinevee/vpc"
  version = "1.0.0"  # Version pinning for the module
  
  for_each = var.vpcs
  
  # VPC Configuration
  vpc_name = each.value.vpc_name
  cidr_block = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support = each.value.enable_dns_support
  enable_classiclink = each.value.enable_classiclink
  enable_classiclink_dns_support = each.value.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = each.value.assign_generated_ipv6_cidr_block
  instance_tenancy = each.value.instance_tenancy
  
  # Subnet Configuration
  availability_zones = each.value.availability_zones
  public_subnets = each.value.public_subnets
  private_subnets = each.value.private_subnets
  database_subnets = each.value.database_subnets
  elasticache_subnets = each.value.elasticache_subnets
  redshift_subnets = each.value.redshift_subnets
  intra_subnets = each.value.intra_subnets
  
  # NAT Gateway Configuration
  enable_nat_gateway = each.value.enable_nat_gateway
  single_nat_gateway = each.value.single_nat_gateway
  one_nat_gateway_per_az = each.value.one_nat_gateway_per_az
  reuse_nat_ips = each.value.reuse_nat_ips
  external_nat_ip_ids = each.value.external_nat_ip_ids
  external_nat_ips = each.value.external_nat_ips
  
  # Internet Gateway Configuration
  enable_internet_gateway = each.value.enable_internet_gateway
  
  # VPN Gateway Configuration
  enable_vpn_gateway = each.value.enable_vpn_gateway
  enable_vpn_gateway_route_propagation = each.value.enable_vpn_gateway_route_propagation
  
  # VPC Endpoints Configuration
  enable_s3_endpoint = each.value.enable_s3_endpoint
  enable_dynamodb_endpoint = each.value.enable_dynamodb_endpoint
  enable_ssm_endpoint = each.value.enable_ssm_endpoint
  enable_ssmmessages_endpoint = each.value.enable_ssmmessages_endpoint
  enable_ec2_endpoint = each.value.enable_ec2_endpoint
  enable_ec2messages_endpoint = each.value.enable_ec2messages_endpoint
  enable_ecr_api_endpoint = each.value.enable_ecr_api_endpoint
  enable_ecr_dkr_endpoint = each.value.enable_ecr_dkr_endpoint
  enable_ecs_endpoint = each.value.enable_ecs_endpoint
  enable_ecs_agent_endpoint = each.value.enable_ecs_agent_endpoint
  enable_ecs_telemetry_endpoint = each.value.enable_ecs_telemetry_endpoint
  enable_sqs_endpoint = each.value.enable_sqs_endpoint
  enable_sns_endpoint = each.value.enable_sns_endpoint
  enable_logs_endpoint = each.value.enable_logs_endpoint
  enable_monitoring_endpoint = each.value.enable_monitoring_endpoint
  enable_events_endpoint = each.value.enable_events_endpoint
  enable_elasticloadbalancing_endpoint = each.value.enable_elasticloadbalancing_endpoint
  enable_access_analyzer_endpoint = each.value.enable_access_analyzer_endpoint
  
  # Route Tables Configuration
  manage_default_route_table = each.value.manage_default_route_table
  default_route_table_name = each.value.default_route_table_name
  default_route_table_tags = each.value.default_route_table_tags
  
  # DHCP Options Configuration
  enable_dhcp_options = each.value.enable_dhcp_options
  dhcp_options_domain_name = each.value.dhcp_options_domain_name
  dhcp_options_domain_name_servers = each.value.dhcp_options_domain_name_servers
  dhcp_options_ntp_servers = each.value.dhcp_options_ntp_servers
  dhcp_options_netbios_name_servers = each.value.dhcp_options_netbios_name_servers
  dhcp_options_netbios_node_type = each.value.dhcp_options_netbios_node_type
  
  # Flow Log Configuration
  enable_flow_log = each.value.enable_flow_log
  flow_log_traffic_type = each.value.flow_log_traffic_type
  flow_log_destination_type = each.value.flow_log_destination_type
  flow_log_log_destination = each.value.flow_log_log_destination
  flow_log_destination_arn = each.value.flow_log_destination_arn
  flow_log_iam_role_arn = each.value.flow_log_iam_role_arn
  
  # Network ACL Configuration
  manage_default_network_acl = each.value.manage_default_network_acl
  default_network_acl_name = each.value.default_network_acl_name
  default_network_acl_tags = each.value.default_network_acl_tags
  
  # Security Groups Configuration
  manage_default_security_group = each.value.manage_default_security_group
  default_security_group_name = each.value.default_security_group_name
  default_security_group_ingress = each.value.default_security_group_ingress
  default_security_group_egress = each.value.default_security_group_egress
  default_security_group_tags = each.value.default_security_group_tags
  
  # Tags
  tags = merge(
    {
      Name = each.value.vpc_name
      Environment = var.environment
      Region = var.region
      CostCenter = var.costcenter
      Project = var.project
      Terraform = true
    },
    each.value.tags
  )
  
  # Subnet Tags
  public_subnet_tags = merge(
    {
      Tier = "public"
      Environment = var.environment
    },
    each.value.public_subnet_tags
  )
  
  private_subnet_tags = merge(
    {
      Tier = "private"
      Environment = var.environment
    },
    each.value.private_subnet_tags
  )
  
  database_subnet_tags = merge(
    {
      Tier = "database"
      Environment = var.environment
    },
    each.value.database_subnet_tags
  )
  
  elasticache_subnet_tags = merge(
    {
      Tier = "elasticache"
      Environment = var.environment
    },
    each.value.elasticache_subnet_tags
  )
  
  redshift_subnet_tags = merge(
    {
      Tier = "redshift"
      Environment = var.environment
    },
    each.value.redshift_subnet_tags
  )
  
  intra_subnet_tags = merge(
    {
      Tier = "intra"
      Environment = var.environment
    },
    each.value.intra_subnet_tags
  )
} 