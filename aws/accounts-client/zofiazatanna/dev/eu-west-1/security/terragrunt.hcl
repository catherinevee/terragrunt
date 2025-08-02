terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/securitygroup?ref=main"
}

dependency "vpc" {
  config_path = "../network/vpc"
}

inputs = {
  name        = "client-a-security-sg"
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Security group for client-a-com security services"
  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "Security"
    Owner       = "Zofia Zatanna"
  }
}
