# Terragrunt config for Security Group in staging

terraform {
  source = "../../modules//securitygroup"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name        = "catherinevee-sg-staging"
  cidr_blocks = ["10.0.0.0/16"]
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
    }
  ]
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
    Purpose     = "security"
  }
}
