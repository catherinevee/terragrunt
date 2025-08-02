# Cyprus AWS Infrastructure - Accounts Client

This directory contains the complete AWS infrastructure for the Cyprus accounts-client project, managed with Terragrunt.

## 🏗️ Architecture Overview

The infrastructure consists of the following components:

### Core Infrastructure
- **VPC**: Multi-AZ VPC with public, private, and database subnets
- **RDS**: PostgreSQL database with encryption and backup
- **ECS**: Fargate cluster for containerized applications
- **ALB**: Application Load Balancer for traffic distribution
- **S3**: Storage for static assets and backups
- **CloudWatch**: Monitoring, logging, and alerting
- **IAM**: Roles and policies for service permissions

### Network Architecture
```
Internet
    ↓
ALB (Public Subnets)
    ↓
ECS Service (Private Subnets)
    ↓
RDS Database (Database Subnets)
```

## 📋 Resource Map

### **AWS Resources Created by Module**

| Module | AWS Resources | Resource Names | Purpose |
|--------|---------------|----------------|---------|
| **VPC** | VPC, Subnets, Route Tables, NAT Gateway, Internet Gateway | `cyprus-vpc`, `cyprus-vpc-public-*`, `cyprus-vpc-private-*`, `cyprus-vpc-database-*` | Network foundation |
| **S3** | S3 Bucket, Bucket Policy | `cyprus-accounts-client-{account-id}` | Data storage |
| **IAM** | IAM Roles, IAM Policies | `cyprus-ecs-task-execution-role`, `cyprus-ecs-task-role`, `cyprus-ecs-task-policy` | Service permissions |
| **RDS** | RDS Instance, Security Group, IAM Role, Parameter Group | `cyprus-accounts-client`, `cyprus-rds-sg`, `cyprus-rds-monitoring-role` | Database layer |
| **ALB** | Application Load Balancer, Target Group, Security Group, Listener | `cyprus-alb`, `cyprus-alb-sg`, `cyprus-alb-tg` | Load balancing |
| **ECS Cluster** | ECS Cluster, Capacity Providers | `cyprus-cluster` | Container orchestration |
| **ECS Service** | ECS Service, Task Definition, Security Group, Log Group | `accounts-client-service`, `cyprus-ecs-sg`, `/ecs/accounts-client-service` | Application deployment |
| **CloudWatch** | Log Groups, Metric Alarms, Dashboard | `/aws/cyprus/accounts-client`, `cyprus-ecs-cpu-high`, `cyprus-accounts-client-dashboard` | Monitoring & alerting |

### **Detailed Resource Breakdown**

#### **🔗 VPC Module Resources**
```
VPC: cyprus-vpc (10.0.0.0/16)
├── Public Subnets (3 AZs)
│   ├── eu-west-1a: 10.0.1.0/24
│   ├── eu-west-1b: 10.0.2.0/24
│   └── eu-west-1c: 10.0.3.0/24
├── Private Subnets (3 AZs)
│   ├── eu-west-1a: 10.0.11.0/24
│   ├── eu-west-1b: 10.0.12.0/24
│   └── eu-west-1c: 10.0.13.0/24
├── Database Subnets (3 AZs)
│   ├── eu-west-1a: 10.0.21.0/24
│   ├── eu-west-1b: 10.0.22.0/24
│   └── eu-west-1c: 10.0.23.0/24
├── NAT Gateways (3)
├── Internet Gateway
├── Route Tables (4)
└── VPC Flow Logs
```

#### **🗄️ S3 Module Resources**
```
S3 Bucket: cyprus-accounts-client-{account-id}
├── Versioning: Enabled
├── Encryption: AES256
├── Public Access: Blocked
└── Lifecycle Rules:
    ├── 30 days → STANDARD_IA
    ├── 90 days → GLACIER
    └── 365 days → DEEP_ARCHIVE
```

#### **🔐 IAM Module Resources**
```
IAM Roles:
├── cyprus-ecs-task-execution-role
│   ├── AmazonECSTaskExecutionRolePolicy
│   ├── S3 Access Policy
│   └── Secrets Manager Access Policy
└── cyprus-ecs-task-role
    ├── S3 Access Policy
    ├── Secrets Manager Access Policy
    └── CloudWatch Logs Policy
```

#### **🗃️ RDS Module Resources**
```
RDS Instance: cyprus-accounts-client
├── Engine: PostgreSQL 15.5
├── Instance: db.t3.micro
├── Storage: 20GB (encrypted)
├── Backup: 7 days retention
├── Security Group: cyprus-rds-sg
├── Monitoring Role: cyprus-rds-monitoring-role
└── Performance Insights: Enabled
```

#### **⚖️ ALB Module Resources**
```
Application Load Balancer: cyprus-alb
├── Type: Application Load Balancer
├── Scheme: Internet-facing
├── Security Group: cyprus-alb-sg
├── Target Group: cyprus-alb-tg
├── Listeners:
│   ├── HTTP (80) → HTTPS redirect
│   └── HTTPS (443) → Target Group
└── Health Check: /health (8080)
```

