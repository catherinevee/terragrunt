# Terragrunt configuration for a complete AWS environment in eu-west-1

terraform {
  source = "../modules//vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project     = "catherinevee"
  environment = "prod"
  region      = "eu-west-1"
  costcenter  = "ITS"
  cidr_block  = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  instance_tenancy = "default"
  enable_network_address_usage_metrics = true
  tags = {
    Name        = "vpc-catherinevee-prod-eu-west-1"
    Environment = "prod"
    Project     = "catherinevee"
    ManagedBy   = "terragrunt"
    CostCenter  = "ITS"
    Terraform   = true
  }
  # Advanced VPC configuration for production
  dhcp_options = {
    domain_name         = "eu-west-1.compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]
    ntp_servers         = ["169.254.169.123"]
    netbios_name_servers = []
    netbios_node_type   = 2
    tags = {
      Name        = "dhcp-options-catherinevee-prod-eu-west-1"
      Environment = "prod"
      Project     = "catherinevee"
      ManagedBy   = "terragrunt"
    }
  }

  flow_logs = {
    enabled           = true
    log_destination   = "arn:aws:logs:eu-west-1:123456789012:log-group:/aws/vpc/flowlogs"
    traffic_type      = "ALL"
    max_aggregation_interval = 60
    tags = {
      Name        = "vpc-flowlogs-catherinevee-prod-eu-west-1"
      Environment = "prod"
      Project     = "catherinevee"
      ManagedBy   = "terragrunt"
    }
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
  assign_generated_ipv6_cidr_block = true
  enable_network_address_usage_metrics = true
  instance_tenancy = "default"

  # Custom VPC endpoints for S3 and DynamoDB
  vpc_endpoints = [
    {
      service_name = "com.amazonaws.eu-west-1.s3"
      vpc_endpoint_type = "Gateway"
      route_table_ids = ["rtb-12345678"] # Replace with actual route table IDs
      tags = {
        Name        = "s3-endpoint-catherinevee-prod-eu-west-1"
        Environment = "prod"
      }
    },
    {
      service_name = "com.amazonaws.eu-west-1.dynamodb"
      vpc_endpoint_type = "Gateway"
      route_table_ids = ["rtb-12345678"] # Replace with actual route table IDs
      tags = {
        Name        = "dynamodb-endpoint-catherinevee-prod-eu-west-1"
        Environment = "prod"
      }
    }
  ]

  # Additional tags for compliance and cost tracking
  tags = merge(
    {
      Name        = "vpc-catherinevee-prod-eu-west-1"
      Environment = "prod"
      Project     = "catherinevee"
      ManagedBy   = "terragrunt"
      CostCenter  = "ITS"
      Terraform   = true
      Compliance  = "PCI-DSS"
      Owner       = "network-team@catherinevee.com"
      Department  = "IT"
    },
    var.extra_tags != null ? var.extra_tags : {}
  )
}
