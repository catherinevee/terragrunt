# Cyprus AWS Infrastructure - Resource Map

## 📋 Overview

This document provides a comprehensive map of all AWS resources that will be created by the Cyprus Terragrunt infrastructure for the accounts-client project.

**Environment**: Cyprus  
**Region**: eu-west-1  
**Project**: accounts-client  
**Deployment Method**: Terragrunt  

---

## 🏗️ Infrastructure Architecture

```
Internet
    ↓
Application Load Balancer (Public Subnets)
    ↓
ECS Fargate Service (Private Subnets)
    ↓
RDS PostgreSQL Database (Database Subnets)
```

---

## 📊 Complete Resource Inventory

### **Module 1: VPC (Network Foundation)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **VPC** | `cyprus-vpc` | CIDR: 10.0.0.0/16 | Main VPC for all resources |
| **Public Subnets** | `cyprus-vpc-public-*` | 3 AZs (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24) | Internet-facing resources |
| **Private Subnets** | `cyprus-vpc-private-*` | 3 AZs (10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24) | Application resources |
| **Database Subnets** | `cyprus-vpc-database-*` | 3 AZs (10.0.21.0/24, 10.0.22.0/24, 10.0.23.0/24) | Database resources |
| **Internet Gateway** | `cyprus-vpc-igw` | Attached to VPC | Internet connectivity |
| **NAT Gateways** | `cyprus-vpc-nat-*` | 3 instances (one per AZ) | Private subnet internet access |
| **Route Tables** | `cyprus-vpc-*` | 4 route tables | Network routing |
| **VPC Flow Logs** | `cyprus-vpc-flow-logs` | CloudWatch Logs | Network monitoring |

**Total VPC Resources**: ~15 resources

---

### **Module 2: S3 (Data Storage)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **S3 Bucket** | `cyprus-accounts-client-{account-id}` | Versioning, Encryption, Lifecycle | Application data storage |
| **Bucket Policy** | Auto-generated | Private access only | Security policy |
| **Lifecycle Rules** | Auto-generated | 30d→IA, 90d→Glacier, 365d→Deep Archive | Cost optimization |

**Total S3 Resources**: ~3 resources

---

### **Module 3: IAM (Security & Permissions)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **IAM Role** | `cyprus-ecs-task-execution-role` | ECS Task Execution + Custom policies | ECS task execution permissions |
| **IAM Role** | `cyprus-ecs-task-role` | S3, Secrets, CloudWatch access | Application permissions |
| **IAM Policy** | `cyprus-ecs-task-policy` | Inline policy for task role | Application-specific permissions |

**Total IAM Resources**: ~3 resources

---

### **Module 4: RDS (Database Layer)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **RDS Instance** | `cyprus-accounts-client` | PostgreSQL 15.5, db.t3.micro, 20GB | Application database |
| **Security Group** | `cyprus-rds-sg` | Port 5432, ECS access only | Database security |
| **IAM Role** | `cyprus-rds-monitoring-role` | Enhanced monitoring | Database monitoring |
| **Parameter Group** | Auto-generated | PostgreSQL 15.5 family | Database configuration |
| **Subnet Group** | Auto-generated | Database subnets | Network placement |
| **Option Group** | Auto-generated | Default | Database options |

**Total RDS Resources**: ~6 resources

---

### **Module 5: ALB (Load Balancing)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **Application Load Balancer** | `cyprus-alb` | Internet-facing, 3 AZs | Traffic distribution |
| **Target Group** | `cyprus-alb-tg` | Port 8080, HTTP health checks | ECS service targets |
| **Security Group** | `cyprus-alb-sg` | Ports 80, 443 | Load balancer security |
| **HTTP Listener** | Auto-generated | Port 80, redirect to HTTPS | HTTP to HTTPS redirect |
| **HTTPS Listener** | Auto-generated | Port 443, forward to target group | Secure traffic handling |

**Total ALB Resources**: ~5 resources

---

### **Module 6: ECS Cluster (Container Orchestration)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **ECS Cluster** | `cyprus-cluster` | Fargate, Container Insights | Container orchestration |
| **Capacity Providers** | Auto-generated | FARGATE, FARGATE_SPOT | Compute capacity |

**Total ECS Cluster Resources**: ~2 resources

---

### **Module 7: ECS Service (Application Deployment)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **ECS Service** | `accounts-client-service` | 2 tasks, auto-scaling | Application deployment |
| **Task Definition** | `accounts-client` | 256 CPU, 512MB RAM | Container specification |
| **Security Group** | `cyprus-ecs-sg` | Port 8080, ALB access only | Application security |
| **CloudWatch Log Group** | `/ecs/accounts-client-service` | 7-day retention | Application logs |
| **Service Auto Scaling** | Auto-generated | CPU/Memory based | Automatic scaling |

