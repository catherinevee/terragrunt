# ==============================================================================
# VPC Module Configuration for Client B - Staging Environment
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
  source = "git::https://github.com/catherinevee/tfm-aws-vpc.git//?ref=v1.0.0"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "VPC Infrastructure - Staging"
  
  vpc_config = {
    vpc = {
      name = "ClientBStagingVPC"
      cidr_block = include.region.locals.region_config.vpc_cidr
      enable_dns_hostnames = true
      enable_dns_support = true
      instance_tenancy = "default"
      tags = {
        Environment = "Staging"
        Purpose     = "VPC Infrastructure"
        Owner       = "DevOps Team"
        DataClassification = "Internal"
      }
    }
    
    availability_zones = include.region.locals.region_config.azs
    
    public_subnets = {
      for i, az in include.region.locals.region_config.azs : "public-${az}" => {
        name = "public-${az}"
        cidr_block = include.region.locals.region_config.public_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = true
        tags = {
          Environment = "Staging"
          Purpose     = "Public Subnet"
          Tier        = "Public"
          Owner       = "DevOps Team"
        }
      }
    }
    
    private_subnets = {
      for i, az in include.region.locals.region_config.azs : "private-${az}" => {
        name = "private-${az}"
        cidr_block = include.region.locals.region_config.private_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = false
        tags = {
          Environment = "Staging"
          Purpose     = "Private Subnet"
          Tier        = "Private"
          Owner       = "DevOps Team"
        }
      }
    }
    
    database_subnets = {
      for i, az in include.region.locals.region_config.azs : "database-${az}" => {
        name = "database-${az}"
        cidr_block = include.region.locals.region_config.database_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = false
        tags = {
          Environment = "Staging"
          Purpose     = "Database Subnet"
          Tier        = "Database"
          Owner       = "DevOps Team"
        }
      }
    }
    
    internet_gateway = {
      name = "ClientBStagingIGW"
      tags = {
        Environment = "Staging"
        Purpose     = "Internet Gateway"
        Owner       = "DevOps Team"
      }
    }
    
    nat_gateway = {
      name = "ClientBStagingNAT"
      allocation_id = null  # Will be created by the module
      subnet_id = null      # Will reference public subnet
      tags = {
        Environment = "Staging"
        Purpose     = "NAT Gateway"
        Owner       = "DevOps Team"
      }
    }
    
    route_tables = {
      public = {
        name = "ClientBStagingPublicRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            gateway_id = null  # Will reference IGW
          }
        ]
        tags = {
          Environment = "Staging"
          Purpose     = "Public Route Table"
          Owner       = "DevOps Team"
        }
      }
      private = {
        name = "ClientBStagingPrivateRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = null  # Will reference NAT Gateway
          }
        ]
        tags = {
          Environment = "Staging"
          Purpose     = "Private Route Table"
          Owner       = "DevOps Team"
        }
      }
      database = {
        name = "ClientBStagingDatabaseRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = null  # Will reference NAT Gateway
          }
        ]
        tags = {
          Environment = "Staging"
          Purpose     = "Database Route Table"
          Owner       = "DevOps Team"
        }
      }
    }
    
    vpc_endpoints = {
      s3 = {
        service = "s3"
        subnet_ids = null  # Will reference private subnets
        security_group_ids = null  # Will reference security groups
        tags = {
          Environment = "Staging"
          Purpose     = "S3 VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      dynamodb = {
        service = "dynamodb"
        subnet_ids = null  # Will reference private subnets
        security_group_ids = null  # Will reference security groups
        tags = {
          Environment = "Staging"
          Purpose     = "DynamoDB VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
    }
    
    dhcp_options = {
      domain_name = "staging.client-b.internal"
      domain_name_servers = ["AmazonProvidedDNS"]
      ntp_servers = ["169.254.169.123"]
      tags = {
        Environment = "Staging"
        Purpose     = "DHCP Options"
        Owner       = "DevOps Team"
      }
    }
  }
} 