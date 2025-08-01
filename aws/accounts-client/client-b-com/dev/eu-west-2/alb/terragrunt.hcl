# ==============================================================================
# Application Load Balancer Module Configuration for Client B - Development Environment (eu-west-2)
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
  source = "git::https://github.com/catherinevee/tfm-aws-alb.git//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Application Load Balancer - Development (eu-west-2)"
  
  alb_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Application Load Balancer"
    create_load_balancers = true
    
    load_balancers = {
      "dev-ecommerce-alb" = {
        name = "client-b-dev-ecommerce-alb"
        internal = false
        load_balancer_type = "application"
        security_groups = [dependency.security_groups.outputs.security_group_ids["alb-sg"]]
        subnets = dependency.vpc.outputs.public_subnet_ids
        
        enable_deletion_protection = false  # For dev environment
        enable_cross_zone_load_balancing = true
        enable_http2 = true
        
        access_logs = {
          bucket = "client-b-dev-alb-logs-${include.account.locals.account_id}"
          prefix = "alb-logs/"
          enabled = true
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Load Balancer"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
    
    target_groups = {
      "dev-ecommerce-tg" = {
        name = "client-b-dev-ecommerce-tg"
        port = 80
        protocol = "HTTP"
        vpc_id = dependency.vpc.outputs.vpc_id
        target_type = "instance"
        
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
        
        stickiness = {
          type = "lb_cookie"
          cookie_duration = 86400
          enabled = false  # Disabled for dev
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Target Group"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
    
    listeners = {
      "dev-ecommerce-http" = {
        load_balancer_arn = "dev-ecommerce-alb"
        port = 80
        protocol = "HTTP"
        default_action = {
          type = "forward"
          target_group_arn = "dev-ecommerce-tg"
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce HTTP Listener"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-ecommerce-https" = {
        load_balancer_arn = "dev-ecommerce-alb"
        port = 443
        protocol = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
        certificate_arn = "arn:aws:acm:eu-west-2:${include.account.locals.account_id}:certificate/dev-cert-id"  # Replace with actual certificate ARN
        
        default_action = {
          type = "forward"
          target_group_arn = "dev-ecommerce-tg"
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce HTTPS Listener"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
    
    listener_rules = {
      "dev-ecommerce-api" = {
        listener_arn = "dev-ecommerce-https"
        priority = 100
        
        action = {
          type = "forward"
          target_group_arn = "dev-ecommerce-tg"
        }
        
        condition = {
          field = "path-pattern"
          values = ["/api/*"]
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce API Rule"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
      
      "dev-ecommerce-admin" = {
        listener_arn = "dev-ecommerce-https"
        priority = 200
        
        action = {
          type = "forward"
          target_group_arn = "dev-ecommerce-tg"
        }
        
        condition = {
          field = "path-pattern"
          values = ["/admin/*"]
        }
        
        tags = {
          Environment = "Development"
          Purpose     = "Ecommerce Admin Rule"
          Service     = "Ecommerce"
          Owner       = "DevOps Team"
        }
      }
    }
  }
} 