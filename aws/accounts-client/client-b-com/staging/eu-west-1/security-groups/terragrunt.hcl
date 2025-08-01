# ==============================================================================
# Security Groups Module Configuration for Client B - Staging Environment
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
  project     = "Security Groups - Staging"
  
  security_groups_config = {
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "Security Groups"
    vpc_id = dependency.vpc.outputs.vpc_id
    create_security_groups = true
    
    security_groups = {
      "web-server-sg" = {
        name = "ClientBStagingWebServerSG"
        description = "Security group for web servers in staging environment"
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
          },
          {
            description = "SSH from bastion"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
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
          Environment = "Staging"
          Purpose     = "Web Server Security"
          Tier        = "Frontend"
          Owner       = "DevOps Team"
        }
      }
      
      "app-server-sg" = {
        name = "ClientBStagingAppServerSG"
        description = "Security group for application servers in staging environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "HTTP from web servers"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["web-server-sg"]
            self = null
          },
          {
            description = "HTTPS from web servers"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["web-server-sg"]
            self = null
          },
          {
            description = "SSH from bastion"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
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
          Environment = "Staging"
          Purpose     = "Application Server Security"
          Tier        = "Application"
          Owner       = "DevOps Team"
        }
      }
      
      "database-sg" = {
        name = "ClientBStagingDatabaseSG"
        description = "Security group for database servers in staging environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "MySQL from app servers"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-server-sg"]
            self = null
          },
          {
            description = "PostgreSQL from app servers"
            from_port = 5432
            to_port = 5432
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["app-server-sg"]
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
          Environment = "Staging"
          Purpose     = "Database Security"
          Tier        = "Database"
          Owner       = "DevOps Team"
        }
      }
      
      "load-balancer-sg" = {
        name = "ClientBStagingLoadBalancerSG"
        description = "Security group for load balancers in staging environment"
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
            description = "HTTP to web servers"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["web-server-sg"]
            self = null
          },
          {
            description = "HTTPS to web servers"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = null
            ipv6_cidr_blocks = null
            prefix_list_ids = null
            security_groups = ["web-server-sg"]
            self = null
          }
        ]
        tags = {
          Environment = "Staging"
          Purpose     = "Load Balancer Security"
          Tier        = "Load Balancer"
          Owner       = "DevOps Team"
        }
      }
      
      "vpc-endpoints-sg" = {
        name = "ClientBStagingVPCEndpointsSG"
        description = "Security group for VPC endpoints in staging environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "HTTPS from private subnets"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
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
          Environment = "Staging"
          Purpose     = "VPC Endpoints Security"
          Tier        = "Infrastructure"
          Owner       = "DevOps Team"
        }
      }
      
      "monitoring-sg" = {
        name = "ClientBStagingMonitoringSG"
        description = "Security group for monitoring services in staging environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        ingress_rules = [
          {
            description = "Prometheus metrics"
            from_port = 9090
            to_port = 9090
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
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
            cidr_blocks = ["10.0.0.0/8"]
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
          Environment = "Staging"
          Purpose     = "Monitoring Security"
          Tier        = "Monitoring"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 