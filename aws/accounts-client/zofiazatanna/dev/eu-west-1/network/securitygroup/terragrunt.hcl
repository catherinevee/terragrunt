outputs = {
  security_group_id = {
    value = module.securitygroup.security_group_id
    description = "The ID of the security group."
  }
}
terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/securitygroup?ref=main"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  name        = "example-sg"
  vpc_id      = dependency.vpc.outputs.vpc_id
  description = "Example security group"
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
  }
}

outputs = {
  security_group_id = {
    value = module.securitygroup.security_group_id
    description = "The ID of the security group."
  }
}
