# Terragrunt config for subnets in staging

terraform {
  source = "../../modules//subnets"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../vpc"
  ]
}

inputs = {
  environment = "staging"
  vpc_id      = dependency.vpc.outputs.vpc_id
  subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
    Purpose     = "networking"
  }
}
