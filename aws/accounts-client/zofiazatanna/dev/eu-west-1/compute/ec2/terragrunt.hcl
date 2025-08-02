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
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}
dependency "securitygroup" {
  config_path = "../../network/securitygroup"
}
dependency "subnet" {
  config_path = "../../network/subnet"
}



inputs = {
  name                  = "example-ec2-instance"
  instance_type         = "t3.micro"
  ami_id                = "ami-1234567890abcdef0"
  subnet_id             = dependency.subnet.outputs.subnet_id
  vpc_id                = dependency.vpc.outputs.vpc_id
  vpc_security_group_ids = [dependency.securitygroup.outputs.security_group_id]
  key_name              = "your-key-name"
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
  }
}