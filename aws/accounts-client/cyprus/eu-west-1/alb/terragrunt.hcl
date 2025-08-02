include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  alb_config   = local.account_vars.locals.alb_config
  
  # Input validation for ALB module
  validate_alb_name = length(local.alb_config.name) <= 32 ? null : file("ERROR: ALB name must be <= 32 characters")
  validate_alb_name_format = can(regex("^[a-zA-Z0-9-]+$", local.alb_config.name)) ? null : file("ERROR: ALB name must contain only alphanumeric characters and hyphens")
  validate_alb_type = contains(["application", "network"], local.alb_config.load_balancer_type) ? null : file("ERROR: Load balancer type must be 'application' or 'network'")
  validate_certificate_arn = can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/", local.alb_config.certificate_arn)) ? null : file("ERROR: Invalid certificate ARN format")
  validate_health_check_path = length(local.alb_config.health_check_path) > 0 ? null : file("ERROR: Health check path cannot be empty")
  validate_health_check_path_format = can(regex("^/", local.alb_config.health_check_path)) ? null : file("ERROR: Health check path must start with /")
  validate_health_check_port = local.alb_config.health_check_port >= 1 && local.alb_config.health_check_port <= 65535 ? null : file("ERROR: Health check port must be between 1 and 65535")
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id         = "vpc-mock"
    public_subnets = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/alb/aws//?version=9.9.2"
}

inputs = {
  name = local.alb_config.name
  
  load_balancer_type = local.alb_config.load_balancer_type
  internal           = local.alb_config.internal
  
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  
  # Security groups
  security_groups = [aws_security_group.alb.id]
  
  # Target groups
  target_groups = {
    accounts_client = {
      name_prefix      = "ac-"
      backend_protocol = "HTTP"
      backend_port     = local.alb_config.health_check_port
      target_type      = "ip"
      
      health_check = {
        enabled             = true
        interval            = 30
        path                = local.alb_config.health_check_path
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  }
  
  # HTTP listener
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]
  
  # HTTPS listener (optional - requires SSL certificate)
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.alb_config.certificate_arn
      target_group_index = 0
      action_type        = "forward"
    }
  ]
  
  # HTTP to HTTPS redirect
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "load-balancing"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "cyprus-alb-"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "cyprus-alb-sg"
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "load-balancer-access"
  }
} 