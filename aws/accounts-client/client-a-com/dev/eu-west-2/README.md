# Client A - Development Environment (eu-west-2)

## Overview

This directory contains the complete Terragrunt configuration for Client A's development environment in the `eu-west-2` region. The infrastructure is designed to provide a scalable, secure, and cost-effective development platform.

## Architecture

### Network Architecture
- **VPC**: `10.1.0.0/16` with multi-tier subnet design
- **Public Subnets**: `10.1.1.0/24`, `10.1.2.0/24`, `10.1.3.0/24` (for ALB and bastion hosts)
- **Private Subnets**: `10.1.10.0/24`, `10.1.11.0/24`, `10.1.12.0/24` (for application servers)
- **Database Subnets**: `10.1.20.0/24`, `10.1.21.0/24`, `10.1.22.0/24` (for RDS instances)
- **ElastiCache Subnets**: `10.1.30.0/24`, `10.1.31.0/24`, `10.1.32.0/24` (for cache clusters)

### Security Architecture
- **Security Groups**: Tiered security groups for web, application, database, and cache layers
- **KMS Encryption**: Service-specific encryption keys for data at rest
- **IAM**: Role-based access control with least privilege principles
- **Network Security**: VPC endpoints for secure AWS service access

### Application Architecture
- **Load Balancer**: Application Load Balancer for traffic distribution
- **Compute**: EC2 instances with Auto Scaling Groups
- **Database**: RDS MySQL and PostgreSQL instances
- **Cache**: ElastiCache Redis and Memcached clusters
- **Monitoring**: Comprehensive CloudWatch monitoring and alerting

## Infrastructure Components

### 1. VPC (`vpc/`)
- **Purpose**: Network foundation with multi-tier subnet design
- **Features**: 
  - Internet Gateway for public access
  - NAT Gateway for private subnet internet access
  - VPC Endpoints for secure AWS service access
  - Route tables for traffic routing
- **Dependencies**: None (foundational)

### 2. KMS (`kms/`)
- **Purpose**: Encryption key management
- **Features**:
  - Service-specific encryption keys (S3, RDS, ElastiCache, CloudWatch)
  - Key rotation enabled
  - 7-day deletion window for development
- **Dependencies**: None

### 3. SNS (`sns/`)
- **Purpose**: Notification and alerting system
- **Features**:
  - Multiple topics (alerts, monitoring, budget, security)
  - Email subscriptions for different teams
  - Filter policies for targeted notifications
- **Dependencies**: None

### 4. Security Groups (`security-groups/`)
- **Purpose**: Network security and access control
- **Features**:
  - Tiered security groups (web, app, database, cache, ALB)
  - Least privilege access rules
  - VPC CIDR-based restrictions
- **Dependencies**: VPC

### 5. IAM (`iam/`)
- **Purpose**: Identity and access management
- **Features**:
  - Users, groups, and roles
  - Service-specific roles (EC2, Lambda, RDS)
  - Custom policies for developers and DevOps
- **Dependencies**: None

### 6. RDS (`rds/`)
- **Purpose**: Managed database services
- **Features**:
  - MySQL and PostgreSQL instances
  - KMS encryption
  - Performance Insights
  - Automated backups (7-day retention)
- **Dependencies**: VPC, KMS, Security Groups

### 7. ElastiCache (`elasticache/`)
- **Purpose**: Managed caching services
- **Features**:
  - Redis and Memcached clusters
  - KMS encryption
  - Multi-AZ disabled for cost optimization
- **Dependencies**: VPC, KMS, Security Groups

### 8. ALB (`alb/`)
- **Purpose**: Application load balancing
- **Features**:
  - Internet-facing load balancer
  - Target groups for web and application tiers
  - HTTP and HTTPS listeners
  - Access logging
- **Dependencies**: VPC, Security Groups

### 9. Monitoring (`monitoring/`)
- **Purpose**: Observability and alerting
- **Features**:
  - CloudWatch log groups
  - Performance and availability alarms
  - VPC Flow Logs
  - Custom dashboard
- **Dependencies**: VPC, SNS, Security Groups

## Deployment Order

The modules should be deployed in the following order due to dependencies:

1. **VPC** - Network foundation
2. **KMS** - Encryption keys
3. **SNS** - Notification system
4. **Security Groups** - Network security (depends on VPC)
5. **IAM** - Access management
6. **RDS** - Database services (depends on VPC, KMS, Security Groups)
7. **ElastiCache** - Cache services (depends on VPC, KMS, Security Groups)
8. **ALB** - Load balancing (depends on VPC, Security Groups)
9. **Monitoring** - Observability (depends on VPC, SNS, Security Groups)

