include "root" {
  path = find_in_parent_folders("root.hcl")
}
include {
  path = find_in_parent_folders("common.tcl")
}

dependency "compute" {
  config_path = "../compute"
}

inputs = {
  s = dependency.compute.locals.instance_type
}