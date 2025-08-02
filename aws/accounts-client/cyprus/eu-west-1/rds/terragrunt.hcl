include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  rds_config   = local.account_vars.locals.rds_config
  
  # Input validation for RDS module
  validate_rds_identifier = length("cyprus-accounts-client") <= 63 ? null : file("ERROR: RDS identifier must be <= 63 characters")
  validate_rds_identifier_format = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", "cyprus-accounts-client")) ? null : file("ERROR: RDS identifier must be lowercase, alphanumeric with hyphens")
  validate_rds_instance_class = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", local.rds_config.instance_class)) ? null : file("ERROR: Invalid RDS instance class format")
  validate_rds_storage = local.rds_config.allocated_storage >= 20 && local.rds_config.allocated_storage <= 65536 ? null : file("ERROR: RDS storage must be between 20 and 65536 GB")
  validate_rds_backup_retention = local.rds_config.backup_retention_period >= 0 && local.rds_config.backup_retention_period <= 35 ? null : file("ERROR: Backup retention must be between 0 and 35 days")
  validate_rds_engine_version = can(regex("^[0-9]+\\.[0-9]+$", local.rds_config.engine_version)) ? null : file("ERROR: Invalid engine version format")
  validate_rds_family = can(regex("^postgres[0-9]+$", local.rds_config.family)) ? null : file("ERROR: Invalid parameter group family")
  validate_rds_db_name = length("accounts_client") <= 63 ? null : file("ERROR: Database name must be <= 63 characters")
  validate_rds_username = length("db_admin") <= 16 ? null : file("ERROR: Database username must be <= 16 characters")
  validate_rds_username_format = can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", "db_admin")) ? null : file("ERROR: Database username must start with letter or underscore")
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id             = "vpc-mock"
    database_subnets   = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
    private_subnets    = ["subnet-mock-4", "subnet-mock-5", "subnet-mock-6"]
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
  engine_version       = local.rds_config.engine_version
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
  family = local.rds_config.family
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "application-database"
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
    Purpose     = "database-access"
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
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "rds-monitoring"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ECS Security Group (referenced by RDS)
resource "aws_security_group" "ecs" {
  name_prefix = "cyprus-ecs-"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "cyprus-ecs-sg"
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "application-access"
  }
} 