#### **🐳 ECS Cluster Module Resources**
```
ECS Cluster: cyprus-cluster
├── Capacity Providers:
│   ├── FARGATE
│   └── FARGATE_SPOT
├── Container Insights: Enabled
└── Cluster Settings: Configured
```

#### **🚀 ECS Service Module Resources**
```
ECS Service: accounts-client-service
├── Task Definition: accounts-client
├── CPU: 256
├── Memory: 512MB
├── Desired Count: 2
├── Security Group: cyprus-ecs-sg
├── Log Group: /ecs/accounts-client-service
├── Auto Scaling: Enabled
└── Load Balancer Integration: ALB
```

#### **📊 CloudWatch Module Resources**
```
CloudWatch Resources:
├── Log Group: /aws/cyprus/accounts-client
├── Metric Alarms:
│   ├── cyprus-ecs-cpu-high (80% threshold)
│   ├── cyprus-ecs-memory-high (80% threshold)
│   └── cyprus-rds-cpu-high (80% threshold)
└── Dashboard: cyprus-accounts-client-dashboard
    ├── ECS Service Metrics
    └── RDS Database Metrics
```

### **🔗 Resource Dependencies**

```
VPC (Foundation)
├── S3 (Independent)
├── IAM (Independent)
├── RDS (Depends on VPC)
├── ALB (Depends on VPC)
├── ECS Cluster (Independent)
├── ECS Service (Depends on VPC, ALB, ECS Cluster, RDS)
└── CloudWatch (Independent)
```

### **💰 Estimated Monthly Costs**

| Service | Resource | Estimated Cost |
|---------|----------|----------------|
| **VPC** | NAT Gateways (3) | ~$45 |
| **RDS** | db.t3.micro | ~$15 |
| **ECS** | Fargate (2 tasks) | ~$30 |
| **ALB** | Application Load Balancer | ~$20 |
| **S3** | Storage + requests | ~$5 |
| **CloudWatch** | Logs + metrics | ~$10 |
| **Total** | | **~$125/month** |

*Note: Costs are estimates and may vary based on usage patterns.*

## 📁 Directory Structure

```
eu-west-1/
├── root.hcl                 # Root configuration
├── region.hcl               # Region-specific variables
├── deploy.ps1               # Deployment script
├── README.md                # This file
├── .gitignore               # Git ignore rules
├── vpc/                     # VPC and networking
│   └── terragrunt.hcl
├── s3/                      # S3 buckets
│   └── terragrunt.hcl
├── iam/                     # IAM roles and policies
│   └── terragrunt.hcl
├── rds/                     # RDS database
│   └── terragrunt.hcl
├── alb/                     # Application Load Balancer
│   └── terragrunt.hcl
├── ecs-cluster/             # ECS cluster
│   └── terragrunt.hcl
├── ecs-service/             # ECS service
│   └── terragrunt.hcl
└── cloudwatch/              # Monitoring and alerting
    └── terragrunt.hcl
```

**Note**: This structure follows the "split state by service boundaries" best practice, with separate modules for the ECS cluster and service.

## 🚀 Quick Start

### Prerequisites

1. **Terragrunt**: Install Terragrunt v0.54.0 or later
   ```bash
   # Windows (Chocolatey)
   choco install terragrunt
   
   # Or download from: https://terragrunt.gruntwork.io/docs/getting-started/install/
   ```

2. **AWS CLI**: Install and configure AWS CLI
   ```bash
   aws configure
   ```

3. **Terraform**: Version 1.13.0 or later
   ```bash
   # Windows (Chocolatey)
   choco install terraform
   ```

### Configuration

1. **Update Account Configuration**
   Edit `../account.hcl` and update:
   - `aws_account_id`: Your AWS account ID
   - `aws_account_role`: IAM role ARN for Terragrunt
   - `company`: Your company name

2. **Update Region Configuration**
   Edit `../region.hcl` if you need to change the region (default: eu-west-1)

### Deployment

#### Option 1: Using the Deployment Script (Recommended)

```powershell
# Plan all modules
.\deploy.ps1 -Action plan

# Apply all modules
.\deploy.ps1 -Action apply

# Deploy specific module
.\deploy.ps1 -Action apply -Module vpc

# Validate configuration
.\deploy.ps1 -Action validate

# Destroy infrastructure (use with caution)
.\deploy.ps1 -Action destroy
```

#### Option 2: Manual Deployment

```bash
# Navigate to the eu-west-1 directory
cd terragrunt/aws/accounts-client/cyprus/eu-west-1

# Deploy modules in order
cd vpc && terragrunt apply && cd ..
cd s3 && terragrunt apply && cd ..
cd iam && terragrunt apply && cd ..
cd rds && terragrunt apply && cd ..
cd alb && terragrunt apply && cd ..
cd ecs-cluster && terragrunt apply && cd ..
cd ecs-service && terragrunt apply && cd ..
cd cloudwatch && terragrunt apply && cd ..
```

