# ==============================================================================
# IAM Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
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

# Dependencies (uncomment and configure as needed)
# dependency "vpc" {
#   config_path = "../network"
# }
# 
# dependency "s3" {
#   config_path = "../storage"
# }

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "IAM Management - Development"
  
  # IAM specific configuration for development environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # Development team users
      "dev-admin" = {
        username = "dev-admin"
        path     = "/users/dev/"
        groups   = ["DevAdmins", "SystemOperatorsDev"]
        tags = {
          Role        = "Development Administrator"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
      
      "dev-engineer" = {
        username = "dev-engineer"
        path     = "/users/dev/"
        groups   = ["DevEngineers", "SystemOperatorsDev"]
        tags = {
          Role        = "Development Engineer"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "dev-tester" = {
        username = "dev-tester"
        path     = "/users/dev/"
        groups   = ["DevTesters", "ReadOnlyAccess"]
        tags = {
          Role        = "Development Tester"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      # Application users (development access)
      "app-service-account-dev" = {
        username = "app-service-account-dev"
        path     = "/users/applications/dev/"
        groups   = ["ApplicationUsersDev", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account - Dev"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      "DevAdmins" = {
        group_name = "DevAdmins"
        path       = "/groups/dev/"
        tags = {
          Purpose     = "Development Administrators"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
      
      "DevEngineers" = {
        group_name = "DevEngineers"
        path       = "/groups/dev/"
        tags = {
          Purpose     = "Development Engineers"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "DevTesters" = {
        group_name = "DevTesters"
        path       = "/groups/dev/"
        tags = {
          Purpose     = "Development Testers"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      "ApplicationUsersDev" = {
        group_name = "ApplicationUsersDev"
        path       = "/groups/applications/dev/"
        tags = {
          Purpose     = "Application Users - Development"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
      
      "SystemOperatorsDev" = {
        group_name = "SystemOperatorsDev"
        path       = "/groups/operations/dev/"
        tags = {
          Purpose     = "System Operators - Development"
          Department  = "Operations"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "ReadOnlyAccess" = {
        group_name = "ReadOnlyAccess"
        path       = "/groups/common/"
        tags = {
          Purpose     = "Read-Only Access"
          Department  = "All"
          AccessLevel = "ReadOnly"
          Environment = "All"
        }
      }
    }
    
    # IAM role configuration
    create_iam_roles = true
    iam_roles = {
      "DevEC2Role" = {
        role_name = "DevEC2Role"
        path      = "/roles/dev/"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Action = "sts:AssumeRole"
              Effect = "Allow"
              Principal = {
                Service = "ec2.amazonaws.com"
              }
            }
          ]
        })
        tags = {
          Purpose     = "EC2 Instance Role - Development"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "DevLambdaRole" = {
        role_name = "DevLambdaRole"
        path      = "/roles/dev/"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Action = "sts:AssumeRole"
              Effect = "Allow"
              Principal = {
                Service = "lambda.amazonaws.com"
              }
            }
          ]
        })
        tags = {
          Purpose     = "Lambda Function Role - Development"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      "DevAdminPolicy" = {
        policy_name = "DevAdminPolicy"
        path        = "/policies/dev/"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:*",
                "s3:*",
                "iam:Get*",
                "iam:List*"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose     = "Development Administrator Policy"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
      
      "DevEngineerPolicy" = {
        policy_name = "DevEngineerPolicy"
        path        = "/policies/dev/"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:Describe*",
                "ec2:Get*",
                "ec2:List*",
                "s3:Get*",
                "s3:List*",
                "s3:Put*",
                "s3:Delete*"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose     = "Development Engineer Policy"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Development"
        }
      }
      
      "DevReadOnlyPolicy" = {
        policy_name = "DevReadOnlyPolicy"
        path        = "/policies/dev/"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:Describe*",
                "ec2:Get*",
                "ec2:List*",
                "s3:Get*",
                "s3:List*"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose     = "Development Read-Only Policy"
          Department  = "All"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
    }
    
    # Group policy attachments
    group_policy_attachments = {
      "DevAdmins" = ["DevAdminPolicy"]
      "DevEngineers" = ["DevEngineerPolicy"]
      "DevTesters" = ["DevReadOnlyPolicy"]
      "ApplicationUsersDev" = ["DevReadOnlyPolicy"]
      "SystemOperatorsDev" = ["DevEngineerPolicy"]
      "ReadOnlyAccess" = ["DevReadOnlyPolicy"]
    }
    
    # Role policy attachments
    role_policy_attachments = {
      "DevEC2Role" = ["AmazonEC2ReadOnlyAccess", "DevEngineerPolicy"]
      "DevLambdaRole" = ["AWSLambdaBasicExecutionRole", "DevReadOnlyPolicy"]
    }
  }
} 