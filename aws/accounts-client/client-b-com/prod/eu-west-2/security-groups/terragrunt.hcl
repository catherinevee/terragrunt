# ==============================================================================
# Security Groups Module Configuration for Client B - Production Environment (eu-west-2)
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
  source = "https://github.com/catherinevee/tfm-aws-security-groups//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # VPC ID from dependency
  vpc_id = dependency.vpc.outputs.vpc_id
  
  # Security Groups Configuration
  security_groups = {
    "alb-sg" = {
      description = "Security group for Application Load Balancer"
      ingress_rules = [
        {
          description = "HTTP from internet"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTPS from internet"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          description = "All traffic to app tier"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
    }
    
    "app-sg" = {
      description = "Security group for application servers"
      ingress_rules = [
        {
          description = "HTTP from ALB"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          security_groups = ["alb-sg"]
        },
        {
          description = "HTTPS from ALB"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          security_groups = ["alb-sg"]
        },
        {
          description = "SSH from bastion"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
        }
      ]
      egress_rules = [
        {
          description = "All traffic to database tier"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.20.0/24", "10.2.21.0/24", "10.2.22.0/24"]
        },
        {
          description = "All traffic to cache tier"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.30.0/24", "10.2.31.0/24", "10.2.32.0/24"]
        },
        {
          description = "HTTPS to internet"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    
    "database-sg" = {
      description = "Security group for database servers"
      ingress_rules = [
        {
          description = "MySQL from app tier"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
      egress_rules = [
        {
          description = "All traffic to app tier"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
    }
    
    "cache-sg" = {
      description = "Security group for cache servers"
      ingress_rules = [
        {
          description = "Redis from app tier"
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
      egress_rules = [
        {
          description = "All traffic to app tier"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
    }
    
    "monitoring-sg" = {
      description = "Security group for monitoring servers"
      ingress_rules = [
        {
          description = "SSH from bastion"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
        },
        {
          description = "HTTP from app tier"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
        }
      ]
      egress_rules = [
        {
          description = "All traffic to all tiers"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["10.2.0.0/16"]
        }
      ]
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Network Security"
  }
} 