include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "common" {
  path= find_in_parent_folders("common.hcl")
}

dependency "storage" {
  config_path = "../storage"  
}


dependency "s3" {
  config_path = "../storage"  
}

dependency "namer" {
  config_path = "../namer"  
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//?version=5.8.1"

  extra_arguments "customvars" {
    commands = [
      "plan"
    ]

    arguments = [
      "-var-file=${get_terragrunt_dir()}/aws/client-a-com/prod/common.tfvars"
    ]
  }

}



locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

inputs = {
   environment = local.common_vars.inputs.environment
   path = path_relative_to_include
   s = dependency.compute.locals.instance_type

}

