include "root" {
  path = find_in_parent_folders("root.hcl")
}
include {
  path = find_in_parent_folders("common.tcl")
}


locals {
  account_id   = "123456789012"
  environment = ${basename(get_terragrunt_dir())}
  client_name = ${basename(dirname(get_terragrunt_dir()))}
  account_name = "account-${local.client_name}-${local.environment}"

}

