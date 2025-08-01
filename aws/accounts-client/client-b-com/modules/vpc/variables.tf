variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "costcenter" {
  description = "Cost center for resource tagging"
  type        = string
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    # VPC Configuration
    vpc_name = string
    cidr_block = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support = optional(bool, true)
    enable_classiclink = optional(bool, false)
    enable_classiclink_dns_support = optional(bool, false)
    assign_generated_ipv6_cidr_block = optional(bool, false)
    instance_tenancy = optional(string, "default")
    
    # Subnet Configuration
    availability_zones = list(string)
    public_subnets = optional(list(string), [])
    private_subnets = optional(list(string), [])
    database_subnets = optional(list(string), [])
    elasticache_subnets = optional(list(string), [])
    redshift_subnets = optional(list(string), [])
    intra_subnets = optional(list(string), [])
    
    # NAT Gateway Configuration
    enable_nat_gateway = optional(bool, true)
    single_nat_gateway = optional(bool, false)
    one_nat_gateway_per_az = optional(bool, true)
    reuse_nat_ips = optional(bool, false)
    external_nat_ip_ids = optional(list(string), [])
    external_nat_ips = optional(list(string), [])
    
    # Internet Gateway Configuration
    enable_internet_gateway = optional(bool, true)
    
    # VPN Gateway Configuration
    enable_vpn_gateway = optional(bool, false)
    enable_vpn_gateway_route_propagation = optional(bool, false)
    
    # VPC Endpoints Configuration
    enable_s3_endpoint = optional(bool, true)
    enable_dynamodb_endpoint = optional(bool, false)
    enable_ssm_endpoint = optional(bool, false)
    enable_ssmmessages_endpoint = optional(bool, false)
    enable_ec2_endpoint = optional(bool, false)
    enable_ec2messages_endpoint = optional(bool, false)
    enable_ecr_api_endpoint = optional(bool, false)
    enable_ecr_dkr_endpoint = optional(bool, false)
    enable_ecs_endpoint = optional(bool, false)
    enable_ecs_agent_endpoint = optional(bool, false)
    enable_ecs_telemetry_endpoint = optional(bool, false)
    enable_sqs_endpoint = optional(bool, false)
    enable_sns_endpoint = optional(bool, false)
    enable_logs_endpoint = optional(bool, false)
    enable_monitoring_endpoint = optional(bool, false)
    enable_events_endpoint = optional(bool, false)
    enable_elasticloadbalancing_endpoint = optional(bool, false)
    enable_access_analyzer_endpoint = optional(bool, false)
    
    # Route Tables Configuration
    manage_default_route_table = optional(bool, false)
    default_route_table_name = optional(string, null)
    default_route_table_tags = optional(map(string), {})
    
    # DHCP Options Configuration
    enable_dhcp_options = optional(bool, false)
    dhcp_options_domain_name = optional(string, null)
    dhcp_options_domain_name_servers = optional(list(string), [])
    dhcp_options_ntp_servers = optional(list(string), [])
    dhcp_options_netbios_name_servers = optional(list(string), [])
    dhcp_options_netbios_node_type = optional(string, null)
    
    # Flow Log Configuration
    enable_flow_log = optional(bool, false)
    flow_log_traffic_type = optional(string, "ALL")
    flow_log_destination_type = optional(string, "cloud-watch-logs")
    flow_log_log_destination = optional(string, null)
    flow_log_destination_arn = optional(string, null)
    flow_log_iam_role_arn = optional(string, null)
    
    # Network ACL Configuration
    manage_default_network_acl = optional(bool, false)
    default_network_acl_name = optional(string, null)
    default_network_acl_tags = optional(map(string), {})
    
    # Security Groups Configuration
    manage_default_security_group = optional(bool, false)
    default_security_group_name = optional(string, null)
    default_security_group_ingress = optional(list(any), [])
    default_security_group_egress = optional(list(any), [])
    default_security_group_tags = optional(map(string), {})
    
    # Tags
    tags = optional(map(string), {})
    public_subnet_tags = optional(map(string), {})
    private_subnet_tags = optional(map(string), {})
    database_subnet_tags = optional(map(string), {})
    elasticache_subnet_tags = optional(map(string), {})
    redshift_subnet_tags = optional(map(string), {})
    intra_subnet_tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for vpc in values(var.vpcs) : 
      can(cidrhost(vpc.cidr_block, 0)) && 
      can(cidrhost(vpc.cidr_block, 1))
    ])
    error_message = "All VPC CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition = alltrue([
      for vpc in values(var.vpcs) : 
      length(vpc.availability_zones) > 0
    ])
    error_message = "At least one availability zone must be specified for each VPC."
  }
  
  validation {
    condition = alltrue([
      for vpc in values(var.vpcs) : 
      length(vpc.public_subnets) == 0 || length(vpc.public_subnets) == length(vpc.availability_zones)
    ])
    error_message = "Number of public subnets must match the number of availability zones or be empty."
  }
  
  validation {
    condition = alltrue([
      for vpc in values(var.vpcs) : 
      length(vpc.private_subnets) == 0 || length(vpc.private_subnets) == length(vpc.availability_zones)
    ])
    error_message = "Number of private subnets must match the number of availability zones or be empty."
  }
} 