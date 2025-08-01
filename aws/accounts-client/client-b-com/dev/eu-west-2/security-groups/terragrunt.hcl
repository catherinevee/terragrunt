# ==============================================================================
# Security Groups Module Configuration for Client B - Development Environment (eu-west-2)
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
  source = "git::https://github.com/catherinevee/tfm-aws-security-groups.git//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Security Groups - Development (eu-west-2)"
  
  security_groups_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Security Groups"
    vpc_id = dependency.vpc.outputs.vpc_id
    create_security_groups = true
    
    security_groups = {
      "alb-sg" = {
        name = "ClientBDevALBSG"
        description = "Security group for Application Load Balancer in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "HTTP from internet"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          },
          {
            description = "HTTPS from internet"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        egress_rules = [
          {
            description = "HTTP to application servers"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-sg"]
            self = null
          },
          {
            description = "HTTPS to application servers"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-sg"]
            self = null
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Load Balancer Security"
          Tier        = "Load Balancer"
          Owner       = "DevOps Team"
        }
      }
      
      "app-sg" = {
        name = "ClientBDevAppSG"
        description = "Security group for application servers in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "HTTP from ALB"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["alb-sg"]
            self = null
          },
          {
            description = "HTTPS from ALB"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["alb-sg"]
            self = null
          },
          {
            description = "SSH from VPC"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        egress_rules = [
          {
            description = "All traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Application Server Security"
          Tier        = "Application"
          Owner       = "DevOps Team"
        }
      }
      
      "db-sg" = {
        name = "ClientBDevDBSG"
        description = "Security group for database in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "MySQL from application servers"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-sg"]
            self = null
          }
        ]
        egress_rules = [
          {
            description = "All traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Database Security"
          Tier        = "Database"
          Owner       = "DevOps Team"
        }
      }
      
      "cache-sg" = {
        name = "ClientBDevCacheSG"
        description = "Security group for ElastiCache in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "Redis from application servers"
            from_port = 6379
            to_port = 6379
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-sg"]
            self = null
          }
        ]
        egress_rules = [
          {
            description = "All traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Cache Security"
          Tier        = "Cache"
          Owner       = "DevOps Team"
        }
      }
      
      "monitoring-sg" = {
        name = "ClientBDevMonitoringSG"
        description = "Security group for monitoring services in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "Prometheus metrics"
            from_port = 9090
            to_port = 9090
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          },
          {
            description = "Grafana dashboard"
            from_port = 3000
            to_port = 3000
            protocol = "tcp"
            cidr_blocks = ["10.2.0.0/16"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        egress_rules = [
          {
            description = "All traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = null
            self = null
          }
        ]
        tags = {
          Environment = "Development"
          Purpose     = "Monitoring Security"
          Tier        = "Monitoring"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 