include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  account_id   = "987654321098"  # Different account ID for client-b-com
  environment = basename(get_terragrunt_dir())
  client_name = basename(dirname(get_terragrunt_dir()))
  account_name = "account-${local.client_name}-${local.environment}"
} 