## Configuration

### Environment-Specific Settings
- **Instance Types**: `t3.micro` for cost optimization
- **Backup Retention**: 7 days for development
- **Deletion Protection**: Disabled for development
- **Multi-AZ**: Disabled for cost optimization
- **Monitoring**: Basic monitoring enabled

### Cost Optimization
- Single NAT Gateway for all private subnets
- Small instance types (`t3.micro`)
- Disabled Multi-AZ for non-critical services
- 7-day backup retention
- Disabled deletion protection

### Security Features
- KMS encryption for all data at rest
- Security groups with least privilege access
- IAM roles with minimal required permissions
- VPC endpoints for secure AWS service access
- VPC Flow Logs for network monitoring

## Usage

### Prerequisites
- Terragrunt installed and configured
- AWS credentials configured
- Access to the required AWS services

### Deployment Commands

```bash
# Deploy all modules in order
terragrunt run-all apply

# Deploy specific module
terragrunt apply --terragrunt-working-dir vpc/

# Plan changes
terragrunt run-all plan

# Destroy specific module
terragrunt destroy --terragrunt-working-dir vpc/

# Destroy all modules (in reverse order)
terragrunt run-all destroy
```

### Module-Specific Commands

```bash
# Deploy VPC foundation
cd vpc/
terragrunt apply

# Deploy security infrastructure
cd ../kms/
terragrunt apply
cd ../sns/
terragrunt apply
cd ../security-groups/
terragrunt apply

# Deploy application infrastructure
cd ../rds/
terragrunt apply
cd ../elasticache/
terragrunt apply
cd ../alb/
terragrunt apply

# Deploy monitoring
cd ../monitoring/
terragrunt apply
```

## Monitoring and Alerting

### CloudWatch Dashboard
- CPU and memory utilization
- ALB request count and response time
- RDS and ElastiCache metrics
- Custom metrics for application performance

### Alarms
- **CPU Utilization**: >80% for 2 evaluation periods
- **Memory Utilization**: >85% for 2 evaluation periods
- **Disk Utilization**: >90% for 2 evaluation periods
- **ALB Response Time**: >5 seconds for 2 evaluation periods
- **RDS Connections**: >80% of max connections

### SNS Topics
- **Alerts**: Critical and high-severity notifications
- **Monitoring**: General monitoring notifications
- **Budget**: Cost and budget alerts
- **Security**: Security-related notifications

## Troubleshooting

### Common Issues

1. **Dependency Errors**
   - Ensure modules are deployed in the correct order
   - Check that all required outputs are available

2. **Permission Errors**
   - Verify IAM roles and policies are correctly configured
   - Check that the AWS credentials have sufficient permissions

3. **Network Connectivity Issues**
   - Verify security group rules allow required traffic
   - Check that VPC endpoints are correctly configured
   - Ensure route tables are properly configured

4. **Resource Limits**
   - Check AWS service limits for the account
   - Request limit increases if necessary

### Debugging Commands

```bash
# Check Terragrunt configuration
terragrunt validate-inputs

# Show module dependencies
terragrunt graph

# Check AWS resource state
terragrunt state list

# Import existing resources
terragrunt import aws_vpc.main vpc-12345678
```

## Maintenance

### Regular Tasks
- Monitor CloudWatch alarms and logs
- Review and update security group rules
- Rotate KMS keys as needed
- Update Terraform modules to latest versions
- Review and optimize costs

### Backup and Recovery
- RDS automated backups (7-day retention)
- Manual snapshots for critical data
- Terraform state backup and versioning
- Configuration documentation updates

## Security Considerations

### Data Protection
- All data encrypted at rest using KMS
- Data in transit encrypted using TLS
- VPC isolation for network security
- IAM least privilege access control

### Compliance
- GDPR compliance for EU data residency
- ISO27001 security standards
- Regular security audits and reviews
- Access logging and monitoring

### Best Practices
- Use IAM roles instead of access keys
- Regularly rotate credentials
- Monitor and alert on security events
- Keep Terraform modules updated
- Document all changes and configurations

## Support

For issues or questions regarding this infrastructure:
- Check the troubleshooting section above
- Review CloudWatch logs and alarms
- Contact the DevOps team
- Refer to AWS documentation for service-specific issues

## Version History

- **v1.0.0**: Initial implementation of complete development environment
- All modules sourced from `https://github.com/catherinevee`
- Version-pinned modules for stability
- Comprehensive monitoring and alerting
- Cost-optimized for development environment 