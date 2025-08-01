# Compute Module - Client B Dev Environment

This directory contains the Terragrunt configuration for deploying EC2 instances in the Client B development environment in the EU West 1 region.

## Overview

The compute module deploys EC2 instances using the custom EC2 module from `https://github.com/catherinevee/ec2` with version pinning to ensure consistent deployments.

## Configuration

### Version Pinning

The module uses version pinning for the EC2 module:
```hcl
source = "github.com/catherinevee/ec2"
version = "1.0.0"
```

### Instance Configuration

The module is configured to deploy two instances:

1. **web-server-1**: A t3.micro instance for web services
   - Public IP enabled
   - Frontend tier
   - Located in public subnet

2. **app-server-1**: A t3.small instance for application services
   - Private IP only
   - Backend tier
   - Located in private subnet

## Prerequisites

Before running this module, ensure the following dependencies are available:

- VPC and subnets (configured in `../vpc`)
- Security groups (configured in `../security-groups`)
- SSH key pair named `client-b-key`

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/dev/eu-west-1/compute
terragrunt plan
terragrunt apply
```

### Destroy the infrastructure

```bash
terragrunt destroy
```

## Dependencies

Uncomment and configure the following dependencies in `terragrunt.hcl` as needed:

```hcl
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}
```

## Outputs

The module provides the following outputs:

- `instance_ids`: List of EC2 instance IDs
- `instance_private_ips`: List of private IP addresses
- `instance_public_ips`: List of public IP addresses
- `instance_arns`: List of instance ARNs
- `instances`: Map of all instance attributes

## Security Considerations

- Instances are configured with CloudWatch monitoring
- User data script creates a dedicated application user
- Security groups should be configured to restrict access
- SSH key pairs should be managed securely

## Monitoring

Instances are configured with CloudWatch agent for:
- System metrics (CPU, memory, disk)
- Log collection
- Custom application metrics

## Tags

All resources are tagged with:
- Environment: dev
- Region: eu-west-1
- CostCenter: ClientB
- Project: Compute Infrastructure
- Role: web-server or app-server
- Tier: frontend or backend 