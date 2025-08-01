# ==============================================================================
# Application Load Balancer Module Configuration for Client B - Development Environment (eu-west-3)
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

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/alb.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Application Load Balancer - Development"
  
  # VPC and subnet references
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  
  # Security group reference
  alb_security_group_id = dependency.security_groups.outputs.alb_security_group_id
  
  # ALB configuration for development environment
  alb_config = {
    # Application Load Balancer
    load_balancer = {
      name = "client-b-dev-alb"
      internal = false  # Internet-facing for dev
      load_balancer_type = "application"
      security_groups = [dependency.security_groups.outputs.alb_security_group_id]
      subnets = dependency.vpc.outputs.public_subnet_ids
      
      # Access logs
      access_logs = {
        bucket = "client-b-dev-logs-${include.account.locals.account_id}"
        prefix = "alb-logs"
        enabled = true
      }
      
      # Deletion protection (disabled for dev)
      enable_deletion_protection = false
      
      # Tags
      tags = {
        Name = "client-b-dev-alb"
        Purpose = "Application Load Balancer"
        Environment = "Development"
        Service = "ALB"
      }
    }
    
    # Target Groups
    target_groups = {
      # Web tier target group
      web = {
        name = "client-b-dev-web-tg"
        port = 80
        protocol = "HTTP"
        vpc_id = dependency.vpc.outputs.vpc_id
        target_type = "instance"
        
        # Health check
        health_check = {
          enabled = true
          healthy_threshold = 2
          unhealthy_threshold = 2
          timeout = 5
          interval = 30
          path = "/"
          port = "traffic-port"
          protocol = "HTTP"
          matcher = "200"
        }
        
        # Tags
        tags = {
          Name = "client-b-dev-web-tg"
          Purpose = "Web Tier Target Group"
          Environment = "Development"
          Tier = "Web"
        }
      }
      
      # Application tier target group
      app = {
        name = "client-b-dev-app-tg"
        port = 8080
        protocol = "HTTP"
        vpc_id = dependency.vpc.outputs.vpc_id
        target_type = "instance"
        
        # Health check
        health_check = {
          enabled = true
          healthy_threshold = 2
          unhealthy_threshold = 2
          timeout = 5
          interval = 30
          path = "/health"
          port = "traffic-port"
          protocol = "HTTP"
          matcher = "200"
        }
        
        # Tags
        tags = {
          Name = "client-b-dev-app-tg"
          Purpose = "Application Tier Target Group"
          Environment = "Development"
          Tier = "Application"
        }
      }
    }
    
    # Listeners
    listeners = {
      # HTTP listener (port 80)
      http = {
        port = 80
        protocol = "HTTP"
        default_action = {
          type = "forward"
          target_group_arn = "self"  # Will reference web target group
        }
        
        # Additional rules
        rules = [
          {
            priority = 100
            conditions = [
              {
                field = "path-pattern"
                values = ["/api/*"]
              }
            ]
            actions = [
              {
                type = "forward"
                target_group_arn = "self"  # Will reference app target group
              }
            ]
          }
        ]
      }
      
      # HTTPS listener (port 443) - for future SSL/TLS
      https = {
        port = 443
        protocol = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
        certificate_arn = "arn:aws:acm:${include.region.locals.region}:${include.account.locals.account_id}:certificate/placeholder"  # Placeholder
        default_action = {
          type = "forward"
          target_group_arn = "self"  # Will reference web target group
        }
        
        # Additional rules
        rules = [
          {
            priority = 100
            conditions = [
              {
                field = "path-pattern"
                values = ["/api/*"]
              }
            ]
            actions = [
              {
                type = "forward"
                target_group_arn = "self"  # Will reference app target group
              }
            ]
          }
        ]
      }
    }
  }
  
  # Tags for all ALB resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
  }
} 