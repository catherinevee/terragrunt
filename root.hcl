locals {
  tfstate_region = "us-west-1"
  provider_version_aws = "6.2.0"
  provider_version_azure = "4.35.0"
}
terraform {
  remote_state {
    backend = "s3"
    generate = {
      path      = "backend.tf"
      if_exists = "overwrite"
    }
    config = {
      bucket         = "tfstate"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "${locals.tfstate_region}"
      encrypt        = true
      dynamodb_table = "my-lock-table"
    } 
  }
  generate "provider" {
    path = "providers.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
  provider "aws" {
    region = "${locals.tfstate_region}"
  }
  provider "azure" {}
  EOF
  }
  generate "provider" {
    path = "providers.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
  provider "aws" {
    region = "${locals.tfstate_region}"
  }
  EOF
  }
  generate "provider_version" {
    path = "versions.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
  terraform {
    required_version = "1.13.0"
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "${locals.provider_version_aws}"
      }
      azurerm = {
        source = "hashicorp/azurerm"
        version = "${locals.provider_version_azure}"
      }
    }
  }
  EOF
  }
  

}

include "modules" {
  path = "./modules"
}

include "aws" {
  path = "./aws"
}

include "azure" {
  path = "./azure"
}