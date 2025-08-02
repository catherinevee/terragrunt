# Client A - Staging Environment (eu-west-2)

## Overview

This directory contains the complete Terragrunt configuration for Client A's **staging environment** in the `eu-west-2` region. The infrastructure is designed to provide a production-like environment for testing, validation, and pre-production deployments with balanced security and cost considerations.

## Staging-Specific Architecture

### Network Architecture
- **VPC**: `10.2.0.0/16` with multi-tier subnet design
- **Public Subnets**: `10.2.1.0/24`, `10.2.2.0/24`, `10.2.3.0/24` (for ALB and bastion hosts)
- **Private Subnets**: `10.2.10.0/24`, `10.2.11.0/24`, `10.2.12.0/24` (for application servers)
- **Database Subnets**: `10.2.20.0/24`, `10.2.21.0/24`, `10.2.22.0/24` (for RDS instances)
- **ElastiCache Subnets**: `10.2.30.0/24`, `10.2.31.0/24`, `10.2.32.0/24` (for cache clusters)

### Staging Security Architecture
- **Security Groups**: Tiered security groups with moderate access controls
- **KMS Encryption**: Service-specific encryption keys with 14-day deletion windows
- **IAM**: Role-based access control with balanced security policies
- **Network Security**: VPC endpoints, VPN Gateway, and comprehensive monitoring
- **Compliance**: SOC2, ISO27001, and GDPR compliance

### Staging Application Architecture
- **Load Balancer**: Application Load Balancer with SSL/TLS termination
- **Compute**: EC2 instances with Auto Scaling Groups and moderate availability
- **Database**: RDS Multi-AZ instances for reliability
- **Cache**: ElastiCache Multi-AZ clusters with automatic failover
- **Monitoring**: Comprehensive CloudWatch monitoring and alerting

## Staging Infrastructure Components

### 1. VPC (`vpc/`)
- **Purpose**: Production-like network foundation
- **Staging Features**: 
  - Multiple NAT Gateways for reliability
  - VPN Gateway for secure remote access
  - Comprehensive VPC endpoints for AWS services
  - Enhanced security and compliance tagging
- **Dependencies**: None (foundational)

### 2. KMS (`kms/`)
- **Purpose**: Balanced encryption key management
- **Staging Features**:
  - 14-day deletion windows for moderate security
  - Enhanced key policies with balanced access controls
  - Service-specific encryption keys
  - SOC2 compliance configurations
- **Dependencies**: None

### 3. SNS (`sns/`)
- **Purpose**: Comprehensive notification and alerting system
- **Staging Features**:
  - High and medium priority topics
  - Enhanced filtering and routing
  - Security and compliance topics
  - Team-specific notifications
- **Dependencies**: None

### 4. Security Groups (`security-groups/`)
- **Purpose**: Balanced network security and access control
- **Staging Features**:
  - Moderate least privilege access rules
  - Enhanced security group configurations
  - Compliance-focused access controls
  - Comprehensive logging and monitoring
- **Dependencies**: VPC

### 5. IAM (`iam/`)
- **Purpose**: Balanced identity and access management
- **Staging Features**:
  - Enhanced security policies and roles
  - Compliance-focused access controls
  - Staging-specific roles
  - Enhanced audit and monitoring
- **Dependencies**: None

### 6. RDS (`rds/`)
- **Purpose**: Reliable managed database services
- **Staging Features**:
  - Multi-AZ deployments for reliability
  - Enhanced monitoring and Performance Insights
  - 14-day backup retention
  - Deletion protection enabled
- **Dependencies**: VPC, KMS, Security Groups

### 7. ElastiCache (`elasticache/`)
- **Purpose**: Reliable managed caching services
- **Staging Features**:
  - Multi-AZ clusters with automatic failover
  - Enhanced monitoring and alerting
  - Staging-grade instance types
  - Comprehensive backup and recovery
- **Dependencies**: VPC, KMS, Security Groups

### 8. ALB (`alb/`)
- **Purpose**: Reliable application load balancing
- **Staging Features**:
  - SSL/TLS termination with ACM certificates
  - Enhanced security configurations
  - Comprehensive access logging
  - Staging-grade health checks
- **Dependencies**: VPC, Security Groups

### 9. Monitoring (`monitoring/`)
- **Purpose**: Comprehensive observability and alerting
- **Staging Features**:
  - Enhanced CloudWatch alarms and dashboards
  - Comprehensive VPC Flow Logs
  - Staging-grade log retention (30 days)
  - Enhanced security monitoring
- **Dependencies**: VPC, SNS, Security Groups

## Staging Deployment Order

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

## Staging Configuration

### Staging-Specific Settings
- **Instance Types**: `t3.small` and larger for performance
- **Backup Retention**: 14 days for moderate security
- **Deletion Protection**: Enabled for critical resources
- **Multi-AZ**: Enabled for all services
- **Monitoring**: Enhanced monitoring with detailed metrics

### Staging Security Features
- **KMS Encryption**: All data encrypted at rest with 14-day deletion windows
- **Security Groups**: Moderate least privilege access with comprehensive rules
- **IAM Roles**: Enhanced security policies with compliance requirements
- **VPC Endpoints**: All AWS services accessed via VPC endpoints
- **VPN Gateway**: Secure remote access for administrators
- **VPC Flow Logs**: Comprehensive network traffic monitoring

### Staging Compliance Features
- **SOC2 Compliance**: Comprehensive audit logging and controls
- **ISO27001 Compliance**: Information security management
- **GDPR Compliance**: Data protection and privacy controls
- **Enhanced Logging**: 30-day log retention for compliance

