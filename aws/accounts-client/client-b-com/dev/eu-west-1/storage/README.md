# Storage Module - Client B Dev Environment

This directory contains the Terragrunt configuration for deploying S3 buckets in the Client B development environment in the EU West 1 region.

## Overview

The storage module deploys S3 buckets using the custom S3 module from `https://github.com/catherinevee/s3` with version pinning to ensure consistent deployments. This configuration is designed for development storage needs with appropriate security and lifecycle policies.

## Configuration

### Version Pinning

The module uses version pinning for the S3 module:
```hcl
source = "github.com/catherinevee/s3"
version = "1.0.0"
```

### Bucket Configuration

The module is configured to deploy four development buckets:

1. **client-b-dev-app-data**: Application data storage
   - Private access with encryption
   - 90-day retention with lifecycle policies
   - CORS enabled for web applications
   - Internal data classification

2. **client-b-dev-logs**: Log storage
   - Log delivery write access
   - 1-year retention with lifecycle policies
   - Optimized for log storage patterns
   - Internal data classification

3. **client-b-dev-backups**: Backup storage
   - Private access with encryption
   - 2-year retention with object lock
   - Multi-tier storage lifecycle
   - Confidential data classification

4. **client-b-dev-static-website**: Static website hosting
   - Public read access for website hosting
   - Website configuration enabled
   - CORS enabled for web access
   - Public data classification

## Development Environment Considerations

### Data Management
- Appropriate retention periods for development data
- Cost-effective storage tiering
- Development-specific access patterns
- Temporary data lifecycle management

### Security
- Encryption enabled on all buckets
- Public access blocked where appropriate
- Development-specific CORS policies
- Proper data classification tagging

### Cost Optimization
- Lifecycle policies to move data to cheaper storage tiers
- Development-appropriate retention periods
- Efficient storage class transitions
- Cost monitoring and optimization

## Prerequisites

Before running this module, ensure the following dependencies are available:

- AWS account with S3 permissions
- KMS key for encryption (if using KMS encryption)
- IAM roles and policies (if using cross-account access)
- VPC endpoints (if using private access)

## Usage

### Deploy the infrastructure

```bash
cd terragrunt/aws/accounts-client/client-b-com/dev/eu-west-1/storage
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
- Object lock is enabled on backup buckets
- Proper CORS policies for web applications
- Data classification tags for compliance

## Lifecycle Management

### Application Data
- 30 days: Move to STANDARD_IA
- 60 days: Move to GLACIER
- 90 days: Delete objects
- 30 days: Delete noncurrent versions

### Logs
- 30 days: Move to STANDARD_IA
- 90 days: Move to GLACIER
- 365 days: Delete objects
- 90 days: Delete noncurrent versions

### Backups
- 90 days: Move to STANDARD_IA
- 180 days: Move to GLACIER
- 365 days: Move to DEEP_ARCHIVE
- 730 days: Delete objects
- 180 days: Delete noncurrent versions

## Monitoring

### CloudWatch Metrics
- Bucket size metrics
- Object count metrics
- Request metrics
- Error rate monitoring

### Access Logging
- All buckets have access logging enabled
- Logs stored in dedicated log bucket
- Log retention policies applied
- Security analysis and auditing

## Tags

All resources are tagged with:
- Environment: dev
- Region: eu-west-1
- CostCenter: ClientB
- Project: Development Storage Infrastructure
- Purpose: application-data, logs, backups, or static-website
- DataClassification: internal, confidential, or public
- BackupRequired: true or false
- Compliance: SOX (where applicable)

## Data Classification

### Internal
- Application data
- Logs
- Development artifacts

### Confidential
- Backups
- Sensitive application data
- Compliance-related data

### Public
- Static website content
- Public documentation
- Marketing materials

## Compliance

### SOX Compliance
- Object lock enabled on backup buckets
- Encryption at rest
- Access logging enabled
- Retention policies enforced

### Data Protection
- Encryption in transit and at rest
- Access controls and policies
- Audit logging and monitoring
- Data lifecycle management

## Cost Management

### Storage Optimization
- Lifecycle policies for cost reduction
- Appropriate storage class selection
- Regular cost analysis and optimization
- Development-specific retention policies

### Monitoring
- Cost allocation tags
- Usage monitoring and alerts
- Regular cost reviews
- Optimization recommendations 