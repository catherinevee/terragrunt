# Staging Network Module - Client B Staging Environment

This directory contains the Terragrunt configuration for deploying VPCs and networking infrastructure in the Client B staging environment in the EU West 1 region.

## Overview

The staging network module deploys VPCs using the custom VPC module from `https://github.com/catherinevee/vpc` with version pinning to ensure consistent deployments. This configuration is designed for staging networking needs with appropriate security, isolation, and testing capabilities.

## Configuration

### Version Pinning

The module uses version pinning for the VPC module:
```hcl
source = "github.com/catherinevee/vpc"
version = "1.0.0"
```

### VPC Configuration

The module is configured to deploy two staging VPCs:

1. **client-b-staging-main-vpc**: Main VPC for general workloads
   - CIDR Block: 10.3.0.0/16
   - Public, private, database, ElastiCache, Redshift, and intra subnets
   - NAT Gateways enabled (one per AZ)
   - Internet Gateway enabled
   - Comprehensive VPC endpoints for AWS services
   - Flow logs enabled for monitoring

2. **client-b-staging-isolated-vpc**: Isolated VPC for sensitive workloads
   - CIDR Block: 10.3.128.0/18
   - Private, database, ElastiCache, and intra subnets only
   - No public subnets or Internet Gateway
   - No NAT Gateways
   - Minimal VPC endpoints (S3 only)
   - Flow logs enabled for monitoring
   - High security level tagging

## Staging Environment Considerations

### Testing and Validation
- Mirrors production architecture with appropriate security levels
- Suitable for integration testing and user acceptance testing
- Supports pre-production deployment validation
- Enables network connectivity testing

### Network Design
- Multi-VPC architecture for workload isolation
- Staging-specific CIDR ranges (10.3.x.x)
- Appropriate subnet sizing for staging workloads
- Staging-specific security policies

### Security
- Flow logs enabled on all VPCs
- Isolated VPC for sensitive workloads
- Comprehensive VPC endpoints for main VPC
- Proper network tier tagging

## Prerequisites

Before running this module, ensure the following dependencies are available:

- AWS account with VPC permissions
- IAM roles and policies for flow logs
- CloudWatch Logs for flow log storage
- KMS key for flow log encryption (if using KMS encryption)

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/staging/eu-west-1/network
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
dependency "kms" {
  config_path = "../kms"
}

