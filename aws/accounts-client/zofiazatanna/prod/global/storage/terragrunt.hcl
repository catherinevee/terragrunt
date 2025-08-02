terraform {
 source = "tfr:///terraform-aws-modules/s3-bucket/aws//?version=4.1.2"   
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "common" {
  path= find_in_parent_folders("common.hcl")
}

dependencies {
    paths = ["../namer"]
}

inputs = {
    bucket = include.common.locals.storagename
}

