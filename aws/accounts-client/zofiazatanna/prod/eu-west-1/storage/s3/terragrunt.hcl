include "root" {
  path = find_in_parent_folders("root.hcl")
}
include {
  path = find_in_parent_folders("common.tcl")
}

locals {
  env = basename(get_terragrunt_dir())
}

terraform {
  source = "../../../modules/s3"
}

inputs = {
  bucket = "dev1"
}