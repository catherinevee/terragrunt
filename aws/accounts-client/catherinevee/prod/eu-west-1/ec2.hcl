# Terragrunt config for EC2 instances

terraform {
  source = "../modules//ec2"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "prod"
  region      = "eu-west-1"
  project     = "catherinevee"
  costcenter  = "ITS"
  # Add subnet_id, vpc_security_group_ids, key_name, etc. as needed
}
