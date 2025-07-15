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
  source = "../../../../modules/ec2"
}
dependency "securitygroup" {
  config_path = "../../../../modules/securitygroup"
}
dependency "vpc" {
  config_path = "../../../../modules/vpc"
}


inputs = {
  s = dependency.compute.locals.instance_type
  vpc_id = dependency.vpc.outputs.vpc_id
}