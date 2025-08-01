# Production Compute Module - Client B Prod Environment

This directory contains the Terragrunt configuration for deploying EC2 instances in the Client B production environment in the EU West 1 region.

## Overview

The production compute module deploys EC2 instances using the custom EC2 module from `https://github.com/catherinevee/ec2` with version pinning to ensure consistent deployments. This configuration is designed for production workloads with high availability and performance requirements.

## Configuration

### Version Pinning

The module uses version pinning for the EC2 module:
```hcl
source = "github.com/catherinevee/ec2"
version = "1.0.0"
```

### Instance Configuration

The module is configured to deploy five production instances:

1. **web-server-prod-1 & web-server-prod-2**: t3.medium instances for web services
   - Public IP enabled
   - Frontend tier
   - Located in public subnets
   - High availability setup

2. **app-server-prod-1 & app-server-prod-2**: t3.large instances for application services
   - Private IP only
   - Backend tier
   - Located in private subnets
   - High availability setup

3. **db-server-prod-1**: t3.xlarge instance for database services
   - Private IP only
   - Database tier
   - Located in database subnet
   - Enhanced monitoring enabled

## Production Considerations

### High Availability
- Multiple instances per tier for redundancy
- Instances distributed across different subnets
- Load balancer ready configuration

### Security
- Production-specific security groups
- Private subnets for sensitive workloads
- Dedicated production SSH key pair
- Enhanced monitoring and logging

### Performance
- Larger instance types for production workloads
- Optimized for production traffic patterns
- CloudWatch monitoring for performance tracking

## Prerequisites

Before running this module, ensure the following dependencies are available:

- VPC and subnets (configured in `../vpc`)
- Security groups (configured in `../security-groups`)
- SSH key pair named `client-b-prod-key`
- Load balancer configuration (if required)
- Database subnet group (for database instance)

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/prod/eu-west-1/compute
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

dependency "load_balancer" {
  config_path = "../load-balancer"
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
- Production security groups with strict access controls
- SSH key pairs managed securely
- Private subnets for sensitive workloads
- Enhanced monitoring and alerting

## Monitoring

Instances are configured with CloudWatch agent for:
- System metrics (CPU, memory, disk)
- Log collection and analysis
- Custom application metrics
- Performance monitoring
- Alerting and notifications

## Backup and Recovery

- EBS snapshots configured for data protection
- Cross-region backup strategy
- Disaster recovery procedures
- Automated backup scheduling

## Tags

All resources are tagged with:
- Environment: prod
- Region: eu-west-1
- CostCenter: ClientB
- Project: Production Compute Infrastructure
- Role: web-server, app-server, or database-server
- Tier: frontend, backend, or database
- Environment: production

## Maintenance

### Scaling
- Use Auto Scaling Groups for dynamic scaling
- Monitor performance metrics
- Adjust instance types based on workload

### Updates
- Use blue-green deployment for zero-downtime updates
- Test changes in staging environment first
- Maintain backup and rollback procedures

### Monitoring
- Set up CloudWatch alarms for critical metrics
- Configure SNS notifications for alerts
- Regular performance reviews and optimization 