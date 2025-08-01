# Client B - Development Environment (eu-west-2)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's development environment in the eu-west-2 region. The solution implements a complete modular architecture with security, monitoring, and cost management specifically designed for ecommerce applications.

## 📁 **Component Overview**

### **Foundation Layer**
- **`vpc/`** - Complete VPC infrastructure with public/private/database/elasticache subnets
- **`kms/`** - Encryption keys for all services (S3, RDS, ElastiCache, CloudWatch)
- **`sns/`** - Notification infrastructure for alerts and monitoring
- **`security-groups/`** - Network security groups for all tiers

### **Identity & Access Management**
- **`iam/`** - Users, groups, roles, and policies for development team

### **Data Layer**
- **`rds/`** - MySQL database for ecommerce application
- **`elasticache/`** - Redis cache for session management and performance

### **Application Layer**
- **`alb/`** - Application Load Balancer for traffic distribution
- **`ecommerce/`** - Ecommerce application infrastructure

### **Monitoring & Observability**
- **`monitoring/`** - CloudWatch monitoring, alarms, and dashboards

## 🔄 **Deployment Dependencies**

The components are designed with proper dependency management:

```
vpc/ → security-groups/ → alb/
vpc/ → security-groups/ → rds/
vpc/ → security-groups/ → elasticache/
vpc/ → monitoring/
kms/ → rds/
kms/ → elasticache/
kms/ → monitoring/
sns/ → monitoring/
rds/ → ecommerce/
elasticache/ → ecommerce/
alb/ → ecommerce/
security-groups/ → ecommerce/
```

## 🚀 **Deployment Order**

1. **Foundation (Deploy First)**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir vpc
   terragrunt run-all apply --terragrunt-working-dir kms
   terragrunt run-all apply --terragrunt-working-dir sns
   ```

2. **Security & Identity**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir security-groups
   terragrunt run-all apply --terragrunt-working-dir iam
   ```

3. **Data Layer**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir rds
   terragrunt run-all apply --terragrunt-working-dir elasticache
   ```

4. **Application Layer**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir alb
   terragrunt run-all apply --terragrunt-working-dir ecommerce
   ```

