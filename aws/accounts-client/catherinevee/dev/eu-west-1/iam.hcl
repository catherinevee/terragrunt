# Terragrunt config for IAM

terraform {
  source = "../modules//iam/iam_user"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  # Add IAM user variables as needed
}
