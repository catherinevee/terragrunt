# Client B - Production Environment (eu-west-1)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's production environment in the eu-west-1 region. The solution implements a complete multi-tier architecture with enterprise-grade security, monitoring, and cost management.

## 📁 **Component Overview**

### **Foundation Layer**
- **`vpc/`** - Complete VPC infrastructure with public/private/database subnets
- **`kms/`** - Encryption keys for all services (S3, EBS, RDS, CloudWatch, Lambda)
- **`security-groups/`** - Network security groups for all tiers
- **`sns/`** - Notification infrastructure for alerts and monitoring

### **Identity & Access Management**
- **`iam/`** - Users, groups, roles, and policies for production team

### **Storage Layer**
- **`storage/`** - S3 buckets for application data and logs with KMS encryption

### **Compute Layer**
- **`compute/`** - EC2 instances for web and application servers

### **Security Layer**
- **`network/`** - Network Firewall for advanced threat protection

### **Monitoring & Observability**
- **`netmon/`** - VPC Flow Logs, CloudWatch monitoring, and alerting

### **Cost Management**
- **`budget/`** - Budget tracking and cost alerts via SNS

## 🔄 **Deployment Dependencies**

The components are designed with proper dependency management:

```
vpc/ → security-groups/ → compute/
vpc/ → network/
vpc/ → netmon/
kms/ → storage/
kms/ → netmon/
sns/ → budget/
sns/ → netmon/
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

3. **Storage & Compute**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir storage
   terragrunt run-all apply --terragrunt-working-dir compute
   ```

4. **Security & Monitoring**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir network
   terragrunt run-all apply --terragrunt-working-dir netmon
   ```

5. **Cost Management**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir budget
   ```

## 🏛️ **Architecture Details**

### **VPC Architecture**
- **VPC CIDR**: `10.4.0.0/16`
- **Public Subnets**: `10.4.1.0/24`, `10.4.2.0/24` (eu-west-1a, eu-west-1b)
- **Private Subnets**: `10.4.10.0/24`, `10.4.11.0/24` (eu-west-1a, eu-west-1b)
- **Database Subnets**: `10.4.20.0/24`, `10.4.21.0/24` (eu-west-1a, eu-west-1b)
- **Internet Gateway**: For public internet access
- **NAT Gateway**: For private subnet internet access
- **VPC Endpoints**: S3 and DynamoDB for private access

### **Security Architecture**
- **Security Groups**: Tiered security (web, app, database, monitoring)
- **Network Firewall**: Advanced threat protection with custom rules
- **KMS Encryption**: Service-specific encryption keys
- **IAM**: Role-based access control with least privilege

### **Compute Architecture**
- **Web Servers**: 2x t3.medium instances in public subnets
- **App Servers**: 2x t3.large instances in private subnets
- **Database Server**: 1x t3.xlarge instance in database subnets
- **Load Balancing**: Application Load Balancer for high availability

### **Storage Architecture**
- **Application Data**: S3 bucket with KMS encryption and 7-year retention
- **Logs**: S3 bucket for centralized logging with 7-year retention
- **Backups**: S3 bucket with object lock for 10-year compliance retention
- **Static Website**: Public S3 bucket for static content
- **Archives**: S3 bucket with 10-year retention for compliance
- **Disaster Recovery**: S3 bucket with 20-year retention for critical data

### **Monitoring Architecture**
- **VPC Flow Logs**: Network traffic monitoring
- **CloudWatch Logs**: Centralized logging with KMS encryption
- **CloudWatch Alarms**: Automated alerting via SNS
- **Network Monitor**: End-to-end connectivity monitoring
- **Route 53 Health Checks**: Application health monitoring

### **Cost Management**
- **Monthly Budget**: $15,000 with 60%, 75%, 85%, 95%, 100% alerts
- **Quarterly Budget**: $45,000 with 70%, 85%, 95%, 100% alerts
- **Annual Budget**: $180,000 with 80%, 90%, 95%, 100% alerts
- **Usage Budget**: 5,000 GB-Mo with 70%, 85% alerts
- **Cost Anomaly Detection**: 5% threshold for unusual spending

