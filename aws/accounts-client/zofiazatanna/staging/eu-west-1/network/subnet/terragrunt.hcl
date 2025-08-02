terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/subnet?ref=main"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name       = "example-subnet"
  vpc_id     = dependency.vpc.outputs.vpc_id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
  }
}

outputs = {
  subnet_id = {
    value = module.subnet.subnet_id
    description = "The ID of the subnet."
  }
  subnet_group_name = {
    value = module.subnet.subnet_group_name
    description = "The name of the subnet group (for RDS, etc)."
  }
}
