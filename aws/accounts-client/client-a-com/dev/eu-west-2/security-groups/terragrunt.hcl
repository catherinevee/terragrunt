# ==============================================================================
# Security Groups Module Configuration for Client A - Development Environment (eu-west-2)
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

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/security-groups.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "Security Groups - Development (eu-west-2)"
  
  # VPC reference
  vpc_id = dependency.vpc.outputs.vpc_id
  
  # Security Groups configuration for development environment
  security_groups_config = {
    # Default security group
    default = {
      name = "client-a-dev-default-sg"
      description = "Default security group for Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-default-sg"
        Purpose = "Default Security Group"
        Environment = "Development"
      }
      rules = {
        # Allow all outbound traffic
        outbound_all = {
          type = "egress"
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound traffic"
        }
      }
    }
    
    # Web tier security group
    web = {
      name = "client-a-dev-web-sg"
      description = "Security group for web tier in Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-web-sg"
        Purpose = "Web Tier Security Group"
        Environment = "Development"
        Tier = "Web"
      }
      rules = {
        # Allow HTTP from internet
        http_inbound = {
          type = "ingress"
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTP from internet"
        }
        # Allow HTTPS from internet
        https_inbound = {
          type = "ingress"
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTPS from internet"
        }
        # Allow SSH from bastion/management
        ssh_inbound = {
          type = "ingress"
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["10.1.0.0/16"]  # VPC CIDR
          description = "Allow SSH from VPC"
        }
      }
    }
    
    # Application tier security group
    app = {
      name = "client-a-dev-app-sg"
      description = "Security group for application tier in Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-app-sg"
        Purpose = "Application Tier Security Group"
        Environment = "Development"
        Tier = "Application"
      }
      rules = {
        # Allow traffic from web tier
        web_to_app = {
          type = "ingress"
          from_port = 8080
          to_port = 8080
          protocol = "tcp"
          source_security_group_id = "self"  # Will reference web security group
          description = "Allow traffic from web tier"
        }
        # Allow SSH from bastion/management
        ssh_inbound = {
          type = "ingress"
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["10.1.0.0/16"]  # VPC CIDR
          description = "Allow SSH from VPC"
        }
      }
    }
    
    # Database tier security group
    database = {
      name = "client-a-dev-database-sg"
      description = "Security group for database tier in Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-database-sg"
        Purpose = "Database Tier Security Group"
        Environment = "Development"
        Tier = "Database"
      }
      rules = {
        # Allow MySQL from application tier
        mysql_from_app = {
          type = "ingress"
          from_port = 3306
          to_port = 3306
          protocol = "tcp"
          source_security_group_id = "self"  # Will reference app security group
          description = "Allow MySQL from application tier"
        }
        # Allow PostgreSQL from application tier
        postgres_from_app = {
          type = "ingress"
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          source_security_group_id = "self"  # Will reference app security group
          description = "Allow PostgreSQL from application tier"
        }
      }
    }
    
    # ElastiCache security group
    elasticache = {
      name = "client-a-dev-elasticache-sg"
      description = "Security group for ElastiCache in Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-elasticache-sg"
        Purpose = "ElastiCache Security Group"
        Environment = "Development"
        Service = "ElastiCache"
      }
      rules = {
        # Allow Redis from application tier
        redis_from_app = {
          type = "ingress"
          from_port = 6379
          to_port = 6379
          protocol = "tcp"
          source_security_group_id = "self"  # Will reference app security group
          description = "Allow Redis from application tier"
        }
        # Allow Memcached from application tier
        memcached_from_app = {
          type = "ingress"
          from_port = 11211
          to_port = 11211
          protocol = "tcp"
          source_security_group_id = "self"  # Will reference app security group
          description = "Allow Memcached from application tier"
        }
      }
    }
    
    # Load Balancer security group
    alb = {
      name = "client-a-dev-alb-sg"
      description = "Security group for Application Load Balancer in Client A development environment"
      vpc_id = dependency.vpc.outputs.vpc_id
      tags = {
        Name = "client-a-dev-alb-sg"
        Purpose = "ALB Security Group"
        Environment = "Development"
        Service = "ALB"
      }
      rules = {
        # Allow HTTP from internet
        http_inbound = {
          type = "ingress"
          from_port = 80
          to_port = 80
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTP from internet"
        }
        # Allow HTTPS from internet
        https_inbound = {
          type = "ingress"
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow HTTPS from internet"
        }
      }
    }
  }
  
  # Tags for all security group resources
  tags = {
    Environment = "Development"
    Project     = "Client A Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    Client      = "Client A"
  }
} 