## 🔧 Module Details

### VPC Module
- **Source**: `terraform-aws-modules/vpc/aws`
- **Version**: 5.8.1
- **Features**:
  - Multi-AZ deployment (3 AZs)
  - Public, private, and database subnets
  - NAT Gateway for private subnet internet access
  - VPC Flow Logs enabled
  - DNS hostnames and support enabled

### RDS Module
- **Source**: `terraform-aws-modules/rds/aws`
- **Version**: 6.8.0
- **Features**:
  - PostgreSQL 15.5
  - Encryption at rest
  - Automated backups (7 days retention)
  - Performance Insights enabled
  - Enhanced monitoring
  - Deletion protection enabled

### ECS Modules
- **Source**: `terraform-aws-modules/ecs/aws`
- **Version**: 5.7.4
- **Features**:
  - **ecs-cluster**: Fargate cluster with Container Insights
  - **ecs-service**: Auto-scaling capabilities with load balancer integration
  - CloudWatch logging
  - Secrets management integration

### ALB Module
- **Source**: `terraform-aws-modules/alb/aws`
- **Version**: 9.9.2
- **Features**:
  - HTTP to HTTPS redirect
  - Health checks
  - Target group for ECS service
  - Security groups configured

### S3 Module
- **Source**: `terraform-aws-modules/s3-bucket/aws`
- **Version**: 4.1.2
- **Features**:
  - Versioning enabled
  - Server-side encryption
  - Public access blocked
  - Lifecycle policies for cost optimization

### CloudWatch Module
- **Source**: `terraform-aws-modules/cloudwatch/aws`
- **Version**: 4.3.2
- **Features**:
  - Log groups with retention policies
  - CPU and memory alarms for ECS
  - RDS monitoring alarms
  - Custom dashboard

### IAM Module
- **Source**: `terraform-aws-modules/iam/aws`
- **Version**: 5.30.0
- **Features**:
  - ECS task execution role
  - ECS task role with S3 and Secrets access
  - Least privilege principle applied

## 🔐 Security Features

- **Encryption**: All data encrypted at rest and in transit
- **Network Security**: Private subnets for application and database
- **IAM**: Role-based access with least privilege
- **Secrets**: AWS Secrets Manager for sensitive data
- **Monitoring**: Comprehensive CloudWatch monitoring and alerting

## 📊 Monitoring and Alerting

### CloudWatch Alarms
- ECS CPU utilization > 80%
- ECS Memory utilization > 80%
- RDS CPU utilization > 80%

### CloudWatch Dashboard
- ECS service metrics
- RDS database metrics
- Application performance monitoring

## 💰 Cost Optimization

- **S3 Lifecycle**: Automatic transition to cheaper storage classes
- **RDS**: Right-sized instance types
- **ECS**: Fargate Spot for cost savings
- **NAT Gateway**: Single NAT Gateway option available

## 🔄 Maintenance

### Regular Tasks
1. **Security Updates**: Keep Terraform modules updated
2. **Backup Verification**: Test RDS backup restoration
3. **Monitoring Review**: Check CloudWatch alarms and metrics
4. **Cost Review**: Monitor AWS costs and optimize

### Scaling
- **ECS**: Auto-scaling based on CPU/memory metrics
- **RDS**: Manual scaling (consider Aurora for auto-scaling)
- **ALB**: Automatic scaling based on traffic

## 🚨 Troubleshooting

### Common Issues

1. **Terragrunt State Lock**
   ```bash
   # Check DynamoDB table
   aws dynamodb describe-table --table-name terragrunt-locks
   ```

2. **ECS Service Not Starting**
   - Check ECS task logs in CloudWatch
   - Verify IAM roles and policies
   - Check security group rules

3. **RDS Connection Issues**
   - Verify security group allows ECS traffic
   - Check VPC and subnet configuration
   - Verify database credentials in Secrets Manager

### Useful Commands

```bash
# Check Terragrunt status
terragrunt plan-all

# Validate configuration
terragrunt validate-all

# Show outputs
terragrunt output-all

# Check AWS resources
aws ecs list-services --cluster cyprus-cluster
aws rds describe-db-instances --db-instance-identifier cyprus-accounts-client
```

## 📝 Notes

- **State Management**: Remote state stored in S3 with DynamoDB locking
- **Dependencies**: Modules have proper dependency management
- **Tags**: All resources tagged for cost allocation and management
- **Compliance**: Infrastructure follows AWS best practices
- **Input Validation**: Comprehensive validation implemented for all modules

## 🤝 Contributing

1. Follow the existing naming conventions
2. Update documentation for any changes
3. Test changes in a development environment first
4. Use semantic versioning for module updates

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Check Terragrunt logs and outputs
4. Contact the infrastructure team

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Terraform Version**: 1.13.0
**AWS Provider Version**: 6.2.0 