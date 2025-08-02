include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  alb_config   = local.account_vars.locals.alb_config
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
      backend_port     = 8080
      target_type      = "ip"
      
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
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
      certificate_arn    = "arn:aws:acm:eu-west-1:123456789012:certificate/mock-cert"  # Replace with actual certificate ARN
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
  }
} 