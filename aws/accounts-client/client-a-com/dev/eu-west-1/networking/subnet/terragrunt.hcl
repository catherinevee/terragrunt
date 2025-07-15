include "root" {
  path = find_in_parent_folders("root.hcl")
}
include {
  path = find_in_parent_folders("common.tcl")
}

dependency "vpc" {
    config_path = "../vpc"
}