## 🔧 **Configuration Features**

### **Version Pinning**
All modules use specific version tags for consistency:
- VPC: `v1.0.0`
- KMS: `v1.0.0`
- SNS: `v1.0.0`
- Security Groups: `v1.0.0`
- Network Firewall: `v1.0.0`
- Network Monitoring: `v1.0.0`
- Budget Management: `v1.0.0`

### **Environment-Specific Configurations**
- **Production Environment**: Enterprise-grade security, comprehensive monitoring
- **Resource Sizing**: Optimized for production workloads and performance
- **Alert Thresholds**: Strict for production workloads
- **Retention Policies**: 7-20 years for logs and data (compliance-driven)

### **Security Features**
- **Encryption at Rest**: KMS-managed keys for all services
- **Encryption in Transit**: TLS/SSL for all communications
- **Network Segmentation**: Public, private, and database tiers
- **Access Control**: IAM roles and policies with least privilege
- **Threat Protection**: Network Firewall with custom rules
- **Compliance**: SOX compliance with object lock and retention policies

### **Monitoring Features**
- **Real-time Monitoring**: CloudWatch metrics and alarms
- **Log Aggregation**: Centralized logging with search capabilities
- **Network Visibility**: Flow logs and network monitoring
- **Health Checks**: Automated application health monitoring
- **Alerting**: Multi-channel notifications via SNS

## 📊 **Resource Summary**

### **Networking**
- 1 VPC with 6 subnets across 2 AZs
- 1 Internet Gateway
- 1 NAT Gateway
- 2 VPC Endpoints (S3, DynamoDB)
- 6 Security Groups

### **Compute**
- 5 EC2 instances (2 web, 2 app, 1 database)
- 1 Application Load Balancer
- 1 Network Firewall

### **Storage**
- 6 S3 buckets with KMS encryption
- 6 KMS keys for different services

### **Monitoring**
- 3 CloudWatch Log Groups
- 4 CloudWatch Alarms
- 2 Network Monitors
- 2 Route 53 Health Checks

### **Security**
- 1 Network Firewall with custom rules
- 6 Security Groups with tiered access
- 6 KMS keys for encryption

### **Cost Management**
- 4 Budgets (monthly, quarterly, annual, usage)
- 1 Cost Anomaly Monitor
- 1 SNS topic for budget alerts

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Dependency Errors**
   - Ensure foundation modules (vpc, kms, sns) are deployed first
   - Check that all dependency paths are correct

2. **Security Group Issues**
   - Verify security group rules allow required traffic
   - Check that security groups reference the correct VPC

3. **KMS Key Issues**
   - Ensure KMS keys are created before storage modules
   - Verify key policies allow required access

4. **SNS Notification Issues**
   - Check that SNS topics are created before budget module
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
- **Daily**: Review Network Firewall logs and alerts
- **Weekly**: Rotate KMS keys and update IAM policies
- **Monthly**: Conduct security assessments and penetration testing

### **Compliance Tasks**
- **Monthly**: Review SOX compliance requirements
- **Quarterly**: Audit retention policies and object lock settings
- **Annually**: Conduct comprehensive compliance assessments

## 🔗 **Related Documentation**

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/)
- [AWS Cost Management](https://docs.aws.amazon.com/cost-management/latest/userguide/)
- [SOX Compliance Guidelines](https://www.sec.gov/spotlight/sarbanes-oxley.htm)

## 📞 **Support**

For issues or questions regarding this infrastructure:
- **DevOps Team**: devops@client-b.com
- **Security Team**: security@client-b.com
- **Finance Team**: finance@client-b.com
- **Compliance Team**: compliance@client-b.com

---

**Last Updated**: January 2025
**Version**: v1.0.0
**Environment**: Production
**Region**: eu-west-1
**Compliance**: SOX 