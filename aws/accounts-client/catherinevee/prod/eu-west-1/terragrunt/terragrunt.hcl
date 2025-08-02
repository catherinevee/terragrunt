# Root Terragrunt configuration for eu-west-1 environment

remote_state {
  backend = "s3"
  config = {
    bucket         = "terragrunt-state-catherinevee-eu-west-1-prod"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terragrunt-locks-catherinevee-eu-west-1-prod"
  }
}

terraform {
  extra_arguments "tf_version" {
    commands = ["init", "apply", "plan", "import", "push", "refresh"]
    arguments = ["-terraform-version=1.13.0"]
  }
}

provider "aws" {
  version = "~> 6.2.0"
}
