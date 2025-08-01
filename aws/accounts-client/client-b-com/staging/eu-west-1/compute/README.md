# Staging Compute Module - Client B Staging Environment

This directory contains the Terragrunt configuration for deploying EC2 instances in the Client B staging environment in the EU West 1 region.

## Overview

The staging compute module deploys EC2 instances using the custom EC2 module from `https://github.com/catherinevee/ec2` with version pinning to ensure consistent deployments. This configuration is designed for staging workloads that mirror production but with reduced resource requirements for testing and validation.

## Configuration

### Version Pinning

The module uses version pinning for the EC2 module:
```hcl
source = "github.com/catherinevee/ec2"
version = "1.0.0"
```

### Instance Configuration

The module is configured to deploy five staging instances:

1. **web-server-staging-1 & web-server-staging-2**: t3.small instances for web services
   - Public IP enabled
   - Frontend tier
   - Located in public subnets
   - Staging-appropriate sizing

2. **app-server-staging-1 & app-server-staging-2**: t3.medium instances for application services
   - Private IP only
   - Backend tier
   - Located in private subnets
   - Staging-appropriate sizing

3. **db-server-staging-1**: t3.large instance for database services
   - Private IP only
   - Database tier
   - Located in database subnet
   - Staging-appropriate sizing

## Staging Environment Considerations

### Testing and Validation
- Mirrors production architecture with reduced resources
- Suitable for integration testing and user acceptance testing
- Supports pre-production deployment validation
- Enables performance testing with realistic data

### Cost Optimization
- Smaller instance types compared to production
- Reduced resource allocation for cost efficiency
- Suitable for temporary testing workloads
- Can be scaled up for specific testing scenarios

### Security
- Staging-specific security groups
- Private subnets for sensitive workloads
- Dedicated staging SSH key pair
- Monitoring and logging for testing validation

## Prerequisites

Before running this module, ensure the following dependencies are available:

- VPC and subnets (configured in `../vpc`)
- Security groups (configured in `../security-groups`)
- SSH key pair named `client-b-staging-key`
- Load balancer configuration (if required)
- Database subnet group (for database instance)

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/staging/eu-west-1/compute
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
- Staging security groups with appropriate access controls
- SSH key pairs managed securely
- Private subnets for sensitive workloads
- Monitoring and alerting for testing validation

## Monitoring

Instances are configured with CloudWatch agent for:
- System metrics (CPU, memory, disk)
- Log collection and analysis
- Custom application metrics
- Performance monitoring for testing
- Alerting and notifications

## Testing and Validation

### Integration Testing
- Full application stack deployment
- End-to-end workflow testing
- API integration validation
- Database connectivity testing

### Performance Testing
- Load testing capabilities
- Performance baseline establishment
- Scalability testing
- Resource utilization monitoring

### User Acceptance Testing
- User interface testing
- Business process validation
- Feature functionality testing
- Cross-browser compatibility testing

## Tags

All resources are tagged with:
- Environment: staging
- Region: eu-west-1
- CostCenter: ClientB
- Project: Staging Compute Infrastructure
- Role: web-server, app-server, or database-server
- Tier: frontend, backend, or database
- Environment: staging

## Maintenance

### Testing Cycles
- Regular deployment testing
- Automated testing integration
- Performance regression testing
- Security vulnerability testing

### Data Management
- Test data provisioning
- Data refresh procedures
- Backup and restore testing
- Data cleanup processes

### Environment Refresh
- Periodic environment rebuilds
- Configuration drift detection
- Security patch testing
- Performance optimization testing

## Deployment Pipeline

### Pre-deployment
- Code review and approval
- Automated testing in CI/CD
- Security scanning
- Performance baseline checks

### Deployment
- Blue-green deployment strategy
- Zero-downtime deployments
- Rollback procedures
- Health check validation

### Post-deployment
- Smoke testing
- Integration testing
- Performance monitoring
- User acceptance testing 