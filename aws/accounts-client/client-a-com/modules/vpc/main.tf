resource "aws_vpc" "vpc" {
  cidr_block                           = "10.0.0.0/16"
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true
  assign_generated_ipv6_cidr_block     = true
  
  tags = {
    Name = "vpc-${var.environment}-${var.region}-${random_string.suffix.id}"
    Environment  = var.environment
    Region        = var.region
    CostCenter   = var.costcenter
    Project      = var.project
  }
}

resource "random_string" "suffix" {
    length = 8
    special = false
    upper = false
}