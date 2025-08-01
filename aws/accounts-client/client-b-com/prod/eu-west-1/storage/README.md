# Production Storage Module - Client B Prod Environment

This directory contains the Terragrunt configuration for deploying S3 buckets in the Client B production environment in the EU West 1 region.

## Overview

The production storage module deploys S3 buckets using the custom S3 module from `https://github.com/catherinevee/s3` with version pinning to ensure consistent deployments. This configuration is designed for production storage needs with enterprise-grade security, compliance, and long-term retention policies.

## Configuration

### Version Pinning

The module uses version pinning for the S3 module:
```hcl
source = "github.com/catherinevee/s3"
version = "1.0.0"
```

### Bucket Configuration

The module is configured to deploy six production buckets:

1. **client-b-prod-app-data**: Application data storage
   - Private access with encryption
   - 7-year retention with lifecycle policies
   - CORS enabled for web applications
   - Internal data classification with SOX compliance

2. **client-b-prod-logs**: Log storage
   - Log delivery write access
   - 7-year retention with lifecycle policies
   - Optimized for log storage patterns
   - Internal data classification with SOX compliance

3. **client-b-prod-backups**: Backup storage
   - Private access with encryption
   - 10-year retention with object lock
   - Multi-tier storage lifecycle
   - Confidential data classification with SOX compliance

4. **client-b-prod-static-website**: Static website hosting
   - Public read access for website hosting
   - Website configuration enabled
   - CORS enabled for web access
   - Public data classification

5. **client-b-prod-archives**: Archive storage
   - Private access with encryption
   - 10-year retention with object lock
   - Multi-tier storage lifecycle
   - Confidential data classification with SOX compliance

6. **client-b-prod-disaster-recovery**: Disaster recovery storage
   - Private access with encryption
   - 20-year retention with object lock
   - Multi-tier storage lifecycle
   - Confidential data classification with SOX compliance

## Production Environment Considerations

### Enterprise Security
- Encryption enabled on all buckets
- Public access blocked on sensitive buckets
- Object lock with compliance mode for critical data
- Production-specific CORS policies
- Proper data classification tagging

### Compliance and Governance
- SOX compliance features enabled
- Long-term retention policies
- Audit logging and monitoring
- Data lifecycle management
- Regulatory compliance tagging

### High Availability and Disaster Recovery
- Multi-tier storage lifecycle
- Cross-region replication ready
- Disaster recovery procedures
- Business continuity planning
- Critical data protection

## Prerequisites

Before running this module, ensure the following dependencies are available:

- AWS account with S3 permissions
- KMS key for encryption (if using KMS encryption)
- IAM roles and policies (if using cross-account access)
- VPC endpoints (if using private access)
- Compliance requirements documented

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/prod/eu-west-1/storage
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

- `bucket_ids`: List of S3 bucket IDs
- `bucket_arns`: List of S3 bucket ARNs
- `bucket_names`: List of S3 bucket names
- `bucket_regions`: List of S3 bucket regions
- `bucket_websites`: List of S3 bucket website endpoints
- `bucket_website_domains`: List of S3 bucket website domain names
- `buckets`: Map of all bucket attributes

## Security Considerations

- All buckets have encryption enabled
- Public access is blocked on sensitive buckets
- Object lock is enabled on compliance buckets
- Proper CORS policies for web applications
- Data classification tags for compliance

## Lifecycle Management

### Application Data
- 30 days: Move to STANDARD_IA
- 90 days: Move to GLACIER
- 365 days: Move to DEEP_ARCHIVE
- 2555 days: Delete objects
- 365 days: Delete noncurrent versions

### Logs
- 30 days: Move to STANDARD_IA
- 90 days: Move to GLACIER
- 365 days: Move to DEEP_ARCHIVE
- 2555 days: Delete objects
- 365 days: Delete noncurrent versions

### Backups
- 90 days: Move to STANDARD_IA
- 180 days: Move to GLACIER
- 365 days: Move to DEEP_ARCHIVE
- 3650 days: Delete objects
- 730 days: Delete noncurrent versions

### Archives
- 30 days: Move to STANDARD_IA
- 90 days: Move to GLACIER
- 365 days: Move to DEEP_ARCHIVE
- 3650 days: Delete objects
- 1095 days: Delete noncurrent versions

### Disaster Recovery
- 90 days: Move to STANDARD_IA
- 365 days: Move to GLACIER
- 1095 days: Move to DEEP_ARCHIVE
- 7300 days: Delete objects
- 1825 days: Delete noncurrent versions

## Monitoring and Alerting

### CloudWatch Metrics
- Bucket size metrics
- Object count metrics
- Request metrics
- Error rate monitoring
- Performance monitoring

### Access Logging
- All buckets have access logging enabled
- Logs stored in dedicated log bucket
- Log retention policies applied
- Security analysis and auditing
- Compliance reporting

## Tags

All resources are tagged with:
- Environment: prod
- Region: eu-west-1
- CostCenter: ClientB
- Project: Production Storage Infrastructure
- Purpose: application-data, logs, backups, static-website, archives, or disaster-recovery
- DataClassification: internal, confidential, or public
- BackupRequired: true or false
- Compliance: SOX (where applicable)
- RetentionPeriod: 7-years, 10-years, or 20-years
- Criticality: high (where applicable)

## Data Classification

### Internal
- Application data
- Logs
- Development artifacts

### Confidential
- Backups
- Archives
- Disaster recovery data
- Sensitive application data
- Compliance-related data

### Public
- Static website content
- Public documentation
- Marketing materials

## Compliance

### SOX Compliance
- Object lock enabled on compliance buckets
- Encryption at rest
- Access logging enabled
- Retention policies enforced
- Audit trail maintenance

### Data Protection
- Encryption in transit and at rest
- Access controls and policies
- Audit logging and monitoring
- Data lifecycle management
- Regulatory compliance

## Cost Management

### Storage Optimization
- Lifecycle policies for cost reduction
- Appropriate storage class selection
- Regular cost analysis and optimization
- Production-specific retention policies
- Cost allocation and tracking

### Monitoring
- Cost allocation tags
- Usage monitoring and alerts
- Regular cost reviews
- Optimization recommendations
- Budget management

## Disaster Recovery

### Backup Strategy
- Multi-tier backup approach
- Cross-region replication ready
- Point-in-time recovery
- Business continuity planning
- RTO/RPO objectives

### Recovery Procedures
- Automated recovery processes
- Manual recovery procedures
- Testing and validation
- Documentation and training
- Regular DR exercises

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