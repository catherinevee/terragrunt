include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  vpc_config   = local.account_vars.locals.vpc_config
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
  }
} 