include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  
  # Input validation for IAM module
  validate_role_name_length = length("cyprus-ecs-task-execution-role") <= 64 ? null : file("ERROR: IAM role name must be <= 64 characters")
  validate_role_name_format = can(regex("^[a-zA-Z0-9+=,.@_-]+$", "cyprus-ecs-task-execution-role")) ? null : file("ERROR: IAM role name must contain only alphanumeric characters and special characters: +=,.@_-")
  validate_role_name_no_prefix = !can(regex("^AWS", "cyprus-ecs-task-execution-role")) ? null : file("ERROR: IAM role name cannot start with 'AWS'")
  validate_policy_name_length = length("cyprus-ecs-task-policy") <= 128 ? null : file("ERROR: IAM policy name must be <= 128 characters")
  validate_policy_name_format = can(regex("^[a-zA-Z0-9+=,.@_-]+$", "cyprus-ecs-task-policy")) ? null : file("ERROR: IAM policy name must contain only alphanumeric characters and special characters: +=,.@_-")
}

terraform {
  source = "tfr://terraform-aws-modules/iam/aws//modules/iam-role?version=5.30.0"
}

inputs = {
  role_name = "cyprus-ecs-task-execution-role"
  
  create_role = true
  role_requires_mfa = false
  
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  
  inline_policies = {
    s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = [
            "arn:aws:s3:::cyprus-accounts-client-${local.account_vars.locals.aws_account_id}/*"
          ]
        }
      ]
    })
    
    secrets_access = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = [
            "arn:aws:secretsmanager:eu-west-1:${local.account_vars.locals.aws_account_id}:secret:cyprus-accounts-client-*"
          ]
        }
      ]
    })
  }
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "task-execution"
  }
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "cyprus-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "task-permissions"
  }
}

# ECS Task Role Policy
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "cyprus-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::cyprus-accounts-client-${local.account_vars.locals.aws_account_id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-1:${local.account_vars.locals.aws_account_id}:secret:cyprus-accounts-client-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:eu-west-1:${local.account_vars.locals.aws_account_id}:log-group:/ecs/accounts-client-service:*"
        ]
      }
    ]
  })
} 