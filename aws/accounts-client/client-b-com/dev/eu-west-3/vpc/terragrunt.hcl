# ==============================================================================
# VPC Module Configuration for Client B - Development Environment (eu-west-3)
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
  source = "git::https://github.com/catherinevee/vpc.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "VPC Foundation - Development"
  
  # VPC configuration for development environment
  vpc_config = {
    # VPC settings
    vpc_name = "client-b-dev-vpc"
    vpc_cidr = include.region.locals.region_config.vpc_cidr
    
    # Availability zones
    azs = include.region.locals.region_config.azs
    
    # Subnet configurations
    public_subnets = include.region.locals.region_config.public_subnets
    private_subnets = include.region.locals.region_config.private_subnets
    database_subnets = include.region.locals.region_config.database_subnets
    elasticache_subnets = include.region.locals.region_config.elasticache_subnets
    
    # Network configuration
    enable_nat_gateway = true
    single_nat_gateway = true  # Cost optimization for dev
    enable_vpn_gateway = false
    enable_dns_hostnames = true
    enable_dns_support = true
    
    # VPC Endpoints for AWS services
    enable_vpc_endpoints = true
    vpc_endpoints = {
      s3 = {
        service = "s3"
        subnet_ids = []  # Gateway endpoint, no subnet needed
      }
      dynamodb = {
        service = "dynamodb"
        subnet_ids = []  # Gateway endpoint, no subnet needed
      }
      ec2 = {
        service = "ec2"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      ec2messages = {
        service = "ec2messages"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      ssm = {
        service = "ssm"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      ssmmessages = {
        service = "ssmmessages"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      logs = {
        service = "logs"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      secretsmanager = {
        service = "secretsmanager"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
      kms = {
        service = "kms"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
    }
    
    # Tags
    tags = {
      Environment = "Development"
      Project     = "Client B Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Internal"
    }
  }
} 