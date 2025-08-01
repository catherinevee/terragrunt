# ==============================================================================
# Application Load Balancer Module Configuration for Client B - Production Environment (eu-west-2)
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
  source = "https://github.com/catherinevee/tfm-aws-alb//?ref=v1.0.0"
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region_name
  client_name = include.account.locals.client_name
  
  # ALB Configuration
  alb_config = {
    # Load balancer configuration
    lb_config = {
      name = "client-b-prod-alb"
      internal = false
      load_balancer_type = "application"
      security_groups = [dependency.security_groups.outputs.security_group_ids["alb-sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
      
      # Access logs
      access_logs = {
        bucket = "client-b-prod-alb-logs"
        prefix = "alb-logs"
        enabled = true
      }
      
      # Idle timeout
      idle_timeout = 60
      enable_deletion_protection = true
      enable_cross_zone_load_balancing = true
    }
    
    # Target groups configuration
    target_groups = {
      "app-tg" = {
        name = "client-b-prod-app-tg"
        port = 80
        protocol = "HTTP"
        vpc_id = dependency.vpc.outputs.vpc_id
        target_type = "instance"
        
        health_check = {
          enabled = true
          healthy_threshold = 2
          unhealthy_threshold = 3
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
          enabled = true
        }
      }
    }
    
    # Listeners configuration
    listeners = {
      "http" = {
        port = 80
        protocol = "HTTP"
        default_action = {
          type = "redirect"
          redirect = {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
          }
        }
      }
      
      "https" = {
        port = 443
        protocol = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
        certificate_arn = "arn:aws:acm:${include.region.locals.region_name}:${include.account.locals.account_id}:certificate/your-certificate-id"
        
        default_action = {
          type = "forward"
          target_group_key = "app-tg"
        }
      }
    }
    
    # Listener rules
    listener_rules = {
      "api-rule" = {
        listener_key = "https"
        priority = 100
        conditions = [
          {
            field = "path-pattern"
            values = ["/api/*"]
          }
        ]
        action = {
          type = "forward"
          target_group_key = "app-tg"
        }
      }
      
      "static-rule" = {
        listener_key = "https"
        priority = 200
        conditions = [
          {
            field = "path-pattern"
            values = ["/static/*"]
          }
        ]
        action = {
          type = "forward"
          target_group_key = "app-tg"
        }
      }
      
      "admin-rule" = {
        listener_key = "https"
        priority = 300
        conditions = [
          {
            field = "path-pattern"
            values = ["/admin/*"]
          }
        ]
        action = {
          type = "forward"
          target_group_key = "app-tg"
        }
      }
    }
  }
  
  # Tags
  tags = {
    Environment = include.account.locals.environment
    Client      = include.account.locals.client_name
    Region      = include.region.locals.region_name
    ManagedBy   = "Terragrunt"
    Purpose     = "Load Balancing"
  }
} 