### Staging Reliability Features
- **Multi-AZ Deployments**: All services deployed across multiple AZs
- **Auto Scaling**: Comprehensive auto scaling for all compute resources
- **Load Balancing**: Application Load Balancer with health checks
- **Database Reliability**: Multi-AZ deployments for RDS
- **Cache Failover**: Automatic failover for ElastiCache clusters

## Staging Usage

### Prerequisites
- Terragrunt installed and configured
- AWS credentials with staging access
- Access to all required AWS services
- Security and compliance approvals

### Staging Deployment Commands

```bash
# Deploy all modules in order (Staging)
terragrunt run-all apply

# Deploy specific module
terragrunt apply --terragrunt-working-dir vpc/

# Plan changes (always run before apply in staging)
terragrunt run-all plan

# Destroy specific module (use with caution)
terragrunt destroy --terragrunt-working-dir vpc/

# Destroy all modules (use with caution)
terragrunt run-all destroy
```

### Staging Module-Specific Commands

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

## Staging Monitoring and Alerting

### Enhanced CloudWatch Dashboard
- CPU, memory, and disk utilization
- ALB request count, response time, and error rates
- RDS and ElastiCache performance metrics
- Network traffic and security metrics
- Custom application performance metrics

### Staging Alarms
- **CPU Utilization**: >75% for 2 evaluation periods
- **Memory Utilization**: >80% for 2 evaluation periods
- **Disk Utilization**: >85% for 2 evaluation periods
- **ALB Response Time**: >4 seconds for 2 evaluation periods
- **RDS Connections**: >75% of max connections
- **Error Rates**: >5% error rate for 2 evaluation periods
- **Availability**: <99.5% availability for 1 evaluation period

### Staging SNS Topics
- **High Alerts**: High priority issues requiring attention
- **Monitoring**: General monitoring notifications
- **Budget**: Cost and budget alerts with team notifications
- **Security**: Security-related notifications with security team
- **Compliance**: Compliance-related notifications with compliance team

## Staging Troubleshooting

### Common Staging Issues

1. **Reliability Issues**
   - Check Multi-AZ configurations
   - Verify auto scaling group health
   - Review load balancer health checks
   - Check database replication status

2. **Performance Issues**
   - Monitor CloudWatch metrics
   - Check auto scaling group scaling
   - Review database performance insights
   - Analyze application logs

3. **Security and Compliance Issues**
   - Review CloudTrail logs
   - Check IAM access logs
   - Verify encryption configurations
   - Review security group rules

4. **Cost Optimization**
   - Monitor CloudWatch billing alarms
   - Review resource utilization
   - Check for unused resources
   - Optimize instance types and sizes

### Staging Debugging Commands

```bash
# Check Terragrunt configuration
terragrunt validate-inputs

# Show module dependencies
terragrunt graph

# Check AWS resource state
terragrunt state list

# Import existing resources (use with caution)
terragrunt import aws_vpc.main vpc-12345678

# Check compliance status
aws config get-compliance-details-by-config-rule --config-rule-name required-tags
```

## Staging Maintenance

### Regular Staging Tasks
- Monitor CloudWatch alarms and logs daily
- Review security group rules weekly
- Rotate KMS keys monthly
- Update Terraform modules quarterly
- Review and optimize costs monthly
- Conduct security audits quarterly
- Update compliance documentation monthly

### Staging Backup and Recovery
- RDS automated backups (14-day retention)
- Manual snapshots for critical data
- Disaster recovery testing quarterly
- Terraform state backup and versioning
- Configuration documentation updates

## Staging Security Considerations

### Data Protection
- All data encrypted at rest using KMS with 14-day deletion windows
- Data in transit encrypted using TLS 1.2+
- VPC isolation with comprehensive security groups
- IAM least privilege access control with compliance policies

### Staging Compliance
- SOC2 compliance for service organization controls
- ISO27001 compliance for information security
- GDPR compliance for EU data protection
- Regular security audits and testing

### Staging Best Practices
- Use IAM roles instead of access keys
- Regularly rotate credentials and keys
- Monitor and alert on all security events
- Keep Terraform modules updated and patched
- Document all changes and configurations
- Conduct regular security training

## Staging Support

For staging issues or questions:
- Check the troubleshooting section above
- Review CloudWatch logs and alarms
- Contact the DevOps team for issues
- Contact AWS support for service-specific issues
- Refer to compliance documentation for regulatory issues

## Staging Change Management

### Change Approval Process
- All changes require approval from DevOps lead
- Security changes require security team approval
- Compliance changes require compliance team approval
- Staging deployments require team lead approval

### Rollback Procedures
- Maintain previous Terraform state versions
- Document rollback procedures for each module
- Test rollback procedures in development environment
- Maintain backup configurations for critical resources

## Environment Comparison

### Staging vs Development
- **Higher Security**: Enhanced security controls and compliance
- **Better Reliability**: Multi-AZ deployments and failover
- **More Monitoring**: Comprehensive monitoring and alerting
- **Production-like**: Closer to production configuration

### Staging vs Production
- **Lower Security**: Moderate security controls vs strict production controls
- **Cost Optimized**: Smaller instance types and reduced redundancy
- **Faster Changes**: Less restrictive change management
- **Testing Focus**: Designed for testing and validation

## Version History

- **v1.0.0**: Initial staging implementation
- All modules sourced from `https://github.com/catherinevee`
- Version-pinned modules for stability
- Comprehensive monitoring and alerting
- Staging-optimized for reliability and moderate security
- SOC2, ISO27001, and GDPR compliant 