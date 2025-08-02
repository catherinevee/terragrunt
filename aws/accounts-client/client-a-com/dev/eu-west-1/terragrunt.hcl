# Root-level Terragrunt configuration for eu-west-1

include "backend" {
  path = "_envcommon/backend.hcl"
}

include "provider" {
  path = "_envcommon/provider.hcl"
}

# Optionally include sensitive variables
include "sensitive" {
  path = "_envcommon/sensitive.auto.tfvars"
  expose = true
}
