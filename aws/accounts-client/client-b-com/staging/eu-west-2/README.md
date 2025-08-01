# Client B - Staging Environment (eu-west-2)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's staging environment in the eu-west-2 region. The solution implements a complete multi-tier architecture with enterprise-grade security, monitoring, and cost management.

## 📋 **Component Overview**

### **Foundation Layer (Tier 1)**
- **VPC** (`vpc/`) - Multi-AZ VPC with public, private, database, and elasticache subnets
- **KMS** (`kms/`) - Encryption keys for S3, RDS, ElastiCache, and CloudWatch
- **SNS** (`sns/`) - Notification topics for alerts and monitoring
- **Security Groups** (`security-groups/`) - Network security rules for all tiers

### **Identity & Access Management**
- **IAM** (`iam/`) - Users, groups, roles, and policies for staging team

### **Data Layer (Tier 2)**
- **RDS** (`rds/`) - MySQL database with multi-AZ deployment
- **ElastiCache** (`elasticache/`) - Redis cache cluster with replication

### **Application Layer (Tier 3)**
- **ALB** (`alb/`) - Application Load Balancer with HTTPS termination
- **E-commerce** (`ecommerce/`) - E-commerce application infrastructure

### **Monitoring & Observability**
- **Monitoring** (`monitoring/`) - CloudWatch alarms, logs, and dashboards

## 🔗 **Deployment Dependencies**

```
Tier 1 (Foundation):
├── vpc/ (no dependencies)
├── kms/ (no dependencies)
├── sns/ (no dependencies)
└── security-groups/ (depends on vpc/)

Tier 2 (Identity & Data):
├── iam/ (no dependencies)
├── rds/ (depends on vpc/, security-groups/, kms/)
└── elasticache/ (depends on vpc/, security-groups/, kms/)

Tier 3 (Application):
├── alb/ (depends on vpc/, security-groups/)
└── ecommerce/ (depends on vpc/, security-groups/, alb/)

Tier 4 (Monitoring):
└── monitoring/ (depends on vpc/, sns/, security-groups/)
```

## 🚀 **Deployment Order**

### **Phase 1: Foundation Infrastructure**
```bash
# Deploy foundational components
terragrunt run-all apply --terragrunt-include-dir vpc
terragrunt run-all apply --terragrunt-include-dir kms
terragrunt run-all apply --terragrunt-include-dir sns
terragrunt run-all apply --terragrunt-include-dir security-groups
```

### **Phase 2: Identity & Data Layer**
```bash
# Deploy identity and data components
terragrunt run-all apply --terragrunt-include-dir iam
terragrunt run-all apply --terragrunt-include-dir rds
terragrunt run-all apply --terragrunt-include-dir elasticache
```

### **Phase 3: Application Layer**
```bash
# Deploy application components
terragrunt run-all apply --terragrunt-include-dir alb
terragrunt run-all apply --terragrunt-include-dir ecommerce
```

### **Phase 4: Monitoring & Observability**
```bash
# Deploy monitoring components
terragrunt run-all apply --terragrunt-include-dir monitoring
```

## 🏛️ **Architecture Details**

### **Network Architecture**
- **VPC CIDR**: `10.2.0.0/16`
- **Public Subnets**: `10.2.1.0/24`, `10.2.2.0/24`, `10.2.3.0/24` (3 AZs)
- **Private Subnets**: `10.2.10.0/24`, `10.2.11.0/24`, `10.2.12.0/24` (3 AZs)
- **Database Subnets**: `10.2.20.0/24`, `10.2.21.0/24`, `10.2.22.0/24` (3 AZs)
- **ElastiCache Subnets**: `10.2.30.0/24`, `10.2.31.0/24`, `10.2.32.0/24` (3 AZs)

### **Security Architecture**
- **Multi-AZ NAT Gateways** for high availability
- **VPC Endpoints** for secure AWS service access
- **Security Groups** with principle of least privilege
- **KMS Encryption** for data at rest and in transit
- **IAM Roles** with minimal required permissions

### **High Availability Features**
- **Multi-AZ RDS** with automatic failover
- **Redis Replication** with automatic failover
- **ALB** with cross-zone load balancing
- **Multi-AZ deployment** across all components

## ⚙️ **Configuration Features**

### **Environment-Specific Optimizations**
- **Staging-optimized** resource sizing (t3.micro for RDS, cache.t3.micro for Redis)
- **Enhanced monitoring** with Performance Insights and detailed alarms
- **Comprehensive logging** with 30-day retention for application logs
- **Security-focused** configuration with encryption and access controls

### **Cost Optimization**
- **Reserved Instances** recommendations for predictable workloads
- **Auto-scaling** policies for dynamic resource management
- **Lifecycle policies** for log retention and cleanup
- **Resource tagging** for cost allocation and tracking

### **Compliance & Governance**
- **GDPR compliance** with EU data residency
- **ISO27001** security standards implementation
- **Comprehensive audit logging** and monitoring
- **Access controls** and least privilege principles

## 📊 **Resource Summary**

| Component | Resource Type | Count | Purpose |
|-----------|---------------|-------|---------|
| VPC | Virtual Private Cloud | 1 | Network isolation |
| Subnets | Subnet | 12 | Network segmentation |
| NAT Gateway | NAT Gateway | 3 | Internet access for private resources |
| VPC Endpoints | VPC Endpoint | 9 | Secure AWS service access |
| KMS Keys | KMS Key | 5 | Data encryption |
| SNS Topics | SNS Topic | 5 | Notifications and alerts |
| Security Groups | Security Group | 5 | Network security |
| IAM Roles | IAM Role | 3 | Access management |
| RDS Instance | RDS Instance | 1 | Database (MySQL) |
| ElastiCache Cluster | ElastiCache Cluster | 1 | Caching (Redis) |
| ALB | Application Load Balancer | 1 | Load balancing |
| CloudWatch Alarms | CloudWatch Alarm | 5 | Monitoring and alerting |
| CloudWatch Dashboard | CloudWatch Dashboard | 1 | Operational visibility |

## 🔧 **Troubleshooting**

### **Common Issues**

1. **Dependency Errors**
   - Ensure modules are deployed in the correct order
   - Verify all dependencies are properly configured

2. **Security Group Issues**
   - Check that security group rules allow required traffic
   - Verify VPC endpoints are accessible from private subnets

3. **RDS Connection Issues**
   - Ensure database subnet group is properly configured
   - Verify security groups allow database access

4. **ALB Health Check Failures**
   - Check target group health check configuration
   - Verify application is responding on the health check path

### **Monitoring & Alerts**

- **CloudWatch Dashboard**: `Client-B-Staging-Dashboard`
- **SNS Topics**: Configured for various alert types
- **Log Groups**: Centralized logging for all components
- **VPC Flow Logs**: Network traffic monitoring

### **Support Contacts**

- **DevOps Team**: devops@client-b.com
- **Security Team**: security@client-b.com
- **E-commerce Team**: ecommerce@client-b.com
- **Monitoring Team**: monitoring@client-b.com

## 📝 **Notes**

- This environment is configured for **staging workloads** with enhanced monitoring
- All resources are **encrypted at rest** using KMS keys
- **Multi-AZ deployment** ensures high availability
- **Comprehensive logging** enables operational visibility
- **Security-first approach** with least privilege access controls

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintained By**: DevOps Team 