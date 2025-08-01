# Client B - Production Environment (eu-west-2)

## 🏗️ **Complete AWS Solution Architecture**

This directory contains a comprehensive, production-ready AWS infrastructure for Client B's production environment in the eu-west-2 region. The solution implements a complete multi-tier architecture with enterprise-grade security, monitoring, and cost management.

## 📋 **Component Overview**

### **Foundation Layer (Tier 1)**
- **VPC** (`vpc/`) - Multi-AZ VPC with public, private, database, and elasticache subnets
- **KMS** (`kms/`) - Encryption keys for S3, RDS, ElastiCache, and CloudWatch
- **SNS** (`sns/`) - Notification topics for alerts and monitoring
- **Security Groups** (`security-groups/`) - Network security rules for all tiers

### **Identity & Access Management**
- **IAM** (`iam/`) - Users, groups, roles, and policies for production team

### **Data Layer (Tier 2)**
- **RDS** (`rds/`) - MySQL database with multi-AZ deployment and enhanced performance
- **ElastiCache** (`elasticache/`) - Redis cache cluster with replication and failover

### **Application Layer (Tier 3)**
- **ALB** (`alb/`) - Application Load Balancer with HTTPS termination and deletion protection
- **E-commerce** (`ecommerce/`) - E-commerce application infrastructure

### **Monitoring & Observability**
- **Monitoring** (`monitoring/`) - CloudWatch alarms, logs, and dashboards with extended retention

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
- **Deletion Protection** enabled on critical resources

### **High Availability Features**
- **Multi-AZ RDS** with automatic failover and enhanced monitoring
- **Redis Replication** with automatic failover and enhanced performance
- **ALB** with cross-zone load balancing and deletion protection
- **Multi-AZ deployment** across all components
- **Enhanced backup retention** (30 days for RDS, 30 days for ElastiCache)

## ⚙️ **Configuration Features**

### **Production-Specific Optimizations**
- **Production-grade** resource sizing (t3.small for RDS, cache.t3.small for Redis)
- **Enhanced monitoring** with Performance Insights and extended retention
- **Comprehensive logging** with 90-day retention for application logs, 365 days for security logs
- **Security-focused** configuration with encryption, access controls, and deletion protection
- **Extended KMS key deletion windows** (30 days) for production safety

### **Cost Optimization**
- **Reserved Instances** recommendations for predictable workloads
- **Auto-scaling** policies for dynamic resource management
- **Lifecycle policies** for log retention and cleanup
- **Resource tagging** for cost allocation and tracking
- **GP3 storage** for RDS with better performance and cost efficiency

### **Compliance & Governance**
- **GDPR compliance** with EU data residency
- **ISO27001, SOC2, PCI-DSS** security standards implementation
- **Comprehensive audit logging** and monitoring with extended retention
- **Access controls** and least privilege principles
- **Enhanced security monitoring** with multiple notification channels

## 📊 **Resource Summary**

| Component | Resource Type | Count | Purpose |
|-----------|---------------|-------|---------|
| VPC | Virtual Private Cloud | 1 | Network isolation |
| Subnets | Subnet | 12 | Network segmentation |
| NAT Gateway | NAT Gateway | 3 | Internet access for private resources |
| VPC Endpoints | VPC Endpoint | 9 | Secure AWS service access |
| KMS Keys | KMS Key | 5 | Data encryption (30-day deletion window) |
| SNS Topics | SNS Topic | 5 | Notifications and alerts (multiple subscribers) |
| Security Groups | Security Group | 5 | Network security |
| IAM Roles | IAM Role | 3 | Access management |
| RDS Instance | RDS Instance | 1 | Database (MySQL) with enhanced performance |
| ElastiCache Cluster | ElastiCache Cluster | 1 | Caching (Redis) with replication |
| ALB | Application Load Balancer | 1 | Load balancing with deletion protection |
| CloudWatch Alarms | CloudWatch Alarm | 7 | Enhanced monitoring and alerting |
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
   - Check Performance Insights and monitoring configuration

4. **ALB Health Check Failures**
   - Check target group health check configuration
   - Verify application is responding on the health check path
   - Ensure deletion protection is not blocking operations

5. **KMS Key Issues**
   - Verify KMS key permissions and policies
   - Check key deletion windows (30 days for production)
   - Ensure proper key rotation is configured

### **Monitoring & Alerts**

- **CloudWatch Dashboard**: `Client-B-Production-Dashboard`
- **SNS Topics**: Configured for various alert types with multiple subscribers
- **Log Groups**: Extended retention (90 days for app logs, 365 days for security)
- **VPC Flow Logs**: Network traffic monitoring with 90-day retention
- **Enhanced Alarms**: Additional monitoring for RDS connections and ALB response times

### **Support Contacts**

- **DevOps Team**: devops@client-b.com
- **On-Call Team**: oncall@client-b.com
- **Security Team**: security@client-b.com
- **Incident Response**: incident-response@client-b.com
- **E-commerce Team**: ecommerce@client-b.com
- **Business Critical**: business-critical@client-b.com
- **Monitoring Team**: monitoring@client-b.com
- **SRE Team**: sre@client-b.com
- **App Support**: app-support@client-b.com
- **Engineering Team**: engineering@client-b.com

## 📝 **Notes**

- This environment is configured for **production workloads** with enhanced security and monitoring
- All resources are **encrypted at rest** using KMS keys with 30-day deletion windows
- **Multi-AZ deployment** ensures high availability and disaster recovery
- **Extended logging retention** enables comprehensive audit trails
- **Security-first approach** with least privilege access controls and deletion protection
- **Enhanced monitoring** with additional alarms for production-critical metrics
- **Multiple notification channels** ensure critical alerts reach the right teams

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintained By**: DevOps Team 