dependency "iam" {
  config_path = "../iam"
}
```

## Outputs

The module provides the following outputs:

- `vpc_ids`: List of VPC IDs
- `vpc_arns`: List of VPC ARNs
- `vpc_cidr_blocks`: List of VPC CIDR blocks
- `vpc_names`: List of VPC names
- `public_subnet_ids`: Map of VPC names to public subnet IDs
- `private_subnet_ids`: Map of VPC names to private subnet IDs
- `database_subnet_ids`: Map of VPC names to database subnet IDs
- `elasticache_subnet_ids`: Map of VPC names to ElastiCache subnet IDs
- `redshift_subnet_ids`: Map of VPC names to Redshift subnet IDs
- `intra_subnet_ids`: Map of VPC names to intra subnet IDs
- `nat_gateway_ids`: Map of VPC names to NAT Gateway IDs
- `internet_gateway_id`: Map of VPC names to Internet Gateway IDs
- `vpc_endpoints`: Map of VPC names to VPC endpoint information
- `vpcs`: Map of all VPC attributes

## Network Architecture

### Main VPC (client-b-staging-main-vpc)

#### Subnet Layout
- **Public Subnets**: 10.3.1.0/24, 10.3.2.0/24, 10.3.3.0/24
- **Private Subnets**: 10.3.10.0/24, 10.3.20.0/24, 10.3.30.0/24
- **Database Subnets**: 10.3.100.0/24, 10.3.200.0/24, 10.3.300.0/24
- **ElastiCache Subnets**: 10.3.40.0/24, 10.3.41.0/24, 10.3.42.0/24
- **Redshift Subnets**: 10.3.50.0/24, 10.3.51.0/24, 10.3.52.0/24
- **Intra Subnets**: 10.3.60.0/24, 10.3.61.0/24, 10.3.62.0/24

#### Network Components
- **Internet Gateway**: Enabled for public internet access
- **NAT Gateways**: One per AZ for private subnet internet access
- **VPC Endpoints**: Comprehensive set for AWS services
- **Flow Logs**: Enabled for network monitoring

### Isolated VPC (client-b-staging-isolated-vpc)

#### Subnet Layout
- **Private Subnets**: 10.3.128.0/26, 10.3.128.64/26, 10.3.128.128/26
- **Database Subnets**: 10.3.129.0/26, 10.3.129.64/26, 10.3.129.128/26
- **ElastiCache Subnets**: 10.3.130.0/26, 10.3.130.64/26, 10.3.130.128/26
- **Intra Subnets**: 10.3.131.0/26, 10.3.131.64/26, 10.3.131.128/26

#### Network Components
- **No Internet Gateway**: Completely isolated from internet
- **No NAT Gateways**: No outbound internet access
- **Minimal VPC Endpoints**: S3 only for essential services
- **Flow Logs**: Enabled for security monitoring

## Security Considerations

### Network Security
- Flow logs enabled on all VPCs
- Isolated VPC for sensitive workloads
- No public subnets in isolated VPC
- Proper subnet tiering and tagging

### VPC Endpoints
- Main VPC: Comprehensive endpoint coverage
- Isolated VPC: Minimal endpoints for security
- S3 endpoints enabled for both VPCs

### Monitoring and Logging
- CloudWatch Flow Logs enabled
- Network traffic monitoring
- Security analysis and auditing
- Compliance reporting

## Testing and Validation

### Network Connectivity Testing
- Inter-VPC connectivity validation
- Subnet routing verification
- VPC endpoint connectivity testing
- NAT Gateway functionality testing

### Security Testing
- Network isolation verification
- Flow log validation
- Security group testing
- Network ACL validation

### Performance Testing
- Network throughput testing
- Latency measurement
- Bandwidth utilization monitoring
- Resource scaling validation

## Monitoring

### CloudWatch Metrics
- VPC metrics
- Subnet metrics
- NAT Gateway metrics
- VPC endpoint metrics

### Flow Logs
- All VPCs have flow logs enabled
- Logs stored in CloudWatch Logs
- Network traffic analysis
- Security monitoring and alerting

## Tags

All resources are tagged with:
- Environment: staging
- Region: eu-west-1
- CostCenter: ClientB
- Project: Staging Network Infrastructure
- Purpose: main-vpc or isolated-vpc
- NetworkTier: main, isolated, public, private, database, elasticache, redshift, or intra
- AutoAssignPublicIp: true or false
- SecurityLevel: high (for isolated VPC)
- BackupRequired: true

## Network Tiers

### Main Tier
- General application workloads
- Public internet access
- Standard security requirements
- Comprehensive AWS service access

### Isolated Tier
- Sensitive workloads
- No internet access
- High security requirements
- Minimal AWS service access

## Compliance

### Network Security
- Flow logs for audit trails
- Network isolation for sensitive data
- Proper subnet tiering
- Security group and NACL management

### Data Protection
- Network segmentation
- Access controls and policies
- Audit logging and monitoring
- Network security best practices

## Cost Management

### Network Optimization
- Appropriate subnet sizing
- NAT Gateway optimization
- VPC endpoint selection
- Resource tagging for cost allocation

### Monitoring
- Cost allocation tags
- Usage monitoring and alerts
- Regular cost reviews
- Optimization recommendations

## Maintenance

### Regular Maintenance
- Security patch management
- Performance optimization
- Capacity planning
- Cost optimization

### Monitoring and Alerting
- Proactive monitoring
- Automated alerting
- Escalation procedures
- Performance baselines 