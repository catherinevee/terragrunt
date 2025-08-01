# ==============================================================================
# Security Groups Module Configuration for Client B - Development Environment
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
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Security Groups - Development"
  
  # Security Groups specific configuration for development environment
  security_groups_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Security Groups"
    
    # VPC ID from dependency
    vpc_id = dependency.vpc.outputs.vpc_id
    
    # Security Groups configuration
    create_security_groups = true
    security_groups = {
      # Web server security group
      "web-server-sg" = {
        name = "ClientBDevWebServerSG"
        description = "Security group for web servers in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "HTTP from internet"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          },
          {
            description = "HTTPS from internet"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          },
          {
            description = "SSH from office"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Office networks
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "All outbound traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "Web Server Security"
          Tier        = "Frontend"
          Owner       = "DevOps Team"
        }
      }
      
      # Application server security group
      "app-server-sg" = {
        name = "ClientBDevAppServerSG"
        description = "Security group for application servers in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "HTTP from web servers"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["web-server-sg"]
            self = false
          },
          {
            description = "HTTPS from web servers"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["web-server-sg"]
            self = false
          },
          {
            description = "Application port from web servers"
            from_port = 8080
            to_port = 8080
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["web-server-sg"]
            self = false
          },
          {
            description = "SSH from office"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Office networks
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "All outbound traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "Application Server Security"
          Tier        = "Backend"
          Owner       = "DevOps Team"
        }
      }
      
      # Database security group
      "database-sg" = {
        name = "ClientBDevDatabaseSG"
        description = "Security group for databases in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "MySQL from app servers"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["app-server-sg"]
            self = false
          },
          {
            description = "PostgreSQL from app servers"
            from_port = 5432
            to_port = 5432
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["app-server-sg"]
            self = false
          },
          {
            description = "SSH from office"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Office networks
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "All outbound traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "Database Security"
          Tier        = "Data"
          Owner       = "DevOps Team"
        }
      }
      
      # Load balancer security group
      "load-balancer-sg" = {
        name = "ClientBDevLoadBalancerSG"
        description = "Security group for load balancers in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "HTTP from internet"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          },
          {
            description = "HTTPS from internet"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "HTTP to web servers"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["web-server-sg"]
            self = false
          },
          {
            description = "HTTPS to web servers"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = []
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = ["web-server-sg"]
            self = false
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "Load Balancer Security"
          Tier        = "Load Balancer"
          Owner       = "DevOps Team"
        }
      }
      
      # VPC endpoints security group
      "vpc-endpoints-sg" = {
        name = "ClientBDevVPCEndpointsSG"
        description = "Security group for VPC endpoints in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "HTTPS from private subnets"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = [include.region.locals.region_config.vpc_cidr]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "All outbound traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        tags = {
          Environment = "Development"
          Purpose     = "VPC Endpoints Security"
          Tier        = "Infrastructure"
          Owner       = "DevOps Team"
        }
      }
      
      # Monitoring security group
      "monitoring-sg" = {
        name = "ClientBDevMonitoringSG"
        description = "Security group for monitoring services in development environment"
        vpc_id = dependency.vpc.outputs.vpc_id
        
        # Ingress rules
        ingress_rules = [
          {
            description = "SSH from office"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Office networks
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          },
          {
            description = "HTTP from office"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Office networks
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
          }
        ]
        
        # Egress rules
        egress_rules = [
          {
            description = "All outbound traffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
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