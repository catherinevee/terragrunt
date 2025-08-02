# Terragrunt config for Security Group

terraform {
  source = "../modules//securitygroup"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "subnets" {
  config_path = "../subnets"
}

inputs = {
  name        = "catherinevee-sg-prod"
  cidr_blocks = [dependency.subnets.outputs.cidr_block]
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Allow SSH from trusted subnet"
  ingress_rules = [
    {
      description = "SSH from subnet"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [dependency.subnets.outputs.cidr_block]
    },
    {
      description = "HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description = "All traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
  tags = {
    Name        = "catherinevee-sg-prod"
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
  }
}