**Total ECS Service Resources**: ~5 resources

---

### **Module 8: CloudWatch (Monitoring & Alerting)**

| Resource Type | Resource Name | Configuration | Purpose |
|---------------|---------------|---------------|---------|
| **Log Group** | `/aws/cyprus/accounts-client` | 30-day retention | General application logs |
| **Metric Alarm** | `cyprus-ecs-cpu-high` | 80% threshold, 2 periods | ECS CPU monitoring |
| **Metric Alarm** | `cyprus-ecs-memory-high` | 80% threshold, 2 periods | ECS memory monitoring |
| **Metric Alarm** | `cyprus-rds-cpu-high` | 80% threshold, 2 periods | RDS CPU monitoring |
| **Dashboard** | `cyprus-accounts-client-dashboard` | ECS + RDS metrics | Monitoring dashboard |

**Total CloudWatch Resources**: ~5 resources

---

## 🔗 Resource Dependencies

```
VPC (Foundation Layer)
├── S3 (Independent)
├── IAM (Independent)
├── RDS (Depends on VPC)
├── ALB (Depends on VPC)
├── ECS Cluster (Independent)
├── ECS Service (Depends on VPC, ALB, ECS Cluster, RDS)
└── CloudWatch (Independent)
```

**Deployment Order**:
1. VPC
2. S3, IAM (parallel)
3. RDS, ALB, ECS Cluster (parallel)
4. ECS Service
5. CloudWatch

---

## 💰 Cost Breakdown

### **Monthly Estimated Costs**

| Service Category | Resources | Estimated Cost | Notes |
|------------------|-----------|----------------|-------|
| **Compute (ECS)** | 2 Fargate tasks | ~$30 | 256 CPU, 512MB each |
| **Database (RDS)** | db.t3.micro | ~$15 | PostgreSQL 15.5 |
| **Networking (VPC)** | 3 NAT Gateways | ~$45 | High availability |
| **Load Balancing (ALB)** | Application Load Balancer | ~$20 | Data processing + LCU |
| **Storage (S3)** | Bucket + requests | ~$5 | Minimal usage |
| **Monitoring (CloudWatch)** | Logs + metrics | ~$10 | Standard monitoring |
| **Total** | | **~$125/month** | Production-ready setup |

### **Cost Optimization Opportunities**

- **NAT Gateway**: Consider single NAT Gateway (~$15/month savings)
- **ECS Spot**: Use FARGATE_SPOT for non-critical workloads
- **RDS**: Consider Aurora Serverless for variable workloads
- **S3**: Implement data lifecycle policies (already configured)

---

## 🔐 Security Configuration

### **Network Security**
- ✅ Private subnets for application and database
- ✅ Security groups with least privilege access
- ✅ VPC Flow Logs enabled
- ✅ No direct internet access for private resources

### **Data Security**
- ✅ S3 bucket encryption (AES256)
- ✅ RDS encryption at rest
- ✅ Secrets Manager for database credentials
- ✅ Public access blocked on S3

### **Access Control**
- ✅ IAM roles with least privilege
- ✅ No hardcoded credentials
- ✅ ECS task roles for application permissions

---

## 📊 Monitoring & Alerting

### **CloudWatch Alarms**
- **ECS CPU High**: >80% for 2 periods (10 minutes)
- **ECS Memory High**: >80% for 2 periods (10 minutes)
- **RDS CPU High**: >80% for 2 periods (10 minutes)

### **CloudWatch Dashboard**
- **ECS Service Metrics**: CPU, Memory, Request Count
- **RDS Database Metrics**: CPU, Connections, Storage
- **Application Metrics**: Custom application metrics

### **Logging**
- **ECS Application Logs**: `/ecs/accounts-client-service`
- **VPC Flow Logs**: Network traffic monitoring
- **RDS Logs**: Database performance monitoring

---

## 🚀 Deployment Information

### **Terragrunt Modules**
- **Total Modules**: 8
- **Deployment Script**: `deploy.ps1`
- **State Backend**: S3 with DynamoDB locking
- **Region**: eu-west-1

### **Resource Count Summary**
- **Total AWS Resources**: ~44 resources
- **VPC Resources**: ~15
- **Application Resources**: ~29

### **Estimated Deployment Time**
- **Full Deployment**: 15-20 minutes
- **Individual Modules**: 2-5 minutes each
- **Dependencies**: Properly managed for parallel deployment

---

## 📝 Notes

- **State Management**: All state stored in S3 with encryption
- **Tags**: All resources tagged for cost allocation
- **Compliance**: Follows AWS best practices
- **Scalability**: Designed for horizontal scaling
- **Backup**: RDS automated backups enabled
- **Monitoring**: Comprehensive CloudWatch integration

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Environment**: Cyprus  
**Region**: eu-west-1 