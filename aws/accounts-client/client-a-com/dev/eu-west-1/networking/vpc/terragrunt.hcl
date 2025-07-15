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
  source = "../../../modules/vpc"
}

locals {
  region = include.region.locals.region
  environment = include.region.locals.environment
}


inputs = {

}
