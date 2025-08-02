# Terragrunt configuration for a complete AWS environment in eu-west-1

terraform {
  source = "../modules//vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project     = "catherinevee"
  environment = "dev"
  region      = "eu-west-1"
  costcenter  = "ITS"
}