5. **Monitoring & Observability**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir monitoring
   ```

## 🏛️ **Architecture Details**

### **VPC Architecture**
- **VPC CIDR**: `10.2.0.0/16`
- **Public Subnets**: `10.2.1.0/24`, `10.2.2.0/24`, `10.2.3.0/24` (eu-west-2a, eu-west-2b, eu-west-2c)
- **Private Subnets**: `10.2.10.0/24`, `10.2.11.0/24`, `10.2.12.0/24` (eu-west-2a, eu-west-2b, eu-west-2c)
- **Database Subnets**: `10.2.20.0/24`, `10.2.21.0/24`, `10.2.22.0/24` (eu-west-2a, eu-west-2b, eu-west-2c)
- **ElastiCache Subnets**: `10.2.30.0/24`, `10.2.31.0/24`, `10.2.32.0/24` (eu-west-2a, eu-west-2b, eu-west-2c)
- **Internet Gateway**: For public internet access
- **NAT Gateway**: For private subnet internet access
- **VPC Endpoints**: S3 and DynamoDB for private access

### **Security Architecture**
- **Security Groups**: Tiered security (ALB, App, Database, Cache, Monitoring)
- **KMS Encryption**: Service-specific encryption keys
- **IAM**: Role-based access control with least privilege

### **Database Architecture**
- **RDS MySQL**: Single AZ for development (cost optimization)
- **Instance Type**: db.t3.micro
- **Storage**: 20GB GP2 with auto-scaling up to 100GB
- **Backup**: 7-day retention
- **Encryption**: KMS-managed encryption

### **Cache Architecture**
- **ElastiCache Redis**: Single node for development
- **Node Type**: cache.t3.micro
- **Encryption**: KMS-managed encryption at rest
- **Backup**: 7-day retention

### **Load Balancer Architecture**
- **Application Load Balancer**: Internet-facing
- **Target Groups**: Instance-based targeting
- **Health Checks**: HTTP-based with 30-second intervals
- **SSL/TLS**: TLS 1.2 with custom certificate
- **Access Logs**: S3-based logging

### **Ecommerce Application Architecture**
- **Auto Scaling**: Disabled for development (cost optimization)
- **Instance Type**: t3.medium
- **Min/Max Size**: 1-3 instances
- **Health Checks**: Application-level health endpoints
- **Monitoring**: CloudWatch integration

### **Monitoring Architecture**
- **CloudWatch Logs**: Centralized logging with 7-day retention
- **CloudWatch Alarms**: CPU, memory, database, and ALB monitoring
- **VPC Flow Logs**: Network traffic monitoring
- **Dashboard**: Custom ecommerce monitoring dashboard

## 🔧 **Configuration Features**

### **Version Pinning**
All modules use specific version tags for consistency:
- VPC: `v1.0.0`
- KMS: `v1.0.0`
- SNS: `v1.0.0`
- Security Groups: `v1.0.0`
- RDS: `v1.0.0`
- ElastiCache: `v1.0.0`
- ALB: `v1.0.0`
- Monitoring: `v1.0.0`
- Ecommerce: `v1.0.0`

### **Environment-Specific Configurations**
- **Development Environment**: Cost-optimized, single-AZ deployments
- **Resource Sizing**: Minimal instances for development workloads
- **Alert Thresholds**: Relaxed for development workloads
- **Retention Policies**: 7 days for logs and data

### **Security Features**
- **Encryption at Rest**: KMS-managed keys for all services
- **Encryption in Transit**: TLS/SSL for all communications
- **Network Segmentation**: Public, private, database, and cache tiers
- **Access Control**: IAM roles and policies with least privilege

### **Monitoring Features**
- **Real-time Monitoring**: CloudWatch metrics and alarms
- **Log Aggregation**: Centralized logging with search capabilities
- **Network Visibility**: Flow logs and network monitoring
- **Health Checks**: Automated application health monitoring
- **Alerting**: Multi-channel notifications via SNS

## 📊 **Resource Summary**

### **Networking**
- 1 VPC with 12 subnets across 3 AZs
- 1 Internet Gateway
- 1 NAT Gateway
- 2 VPC Endpoints (S3, DynamoDB)
- 5 Security Groups

### **Database & Cache**
- 1 RDS MySQL instance (db.t3.micro)
- 1 ElastiCache Redis cluster (cache.t3.micro)

### **Load Balancing**
- 1 Application Load Balancer
- 1 Target Group
- 2 Listeners (HTTP, HTTPS)

### **Application**
- 1-3 EC2 instances (t3.medium)
- Auto Scaling Group (disabled for dev)

### **Monitoring**
- 3 CloudWatch Log Groups
- 4 CloudWatch Alarms
- 1 VPC Flow Log
- 1 CloudWatch Dashboard

### **Security**
- 5 KMS keys for encryption
- 5 Security Groups with tiered access
- IAM users, groups, roles, and policies

### **Notifications**
- 5 SNS topics for different alert types
- 5 email subscriptions

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Dependency Errors**
   - Ensure foundation modules (vpc, kms, sns) are deployed first
   - Check that all dependency paths are correct

2. **Security Group Issues**
   - Verify security group rules allow required traffic
   - Check that security groups reference the correct VPC

3. **KMS Key Issues**
   - Ensure KMS keys are created before database and cache modules
   - Verify key policies allow required access

4. **SNS Notification Issues**
   - Check that SNS topics are created before monitoring module
   - Verify email subscriptions are confirmed

### **Deployment Commands**

```bash
# Deploy all modules
terragrunt run-all apply

# Deploy specific module
terragrunt apply --terragrunt-working-dir vpc

# Plan changes
terragrunt plan --terragrunt-working-dir vpc

# Destroy specific module
terragrunt destroy --terragrunt-working-dir vpc
```

### **Validation Commands**

```bash
# Validate all configurations
terragrunt run-all validate-inputs

# Check dependencies
terragrunt run-all graph

# Show module outputs
terragrunt output --terragrunt-working-dir vpc
```

## 📋 **Maintenance**

### **Regular Tasks**
- **Weekly**: Review and update security group rules
- **Monthly**: Review and optimize resource sizing
- **Quarterly**: Update module versions and review architecture

### **Monitoring Tasks**
- **Daily**: Check CloudWatch alarms and SNS notifications
- **Weekly**: Review VPC Flow Logs for unusual traffic
- **Monthly**: Analyze cost reports and optimize spending

### **Security Tasks**
- **Daily**: Review security group logs and alerts
- **Weekly**: Rotate KMS keys and update IAM policies
- **Monthly**: Conduct security assessments

## 🔗 **Related Documentation**

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [AWS RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [AWS ElastiCache Best Practices](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/best-practices.html)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## 📞 **Support**

For issues or questions regarding this infrastructure:
- **DevOps Team**: devops@client-b.com
- **Security Team**: security@client-b.com
- **Development Team**: dev@client-b.com

---

**Last Updated**: January 2025
**Version**: v1.0.0
**Environment**: Development
**Region**: eu-west-2
**Compliance**: GDPR 