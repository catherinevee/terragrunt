include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  rds_config   = local.account_vars.locals.rds_config
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id             = "vpc-mock"
    database_subnets   = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
    private_subnets    = ["subnet-mock-4", "subnet-mock-5", "subnet-mock-6"]
    vpc_cidr_block     = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/rds/aws//?version=6.8.0"
}

inputs = {
  identifier = "cyprus-accounts-client"
  
  # Engine configuration
  engine               = "postgres"
  engine_version       = "15.5"
  instance_class       = local.rds_config.instance_class
  allocated_storage    = local.rds_config.allocated_storage
  
  # Database configuration
  db_name  = "accounts_client"
  username = "db_admin"
  
  # Security configuration
  storage_encrypted = local.rds_config.storage_encrypted
  manage_master_user_password = true
  master_user_secret_kms_key_id = "alias/aws/secretsmanager"
  
  # Network configuration
  vpc_security_group_ids = [aws_security_group.rds.id]
  subnet_ids             = dependency.vpc.outputs.database_subnets
  
  # Backup configuration
  backup_retention_period = local.rds_config.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Deletion protection
  deletion_protection = local.rds_config.deletion_protection
  skip_final_snapshot = local.rds_config.skip_final_snapshot
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  
  # Performance Insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  # Parameter group
  family = "postgres15"
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "cyprus-rds-"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "cyprus-rds-sg"
    Environment = "cyprus"
    Project     = "accounts-client"
  }
}

# IAM Role for RDS Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "cyprus-rds-monitoring-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
} 