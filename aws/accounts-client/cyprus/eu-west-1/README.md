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

## 📁 Directory Structure

```
eu-west-1/
├── root.hcl                 # Root configuration
├── account.hcl              # Account-specific variables
├── region.hcl               # Region-specific variables
├── deploy.ps1               # Deployment script
├── README.md                # This file
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
   Edit `account.hcl` and update:
   - `aws_account_id`: Your AWS account ID
   - `aws_account_role`: IAM role ARN for Terragrunt
   - `company`: Your company name

2. **Update Region Configuration**
   Edit `region.hcl` if you need to change the region (default: eu-west-1)

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
  - Fargate cluster with Container Insights
  - Auto-scaling capabilities
  - Load balancer integration
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