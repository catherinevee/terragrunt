# Client B - Development Environment (eu-west-3)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's development environment in the eu-west-3 region. The solution follows a modular architecture with proper dependency management and version pinning.

## 📁 **Directory Structure**

```
dev/eu-west-3/
├── region.hcl                    # Region-specific configuration
├── terragrunt.hcl               # Root configuration
├── README.md                    # This documentation
├── vpc/                         # Network foundation
│   └── terragrunt.hcl
├── kms/                         # Encryption keys
│   └── terragrunt.hcl
├── sns/                         # Notifications
│   └── terragrunt.hcl
├── security-groups/             # Network security
│   └── terragrunt.hcl
├── iam/                         # Identity & Access Management
│   └── terragrunt.hcl
├── compute/                     # EC2 instances & Auto Scaling
│   └── terragrunt.hcl
├── storage/                     # S3 buckets & storage
│   └── terragrunt.hcl
├── rds/                         # Database instances
│   └── terragrunt.hcl
├── elasticache/                 # Cache clusters
│   └── terragrunt.hcl
├── alb/                         # Application Load Balancer
│   └── terragrunt.hcl
├── monitoring/                  # CloudWatch & observability
│   └── terragrunt.hcl
└── network/                     # Network Firewall
    └── terragrunt.hcl
```

## 🧩 **Solution Components**

### **Foundational Infrastructure**
- **VPC Module** (`vpc/`): Multi-tier network architecture with public, private, database, and ElastiCache subnets
- **KMS Module** (`kms/`): Encryption keys for various services (S3, RDS, ElastiCache, general)
- **SNS Module** (`sns/`): Notification topics for alerts, monitoring, budget, and security
- **Security Groups Module** (`security-groups/`): Network security rules for different tiers

### **Application Infrastructure**
- **IAM Module** (`iam/`): Users, groups, roles, and policies for development team
- **Compute Module** (`compute/`): EC2 instances, Auto Scaling Groups, and Launch Templates
- **Storage Module** (`storage/`): S3 buckets with lifecycle policies and KMS encryption
- **RDS Module** (`rds/`): MySQL and PostgreSQL database instances with encryption
- **ElastiCache Module** (`elasticache/`): Redis and Memcached cache clusters
- **ALB Module** (`alb/`): Application Load Balancer with target groups and listeners

### **Operational Infrastructure**
- **Monitoring Module** (`monitoring/`): CloudWatch logs, alarms, VPC flow logs, and dashboards
- **Network Module** (`network/`): AWS Network Firewall for advanced security

## 🔗 **Dependencies & Deployment Order**

### **Phase 1: Foundation (Deploy First)**
1. **VPC** - Network foundation
2. **KMS** - Encryption keys
3. **SNS** - Notification infrastructure
4. **Security Groups** - Network security rules

### **Phase 2: Core Services (Deploy Second)**
5. **IAM** - Identity and access management
6. **Storage** - S3 buckets and storage resources
7. **RDS** - Database instances
8. **ElastiCache** - Cache clusters

### **Phase 3: Application Layer (Deploy Third)**
9. **Compute** - EC2 instances and Auto Scaling Groups
10. **ALB** - Application Load Balancer

### **Phase 4: Operations (Deploy Last)**
11. **Monitoring** - CloudWatch and observability
12. **Network** - Network Firewall (optional)

## 🚀 **Deployment Commands**

```bash
# Navigate to the environment directory
cd terragrunt/aws/accounts-client/client-b-com/dev/eu-west-3

# Deploy all modules in dependency order
terragrunt run-all apply

# Deploy specific modules
terragrunt apply --terragrunt-working-dir vpc
terragrunt apply --terragrunt-working-dir kms
terragrunt apply --terragrunt-working-dir sns
terragrunt apply --terragrunt-working-dir security-groups

# Plan changes
terragrunt run-all plan

# Destroy specific modules (in reverse order)
terragrunt destroy --terragrunt-working-dir monitoring
terragrunt destroy --terragrunt-working-dir network
# ... continue with other modules
```

## 🏛️ **Architecture Overview**

