include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  vpc_config   = local.account_vars.locals.vpc_config
  
  # Input validation for VPC module
  validate_vpc_name = length(local.account_vars.locals.environment) > 0 ? null : file("ERROR: Environment name cannot be empty")
  validate_vpc_cidr = can(cidrhost(local.vpc_config.cidr_block, 0)) ? null : file("ERROR: VPC CIDR block must be valid")
  validate_az_count = length(local.vpc_config.availability_zones) >= 2 ? null : file("ERROR: At least 2 availability zones required")
  validate_subnet_count = length(local.vpc_config.public_subnets) == length(local.vpc_config.availability_zones) ? null : file("ERROR: Public subnet count must match AZ count")
  validate_private_subnet_count = length(local.vpc_config.private_subnets) == length(local.vpc_config.availability_zones) ? null : file("ERROR: Private subnet count must match AZ count")
  validate_db_subnet_count = length(local.vpc_config.database_subnets) == length(local.vpc_config.availability_zones) ? null : file("ERROR: Database subnet count must match AZ count")
  
  # Validate subnet CIDR ranges
  validate_public_subnets = alltrue([
    for subnet in local.vpc_config.public_subnets : can(cidrhost(subnet, 0))
  ]) ? null : file("ERROR: All public subnet CIDR blocks must be valid")
  
  validate_private_subnets = alltrue([
    for subnet in local.vpc_config.private_subnets : can(cidrhost(subnet, 0))
  ]) ? null : file("ERROR: All private subnet CIDR blocks must be valid")
  
  validate_db_subnets = alltrue([
    for subnet in local.vpc_config.database_subnets : can(cidrhost(subnet, 0))
  ]) ? null : file("ERROR: All database subnet CIDR blocks must be valid")
  
  # Validate subnet overlaps
  validate_no_subnet_overlap = (
    length(setintersection(
      local.vpc_config.public_subnets,
      local.vpc_config.private_subnets,
      local.vpc_config.database_subnets
    )) == 0
  ) ? null : file("ERROR: Subnet CIDR blocks must not overlap")
}

terraform {
  source = "tfr://terraform-aws-modules/vpc/aws//?version=5.8.1"
}

inputs = {
  name = "cyprus-vpc"
  
  cidr = local.vpc_config.cidr_block
  azs  = local.vpc_config.availability_zones
  
  public_subnets  = local.vpc_config.public_subnets
  private_subnets = local.vpc_config.private_subnets
  
  database_subnets = local.vpc_config.database_subnets
  
  # NAT Gateway configuration
  enable_nat_gateway = local.vpc_config.enable_nat_gateway
  single_nat_gateway = local.vpc_config.single_nat_gateway
  
  # VPN Gateway configuration
  enable_vpn_gateway = local.vpc_config.enable_vpn_gateway
  
  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
  
  # Tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  
  database_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "network-infrastructure"
  }
} 