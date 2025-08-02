terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/elb?ref=main"
}

dependency "subnet" {
  config_path = "../../network/subnet"
}

dependency "securitygroup" {
  config_path = "../../network/securitygroup"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  name               = "client-a-elb"
  subnets            = [dependency.subnet.outputs.subnet_id]
  security_groups    = [dependency.securitygroup.outputs.security_group_id]
  vpc_id             = dependency.vpc.outputs.vpc_id
  internal           = false
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}

outputs = {
  elb_dns_name = {
    value = module.elb.dns_name
    description = "The DNS name of the ELB."
  }
}
