terraform {
  source = "tfr:///cloudposse/label/null/latest/?version=0.25.0"
}

inputs = {
  namespace = "sdfs"
  stage = "prod"
  name = ""
  attributes = [""]
  delimiter = "-"
  tags = {
    "CostCenter" = "IT",
    "Project" = "catstar"
  }
}