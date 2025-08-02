# Terragrunt config for IAM in staging

terraform {
  source = "../../modules//iam/iam_user"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "staging"
  user_name   = "staging-user"
  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  tags = {
    Environment = "staging"
    Owner       = "catherinevee"
  }
}
