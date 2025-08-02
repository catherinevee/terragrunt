# Terragrunt config for subnets

terraform {
  source = "../modules//subnets"
}

# Example outputs for downstream modules
generate "outputs.tf" {
  path      = "outputs.tf"
  if_exists = "overwrite"
  contents  = <<EOF
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}
output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}
output "private_route_table_id" {
  value = aws_route_table.private.id
}
EOF
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id    = dependency.vpc.outputs.vpc_id
  subnets = [
    {
      name              = "public-subnet-1"
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-1a"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-subnet-1"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name              = "public-subnet-2"
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-1b"
      map_public_ip_on_launch = true
      tags = {
        Name        = "public-subnet-2"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name              = "private-subnet-1"
      cidr_block        = "10.0.101.0/24"
      availability_zone = "eu-west-1a"
      map_public_ip_on_launch = false
      tags = {
        Name        = "private-subnet-1"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    }
  ]
  # Example NAT gateway and route table variables
  nat_gateways = [
    {
      name        = "nat-gateway-1"
      subnet_name = "public-subnet-1"
      allocation_id = "eipalloc-12345678" # Replace with actual EIP allocation ID
      tags = {
        Name        = "nat-gateway-1"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    }
  ]
  route_tables = [
    {
      name = "public-rt"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          gateway_id = "igw-12345678" # Replace with actual IGW ID
        }
      ]
      subnet_names = ["public-subnet-1", "public-subnet-2"]
      tags = {
        Name        = "public-rt"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name = "private-rt"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
          nat_gateway_id = "nat-gateway-1" # Reference to NAT gateway above
        }
      ]
      subnet_names = ["private-subnet-1"]
      tags = {
        Name        = "private-rt"
        Environment = "dev"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    }
  ]
}
