# ==============================================================================
# IAM Module Configuration for Client B - Production Environment
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
  project     = "IAM Management - Production"
  
  # IAM specific configuration for production environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "production"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # Production team users
      "prod-admin" = {
        username = "prod-admin"
        path     = "/users/prod/"
        groups   = ["ProdAdmins", "SystemOperatorsProd"]
        tags = {
          Role        = "Production Administrator"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Production"
        }
      }
      
      "prod-engineer" = {
        username = "prod-engineer"
        path     = "/users/prod/"
        groups   = ["ProdEngineers", "SystemOperatorsProd"]
        tags = {
          Role        = "Production Engineer"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Production"
        }
      }
      
      "prod-operator" = {
        username = "prod-operator"
        path     = "/users/prod/"
        groups   = ["ProdOperators", "ReadOnlyAccess"]
        tags = {
          Role        = "Production Operator"
          Department  = "Operations"
          AccessLevel = "ReadOnly"
          Environment = "Production"
        }
      }
      
      # Application users (production access)
      "app-service-account-prod" = {
        username = "app-service-account-prod"
        path     = "/users/applications/prod/"
        groups   = ["ApplicationUsersProd", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account - Production"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Production"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      "ProdAdmins" = {
        group_name = "ProdAdmins"
        path       = "/groups/prod/"
        tags = {
          Purpose     = "Production Administrators"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Production"
        }
      }
      
      "ProdEngineers" = {
        group_name = "ProdEngineers"
        path       = "/groups/prod/"
        tags = {
          Purpose     = "Production Engineers"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Production"
        }
      }
      
      "ProdOperators" = {
        group_name = "ProdOperators"
        path       = "/groups/prod/"
        tags = {
          Purpose     = "Production Operators"
          Department  = "Operations"
          AccessLevel = "ReadOnly"
          Environment = "Production"
        }
      }
      
      "ApplicationUsersProd" = {
        group_name = "ApplicationUsersProd"
        path       = "/groups/applications/prod/"
        tags = {
          Purpose     = "Application Users - Production"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Production"
        }
      }
      
      "SystemOperatorsProd" = {
        group_name = "SystemOperatorsProd"
        path       = "/groups/operations/prod/"
        tags = {
          Purpose     = "System Operators - Production"
          Department  = "Operations"
          AccessLevel = "Operator"
          Environment = "Production"
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
      "ProdEC2Role" = {
        role_name = "ProdEC2Role"
        path      = "/roles/prod/"
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
          Purpose     = "EC2 Instance Role - Production"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Production"
        }
      }
      
      "ProdLambdaRole" = {
        role_name = "ProdLambdaRole"
        path      = "/roles/prod/"
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
          Purpose     = "Lambda Function Role - Production"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Production"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      "ProdAdminPolicy" = {
        policy_name = "ProdAdminPolicy"
        path        = "/policies/prod/"
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
          Purpose     = "Production Administrator Policy"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Production"
        }
      }
      
      "ProdEngineerPolicy" = {
        policy_name = "ProdEngineerPolicy"
        path        = "/policies/prod/"
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
          Purpose     = "Production Engineer Policy"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Production"
        }
      }
      
      "ProdReadOnlyPolicy" = {
        policy_name = "ProdReadOnlyPolicy"
        path        = "/policies/prod/"
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
          Purpose     = "Production Read-Only Policy"
          Department  = "All"
          AccessLevel = "ReadOnly"
          Environment = "Production"
        }
      }
    }
    
    # Group policy attachments
    group_policy_attachments = {
      "ProdAdmins" = ["ProdAdminPolicy"]
      "ProdEngineers" = ["ProdEngineerPolicy"]
      "ProdOperators" = ["ProdReadOnlyPolicy"]
      "ApplicationUsersProd" = ["ProdReadOnlyPolicy"]
      "SystemOperatorsProd" = ["ProdEngineerPolicy"]
      "ReadOnlyAccess" = ["ProdReadOnlyPolicy"]
    }
    
    # Role policy attachments
    role_policy_attachments = {
      "ProdEC2Role" = ["AmazonEC2ReadOnlyAccess", "ProdEngineerPolicy"]
      "ProdLambdaRole" = ["AWSLambdaBasicExecutionRole", "ProdReadOnlyPolicy"]
    }
  }
} 