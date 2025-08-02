# Terragrunt config for IAM

terraform {
  source = "../modules//iam/iam_user"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  users = [
    {
      name = "catherine"
      create_iam_access_key = false
      create_iam_user_login_profile = true
      force_destroy = false
      password_reset_required = true
      mfa_enabled = true
      pgp_key = "keybase:catherine"
      tags = {
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name = "qatherine"
      create_iam_access_key = false
      create_iam_user_login_profile = true
      force_destroy = false
      password_reset_required = true
      mfa_enabled = true
      pgp_key = "keybase:qatherine"
      tags = {
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    }
  ]
  group = {
    name = "prodops"
    path = "/"
    users = ["catherine", "qatherine"]
    tags = {
      Environment = "prod"
      Project     = "catherinevee"
      ManagedBy   = "terragrunt"
    }
  }
  policies = [
    {
      name = "ReadOnlyAccess"
      policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    },
    {
      name = "CustomProdPolicy"
      policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:Describe*", "s3:ListBucket"],
      "Resource": "*"
    }
  ]
}
EOF
    }
  ]
  tags = {
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
    Terraform   = true
    Compliance  = "PCI-DSS"
    Owner       = "security@catherinevee.com"
  }
}
