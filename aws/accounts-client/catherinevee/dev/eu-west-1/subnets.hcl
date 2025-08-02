# Terragrunt config for subnets

terraform {
  source = "../modules//subnets"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  # Add subnet-specific variables if needed
}
