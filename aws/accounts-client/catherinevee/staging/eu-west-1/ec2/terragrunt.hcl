# Terragrunt config for EC2 instances in staging

terraform {
  source = "../../modules//ec2"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../vpc",
    "../subnets",
    "../securitygroup"
  ]
}

inputs = {
  environment = "staging"
  region      = "eu-west-1"
  project     = "catherinevee"
  costcenter  = "ITS"
  instance_type = "t3.medium"
  key_name      = "staging-key"
  subnet_ids    = dependency.subnets.outputs.subnet_ids
  vpc_id        = dependency.vpc.outputs.vpc_id
  security_group_ids = dependency.securitygroup.outputs.security_group_ids
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
    Purpose     = "application-server"
  }
}
