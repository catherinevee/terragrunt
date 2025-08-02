# Terragrunt config for Security Group

terraform {
  source = "../modules//securitygroup"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name        = "catherinevee-sg"
  cidr_blocks = ["0.0.0.0/0"]
}
