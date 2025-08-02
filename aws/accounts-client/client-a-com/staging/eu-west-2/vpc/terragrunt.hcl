# ==============================================================================
# VPC Module Configuration for Client A - Staging Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
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
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "VPC Infrastructure - Staging (eu-west-2)"
  
  # VPC configuration for staging environment
  vpc_config = {
    # VPC settings
    vpc_name = "client-a-staging-vpc"
    vpc_cidr = include.region.locals.region_config.vpc_cidr
    
    # Availability zones
    azs = include.region.locals.region_config.azs
    
    # Subnet configurations
    public_subnets = include.region.locals.region_config.public_subnets
    private_subnets = include.region.locals.region_config.private_subnets
    database_subnets = include.region.locals.region_config.database_subnets
    elasticache_subnets = include.region.locals.region_config.elasticache_subnets
    
    # Network configuration (Staging settings - balanced between dev and prod)
    enable_nat_gateway = true
    single_nat_gateway = false  # Multiple NAT Gateways for reliability
    enable_vpn_gateway = true   # VPN for secure access
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
      cloudwatch = {
        service = "monitoring"
        subnet_ids = "private"
        security_group_ids = ["default"]
      }
    }
    
    # Tags for all VPC resources
    tags = {
      Name = "client-a-staging-vpc"
      Purpose = "VPC Foundation"
      Environment = "Staging"
      Service = "VPC"
      Compliance = "SOC2"
    }
  }
  
  # Tags for all VPC resources
  tags = {
    Environment = "Staging"
    Project     = "Client A Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    Client      = "Client A"
    Compliance  = "SOC2"
  }
} 