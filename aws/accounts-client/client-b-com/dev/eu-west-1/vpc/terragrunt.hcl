# ==============================================================================
# VPC Module Configuration for Client B - Development Environment
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
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "VPC Infrastructure - Development"
  
  # VPC specific configuration for development environment
  vpc_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "VPC Infrastructure"
    
    # VPC configuration
    vpc = {
      name = "ClientBDevVPC"
      cidr_block = include.region.locals.region_config.vpc_cidr
      enable_dns_hostnames = true
      enable_dns_support = true
      instance_tenancy = "default"
      
      tags = {
        Environment = "Development"
        Purpose     = "VPC Infrastructure"
        Owner       = "DevOps Team"
        DataClassification = "Internal"
      }
    }
    
    # Availability Zones
    availability_zones = include.region.locals.region_config.azs
    
    # Public subnets
    public_subnets = {
      for i, az in include.region.locals.region_config.azs : "public-${az}" => {
        name = "public-${az}"
        cidr_block = include.region.locals.region_config.public_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = true
        tags = {
          Environment = "Development"
          Purpose     = "Public Subnet"
          Tier        = "Public"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Private subnets
    private_subnets = {
      for i, az in include.region.locals.region_config.azs : "private-${az}" => {
        name = "private-${az}"
        cidr_block = include.region.locals.region_config.private_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = false
        tags = {
          Environment = "Development"
          Purpose     = "Private Subnet"
          Tier        = "Private"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Database subnets
    database_subnets = {
      for i, az in include.region.locals.region_config.azs : "database-${az}" => {
        name = "database-${az}"
        cidr_block = include.region.locals.region_config.database_subnets[i]
        availability_zone = az
        map_public_ip_on_launch = false
        tags = {
          Environment = "Development"
          Purpose     = "Database Subnet"
          Tier        = "Database"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # Internet Gateway
    internet_gateway = {
      enabled = true
      name = "ClientBDevIGW"
      tags = {
        Environment = "Development"
        Purpose     = "Internet Gateway"
        Owner       = "DevOps Team"
      }
    }
    
    # NAT Gateway
    nat_gateway = {
      enabled = true
      name = "ClientBDevNAT"
      allocation_id = null  # Will be created by EIP
      subnet_id = null     # Will reference first public subnet
      tags = {
        Environment = "Development"
        Purpose     = "NAT Gateway"
        Owner       = "DevOps Team"
      }
    }
    
    # Route Tables
    route_tables = {
      public = {
        name = "ClientBDevPublicRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            gateway_id = null  # Will reference Internet Gateway
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Public Route Table"
          Owner       = "DevOps Team"
        }
      }
      
      private = {
        name = "ClientBDevPrivateRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = null  # Will reference NAT Gateway
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Private Route Table"
          Owner       = "DevOps Team"
        }
      }
      
      database = {
        name = "ClientBDevDatabaseRT"
        routes = [
          {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = null  # Will reference NAT Gateway
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Database Route Table"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # VPC Endpoints (for AWS services)
    vpc_endpoints = {
      s3 = {
        service = "s3"
        vpc_endpoint_type = "Gateway"
        route_table_ids = []  # Will reference private route tables
        tags = {
          Environment = "Development"
          Purpose     = "S3 VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      
      dynamodb = {
        service = "dynamodb"
        vpc_endpoint_type = "Gateway"
        route_table_ids = []  # Will reference private route tables
        tags = {
          Environment = "Development"
          Purpose     = "DynamoDB VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      
      ec2 = {
        service = "ec2"
        vpc_endpoint_type = "Interface"
        subnet_ids = []  # Will reference private subnets
        security_group_ids = []  # Will reference security groups
        private_dns_enabled = true
        tags = {
          Environment = "Development"
          Purpose     = "EC2 VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      
      ec2messages = {
        service = "ec2messages"
        vpc_endpoint_type = "Interface"
        subnet_ids = []  # Will reference private subnets
        security_group_ids = []  # Will reference security groups
        private_dns_enabled = true
        tags = {
          Environment = "Development"
          Purpose     = "EC2 Messages VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      
      ssm = {
        service = "ssm"
        vpc_endpoint_type = "Interface"
        subnet_ids = []  # Will reference private subnets
        security_group_ids = []  # Will reference security groups
        private_dns_enabled = true
        tags = {
          Environment = "Development"
          Purpose     = "SSM VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
      
      ssmessages = {
        service = "ssmmessages"
        vpc_endpoint_type = "Interface"
        subnet_ids = []  # Will reference private subnets
        security_group_ids = []  # Will reference security groups
        private_dns_enabled = true
        tags = {
          Environment = "Development"
          Purpose     = "SSM Messages VPC Endpoint"
          Owner       = "DevOps Team"
        }
      }
    }
    
    # DHCP Options
    dhcp_options = {
      domain_name = "dev.internal"
      domain_name_servers = ["AmazonProvidedDNS"]
      ntp_servers = ["169.254.169.123"]
      netbios_name_servers = []
      netbios_node_type = 2
      tags = {
        Environment = "Development"
        Purpose     = "DHCP Options"
        Owner       = "DevOps Team"
      }
    }
  }
} 