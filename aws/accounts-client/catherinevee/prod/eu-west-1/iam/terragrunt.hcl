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
      pgp_key = "keybase:qatherine"
      tags = {
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name = "katherine"
      create_iam_access_key = false
      create_iam_user_login_profile = true
      force_destroy = false
      password_reset_required = true
      pgp_key = "keybase:katherine"
      tags = {
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    }
  ]
  group = {
    name = "devops"
    path = "/"
    users = ["catherine", "qatherine", "katherine"]
    tags = {
      Environment = "prod"
      Project     = "catherinevee"
      ManagedBy   = "terragrunt"
    }
  }
  tags = {
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
    Terraform   = true
  }
  # Example: add policies, roles, or MFA configuration if supported by the module
}
