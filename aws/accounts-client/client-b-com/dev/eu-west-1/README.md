# Client B - Development Environment (eu-west-1)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's development environment in the eu-west-1 region. The solution implements a complete multi-tier architecture with security, monitoring, and cost management.

## 📁 **Component Overview**

### **Foundation Layer**
- **`vpc/`** - Complete VPC infrastructure with public/private/database subnets
- **`kms/`** - Encryption keys for all services (S3, EBS, RDS, CloudWatch, Lambda)
- **`security-groups/`** - Network security groups for all tiers
- **`sns/`** - Notification infrastructure for alerts and monitoring

### **Identity & Access Management**
- **`iam/`** - Users, groups, roles, and policies for development team

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

3. **Infrastructure**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir storage
   terragrunt run-all apply --terragrunt-working-dir network
   terragrunt run-all apply --terragrunt-working-dir compute
   ```

4. **Monitoring & Management**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir netmon
   terragrunt run-all apply --terragrunt-working-dir budget
   ```

## 🏛️ **Architecture Details**

### **Network Architecture**
- **VPC CIDR**: `10.1.0.0/16`
- **Public Subnets**: `10.1.1.0/24`, `10.1.2.0/24`, `10.1.3.0/24`
- **Private Subnets**: `10.1.10.0/24`, `10.1.20.0/24`, `10.1.30.0/24`
- **Database Subnets**: `10.1.100.0/24`, `10.1.200.0/24`, `10.1.300.0/24`
- **Availability Zones**: eu-west-1a, eu-west-1b, eu-west-1c

### **Security Groups**
- **Web Server SG**: HTTP/HTTPS from internet, SSH from office
- **App Server SG**: HTTP/HTTPS from web servers, SSH from office
- **Database SG**: MySQL/PostgreSQL from app servers, SSH from office
- **Load Balancer SG**: HTTP/HTTPS from internet to web servers
- **VPC Endpoints SG**: HTTPS from VPC CIDR
- **Monitoring SG**: SSH/HTTP from office networks

### **Encryption Strategy**
- **S3**: KMS encryption with `alias/dev-s3`
- **EBS**: KMS encryption with `alias/dev-ebs`
- **RDS**: KMS encryption with `alias/dev-rds`
- **CloudWatch**: KMS encryption with `alias/dev-cloudwatch`
- **Lambda**: KMS encryption with `alias/dev-lambda`

### **Monitoring & Alerting**
- **VPC Flow Logs**: All traffic logging to CloudWatch
- **CloudWatch Alarms**: CPU, memory, disk, network monitoring
- **SNS Topics**: 
  - General notifications
  - Security alerts
  - Budget alerts
  - Monitoring alerts
  - Application alerts

### **Cost Management**
- **Monthly Budget**: $5,000 with 80%, 100%, 120% alerts
- **Quarterly Budget**: $15,000 with 85%, 100% alerts
- **Annual Budget**: $60,000 with 90%, 100% alerts

## 🔧 **Configuration Features**

### **Environment-Specific Settings**
- Development-appropriate instance types (t3.micro, t3.small)
- 90-day data retention for development data
- 1-year log retention
- Office network access for SSH (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)

### **Security Best Practices**
- Principle of least privilege
- Network segmentation (public/private/database tiers)
- Encryption at rest and in transit
- Security group-based access control
- VPC endpoints for AWS services

### **Operational Excellence**
- Comprehensive tagging strategy
- Automated monitoring and alerting
- Cost tracking and budget management
- Centralized logging and monitoring

## 📊 **Resource Summary**

| Component | Resources Created |
|-----------|------------------|
| VPC | 1 VPC, 9 subnets, 3 route tables, 1 IGW, 1 NAT Gateway, 5 VPC endpoints |
| KMS | 6 encryption keys with aliases |
| Security Groups | 6 security groups with tiered access |
| SNS | 5 topics with 7 subscriptions |
| IAM | 4 users, 6 groups, 2 roles, 3 policies |
| Storage | 2 S3 buckets with lifecycle policies |
| Compute | 2 EC2 instances (web + app server) |
| Network | 1 Network Firewall with policies |
| Monitoring | VPC Flow Logs, CloudWatch Log Groups, Alarms |
| Budget | 3 budgets with SNS notifications |

## 🚨 **Important Notes**

1. **Pre-deployment Requirements**:
   - AWS credentials configured
   - Terragrunt installed
   - S3 backend configured for state management

2. **Security Considerations**:
   - Update office network CIDRs in security groups
   - Review and customize IAM policies as needed
   - Configure actual phone numbers for SMS alerts

3. **Cost Optimization**:
   - Monitor budget alerts closely
   - Consider using Spot instances for development workloads
   - Review and adjust retention policies

4. **Maintenance**:
   - Regular security group reviews
   - KMS key rotation monitoring
   - Budget threshold adjustments

## 🔍 **Troubleshooting**

### **Common Issues**
1. **Dependency Errors**: Ensure components are deployed in order
2. **Permission Errors**: Verify IAM roles and policies
3. **Network Issues**: Check security group rules and VPC configuration
4. **Encryption Errors**: Verify KMS key policies and permissions

### **Useful Commands**
```bash
# Validate configuration
terragrunt plan

# Check dependencies
terragrunt graph

# Destroy specific component
terragrunt destroy --terragrunt-working-dir <component>

# View outputs
terragrunt output --terragrunt-working-dir <component>
```

## 📞 **Support**

For issues or questions:
- **DevOps Team**: devops@client-b.com
- **Security Team**: security@client-b.com
- **Finance Team**: finance@client-b.com

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Environment**: Development  
**Region**: eu-west-1 