# Production Network Module - Client B Production Environment

This directory contains the Terragrunt configuration for deploying VPCs and networking infrastructure in the Client B production environment in the EU West 1 region.

## Overview

The production network module deploys VPCs using the custom VPC module from `https://github.com/catherinevee/vpc` with version pinning to ensure consistent deployments. This configuration is designed for production networking needs with enterprise-grade security, compliance, and high availability.

## Configuration

### Version Pinning

The module uses version pinning for the VPC module:
```hcl
source = "github.com/catherinevee/vpc"
version = "1.0.0"
```

### VPC Configuration

The module is configured to deploy three production VPCs:

1. **client-b-prod-main-vpc**: Main VPC for general workloads
   - CIDR Block: 10.2.0.0/16
   - Public, private, database, ElastiCache, Redshift, and intra subnets
   - NAT Gateways enabled (one per AZ)
   - Internet Gateway enabled
   - VPN Gateway enabled for secure connectivity
   - Comprehensive VPC endpoints for AWS services
   - Flow logs enabled for monitoring

2. **client-b-prod-isolated-vpc**: Isolated VPC for sensitive workloads
   - CIDR Block: 10.2.128.0/18
   - Private, database, ElastiCache, and intra subnets only
   - No public subnets or Internet Gateway
   - No NAT Gateways
   - Minimal VPC endpoints (S3 only)
   - Flow logs enabled for monitoring
   - High security level tagging

3. **client-b-prod-dmz-vpc**: DMZ VPC for public-facing services
   - CIDR Block: 10.2.192.0/20
   - Public and intra subnets only
   - Internet Gateway enabled
   - No NAT Gateways
   - Minimal VPC endpoints (S3 only)
   - Flow logs enabled for monitoring
   - DMZ security level tagging

## Production Environment Considerations

### Enterprise Security
- Multi-VPC architecture for workload isolation
- VPN Gateway for secure connectivity
- Comprehensive VPC endpoints for main VPC
- Flow logs enabled on all VPCs
- Proper network tiering and tagging

### Compliance and Governance
- SOX compliance features enabled
- Network segmentation for regulatory requirements
- Audit logging and monitoring
- Data protection and security controls
- Regulatory compliance tagging

### High Availability and Disaster Recovery
- Multi-AZ deployment across all VPCs
- Redundant NAT Gateways
- Cross-VPC connectivity options
- Business continuity planning
- Critical infrastructure protection

## Prerequisites

Before running this module, ensure the following dependencies are available:

- AWS account with VPC permissions
- IAM roles and policies for flow logs
- CloudWatch Logs for flow log storage
- KMS key for flow log encryption (if using KMS encryption)
- VPN connectivity requirements documented

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/prod/eu-west-1/network
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
- `vpn_gateway_id`: Map of VPC names to VPN Gateway IDs
- `vpc_endpoints`: Map of VPC names to VPC endpoint information
- `vpcs`: Map of all VPC attributes

## Network Architecture

### Main VPC (client-b-prod-main-vpc)

#### Subnet Layout
- **Public Subnets**: 10.2.1.0/24, 10.2.2.0/24, 10.2.3.0/24
- **Private Subnets**: 10.2.10.0/24, 10.2.20.0/24, 10.2.30.0/24
- **Database Subnets**: 10.2.100.0/24, 10.2.200.0/24, 10.2.300.0/24
- **ElastiCache Subnets**: 10.2.40.0/24, 10.2.41.0/24, 10.2.42.0/24
- **Redshift Subnets**: 10.2.50.0/24, 10.2.51.0/24, 10.2.52.0/24
- **Intra Subnets**: 10.2.60.0/24, 10.2.61.0/24, 10.2.62.0/24

#### Network Components
- **Internet Gateway**: Enabled for public internet access
- **NAT Gateways**: One per AZ for private subnet internet access
- **VPN Gateway**: Enabled for secure connectivity
- **VPC Endpoints**: Comprehensive set for AWS services
- **Flow Logs**: Enabled for network monitoring

### Isolated VPC (client-b-prod-isolated-vpc)

#### Subnet Layout
- **Private Subnets**: 10.2.128.0/26, 10.2.128.64/26, 10.2.128.128/26
- **Database Subnets**: 10.2.129.0/26, 10.2.129.64/26, 10.2.129.128/26
- **ElastiCache Subnets**: 10.2.130.0/26, 10.2.130.64/26, 10.2.130.128/26
- **Intra Subnets**: 10.2.131.0/26, 10.2.131.64/26, 10.2.131.128/26

#### Network Components
- **No Internet Gateway**: Completely isolated from internet
- **No NAT Gateways**: No outbound internet access
- **No VPN Gateway**: No external connectivity
- **Minimal VPC Endpoints**: S3 only for essential services
- **Flow Logs**: Enabled for security monitoring

### DMZ VPC (client-b-prod-dmz-vpc)

#### Subnet Layout
- **Public Subnets**: 10.2.192.0/26, 10.2.192.64/26, 10.2.192.128/26
- **Intra Subnets**: 10.2.193.0/26, 10.2.193.64/26, 10.2.193.128/26

#### Network Components
- **Internet Gateway**: Enabled for public internet access
- **No NAT Gateways**: Direct internet access
- **No VPN Gateway**: Public-facing services
- **Minimal VPC Endpoints**: S3 only for essential services
- **Flow Logs**: Enabled for security monitoring

## Security Considerations

### Network Security
- Flow logs enabled on all VPCs
- Isolated VPC for sensitive workloads
- DMZ VPC for public-facing services
- No public subnets in isolated VPC
- Proper subnet tiering and tagging

### VPC Endpoints
- Main VPC: Comprehensive endpoint coverage
- Isolated VPC: Minimal endpoints for security
- DMZ VPC: Minimal endpoints for security
- S3 endpoints enabled for all VPCs

### VPN Connectivity
- VPN Gateway enabled on main VPC
- Secure connectivity to on-premises networks
- Route propagation enabled
- Enterprise-grade security

### Monitoring and Logging
- CloudWatch Flow Logs enabled
- Network traffic monitoring
- Security analysis and auditing
- Compliance reporting

## High Availability

### Multi-AZ Deployment
- All subnets deployed across multiple AZs
- Redundant NAT Gateways
- High availability for critical services
- Disaster recovery capabilities

### Network Redundancy
- Multiple NAT Gateways for private subnets
- Redundant VPN connections
- Cross-AZ load balancing support
- Failover mechanisms

## Compliance

### SOX Compliance
- Network segmentation for data protection
- Flow logs for audit trails
- Access controls and policies
- Security group and NACL management
- Compliance tagging on all resources

### Data Protection
- Network isolation for sensitive data
- Encryption in transit and at rest
- Access controls and policies
- Audit logging and monitoring
- Regulatory compliance

## Cost Management

### Network Optimization
- Appropriate subnet sizing
- NAT Gateway optimization
- VPC endpoint selection
- Resource tagging for cost allocation
- Cost-effective architecture

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
- Compliance audits

### Monitoring and Alerting
- Proactive monitoring
- Automated alerting
- Escalation procedures
- Performance baselines
- SLA monitoring

## Disaster Recovery

### Network Recovery
- Multi-AZ redundancy
- Cross-region replication ready
- Backup and restore procedures
- Business continuity planning
- RTO/RPO objectives

### Recovery Procedures
- Automated recovery processes
- Manual recovery procedures
- Testing and validation
- Documentation and training
- Regular DR exercises 