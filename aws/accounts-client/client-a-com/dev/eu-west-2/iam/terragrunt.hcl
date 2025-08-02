# ==============================================================================
# IAM Module Configuration for Client A - Development Environment (eu-west-2)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "common" {
  path = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/iam.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.region.locals.environment
  region      = include.region.locals.region_name
  account_id  = include.common.locals.account_id
  client_name = include.common.locals.client_name
  project     = "IAM Management - Development (eu-west-2)"
  
  # IAM configuration for development environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientA"
    environment_name  = "development"
    project_name      = "IAM Management"
    
    # IAM users configuration
    create_users = true
    users = {
      # Developer user
      developer = {
        username = "developer-dev"
        path = "/users/developers/"
        groups = ["developers"]
        tags = {
          Role = "Developer"
          Department = "Engineering"
          AccessLevel = "Standard"
          Environment = "Development"
        }
      }
      
      # DevOps user
      devops = {
        username = "devops-dev"
        path = "/users/devops/"
        groups = ["devops", "developers"]
        tags = {
          Role = "DevOps Engineer"
          Department = "DevOps"
          AccessLevel = "Elevated"
          Environment = "Development"
        }
      }
      
      # Admin user
      admin = {
        username = "admin-dev"
        path = "/users/admins/"
        groups = ["admins", "devops"]
        tags = {
          Role = "Administrator"
          Department = "IT"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
    }
    
    # IAM groups configuration
    create_groups = true
    groups = {
      # Developers group
      developers = {
        name = "developers"
        path = "/groups/"
        tags = {
          Purpose = "Development Access"
          Environment = "Development"
          GroupType = "Standard"
        }
      }
      
      # DevOps group
      devops = {
        name = "devops"
        path = "/groups/"
        tags = {
          Purpose = "DevOps Access"
          Environment = "Development"
          GroupType = "Elevated"
        }
      }
      
      # Admins group
      admins = {
        name = "admins"
        path = "/groups/"
        tags = {
          Purpose = "Administrative Access"
          Environment = "Development"
          GroupType = "Admin"
        }
      }
    }
    
    # IAM roles configuration
    create_roles = true
    roles = {
      # EC2 instance role
      ec2_instance_role = {
        name = "client-a-dev-ec2-instance-role"
        description = "Role for EC2 instances in Client A development environment"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "ec2.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        ]
        tags = {
          Purpose = "EC2 Instance Role"
          Environment = "Development"
          RoleType = "Service"
        }
      }
      
      # Lambda execution role
      lambda_execution_role = {
        name = "client-a-dev-lambda-execution-role"
        description = "Role for Lambda functions in Client A development environment"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "lambda.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        ]
        tags = {
          Purpose = "Lambda Execution Role"
          Environment = "Development"
          RoleType = "Service"
        }
      }
      
      # RDS monitoring role
      rds_monitoring_role = {
        name = "client-a-dev-rds-monitoring-role"
        description = "Role for RDS monitoring in Client A development environment"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                Service = "monitoring.rds.amazonaws.com"
              }
              Action = "sts:AssumeRole"
            }
          ]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
        ]
        tags = {
          Purpose = "RDS Monitoring Role"
          Environment = "Development"
          RoleType = "Service"
        }
      }
    }
    
    # IAM policies configuration
    create_policies = true
    policies = {
      # Developer policy
      developer_policy = {
        name = "client-a-dev-developer-policy"
        description = "Policy for developers in Client A development environment"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:Describe*",
                "ec2:Get*",
                "ec2:List*",
                "s3:GetObject",
                "s3:ListBucket",
                "cloudwatch:GetMetricData",
                "cloudwatch:DescribeAlarms",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
              ]
              Resource = "*"
            },
            {
              Effect = "Deny"
              Action = [
                "ec2:Delete*",
                "ec2:Terminate*",
                "s3:Delete*",
                "rds:Delete*",
                "iam:Delete*"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose = "Developer Access"
          Environment = "Development"
          PolicyType = "Standard"
        }
      }
      
      # DevOps policy
      devops_policy = {
        name = "client-a-dev-devops-policy"
        description = "Policy for DevOps engineers in Client A development environment"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:*",
                "s3:*",
                "rds:*",
                "elasticache:*",
                "cloudwatch:*",
                "logs:*",
                "iam:Get*",
                "iam:List*",
                "iam:PassRole"
              ]
              Resource = "*"
            },
            {
              Effect = "Deny"
              Action = [
                "iam:DeleteRole",
                "iam:DeletePolicy",
                "iam:DeleteUser",
                "iam:DeleteGroup"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose = "DevOps Access"
          Environment = "Development"
          PolicyType = "Elevated"
        }
      }
    }
  }
  
  # Tags for all IAM resources
  tags = {
    Environment = "Development"
    Project     = "Client A Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    Client      = "Client A"
  }
} 