locals {
  aws_region = "eu-west-1"
  
  # Region-specific configurations
  region_config = {
    name = "eu-west-1"
    availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  }
} 