### **Network Architecture**
- **VPC CIDR**: `10.3.0.0/16`
- **Public Subnets**: `10.3.1.0/24`, `10.3.2.0/24`, `10.3.3.0/24`
- **Private Subnets**: `10.3.10.0/24`, `10.3.20.0/24`, `10.3.30.0/24`
- **Database Subnets**: `10.3.100.0/24`, `10.3.200.0/24`, `10.3.300.0/24`
- **ElastiCache Subnets**: `10.3.110.0/24`, `10.3.210.0/24`, `10.3.310.0/24`

### **Security Architecture**
- **Multi-tier security groups** with least-privilege access
- **KMS encryption** for all data at rest
- **VPC endpoints** for secure AWS service access
- **Network Firewall** for advanced threat protection

### **High Availability**
- **Multi-AZ deployment** for critical services
- **Auto Scaling Groups** for application resilience
- **Load balancer** for traffic distribution
- **Database backups** with point-in-time recovery

## 🔧 **Configuration Details**

### **Environment-Specific Settings**
- **Instance Types**: `t3.micro` for cost optimization
- **Backup Retention**: 7 days for development
- **Deletion Protection**: Disabled for development flexibility
- **Multi-AZ**: Disabled for cost savings
- **Monitoring**: Basic CloudWatch monitoring enabled

### **Cost Optimization**
- **Single NAT Gateway** for cost efficiency
- **Small instance types** for development workloads
- **Reduced backup retention** periods
- **Lifecycle policies** for S3 cost management

### **Security Features**
- **KMS encryption** for all data at rest
- **Security groups** with minimal required access
- **IAM roles** with least privilege
- **VPC flow logs** for network monitoring

## 📊 **Monitoring & Observability**

### **CloudWatch Alarms**
- CPU utilization (>80%)
- Memory utilization (>85%)
- Disk utilization (>90%)
- ALB response time (>5s)
- RDS connections (>80%)

### **Log Management**
- **Application logs**: 7-day retention
- **System logs**: 7-day retention
- **Security logs**: 30-day retention
- **VPC flow logs**: 7-day retention

### **Dashboards**
- **Development Dashboard**: CPU, memory, ALB, RDS, and ElastiCache metrics
- **Custom widgets** for key performance indicators

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Dependency Errors**
   ```bash
   # Ensure modules are deployed in correct order
   terragrunt run-all plan
   ```

2. **VPC Endpoint Issues**
   ```bash
   # Check VPC endpoint connectivity
   aws ec2 describe-vpc-endpoints --vpc-id <vpc-id>
   ```

3. **Security Group Rules**
   ```bash
   # Verify security group rules
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

4. **KMS Key Access**
   ```bash
   # Check KMS key permissions
   aws kms describe-key --key-id <key-id>
   ```

### **Useful Commands**

```bash
# Check module status
terragrunt run-all show

# Validate configuration
terragrunt run-all validate-inputs

# Check dependencies
terragrunt graph

# View outputs
terragrunt output --terragrunt-working-dir vpc
```

## 📋 **Pre-deployment Checklist**

- [ ] AWS credentials configured
- [ ] S3 backend bucket exists
- [ ] DynamoDB table for state locking exists
- [ ] Required IAM permissions granted
- [ ] Account and region configurations verified
- [ ] Network CIDR ranges reviewed
- [ ] Security group rules validated
- [ ] KMS key policies configured

## 🔄 **Maintenance & Updates**

### **Regular Tasks**
- **Weekly**: Review CloudWatch alarms and logs
- **Monthly**: Update AMI versions and security patches
- **Quarterly**: Review and update IAM permissions
- **Annually**: Review and update compliance configurations

### **Version Updates**
- **Module versions**: Pinned to specific versions for stability
- **Terraform version**: Managed via `versions.tf`
- **Provider versions**: Updated as needed for new features

## 📞 **Support & Contacts**

- **DevOps Team**: devops@clientb.com
- **Development Team**: dev-team@clientb.com
- **Security Team**: security@clientb.com
- **Infrastructure Lead**: infrastructure@clientb.com

## 📚 **Additional Resources**

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Environment**: Development  
**Region**: eu-west-3 