# ==============================================================================
# VPC Module Configuration for Client B - Staging Environment (eu-west-2)
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

terraform {
  source = "https://github.com/catherinevee/tfm-aws-vpc//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # VPC Configuration
  vpc_config = {
    cidr_block = include.region.locals.region_config.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    # Subnet configurations
    public_subnets = include.region.locals.region_config.public_subnets
    private_subnets = include.region.locals.region_config.private_subnets
    database_subnets = include.region.locals.region_config.database_subnets
    elasticache_subnets = include.region.locals.region_config.elasticache_subnets
    availability_zones = include.region.locals.region_config.azs
    
    # NAT Gateway configuration (multi-AZ for staging)
    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
    
    # VPC Endpoints for AWS services
    enable_vpc_endpoints = true
    vpc_endpoints = {
      s3 = {
        service = "s3"
        subnet_ids = "private"
      }
      dynamodb = {
        service = "dynamodb"
        subnet_ids = "private"
      }
      ec2 = {
        service = "ec2"
        subnet_ids = "private"
      }
      ec2messages = {
        service = "ec2messages"
        subnet_ids = "private"
      }
      ssmmessages = {
        service = "ssmmessages"
        subnet_ids = "private"
      }
      ssm = {
        service = "ssm"
        subnet_ids = "private"
      }
      logs = {
        service = "logs"
        subnet_ids = "private"
      }
      secretsmanager = {
        service = "secretsmanager"
        subnet_ids = "private"
      }
      kms = {
        service = "kms"
        subnet_ids = "private"
      }
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "VPC Infrastructure"
  }
} 