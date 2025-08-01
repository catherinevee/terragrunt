# ==============================================================================
# IAM Module Configuration for Client B - Staging Environment
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
  project     = "IAM Management - Staging"
  
  # IAM specific configuration for staging environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "staging"
    project_name      = "IAM Management"
    
    # IAM user configuration
    create_iam_users = true
    iam_users = {
      # Staging team users
      "staging-admin" = {
        username = "staging-admin"
        path     = "/users/staging/"
        groups   = ["StagingAdmins", "SystemOperatorsStaging"]
        tags = {
          Role        = "Staging Administrator"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Staging"
        }
      }
      
      "staging-engineer" = {
        username = "staging-engineer"
        path     = "/users/staging/"
        groups   = ["StagingEngineers", "SystemOperatorsStaging"]
        tags = {
          Role        = "Staging Engineer"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
      
      "staging-tester" = {
        username = "staging-tester"
        path     = "/users/staging/"
        groups   = ["StagingTesters", "ReadOnlyAccess"]
        tags = {
          Role        = "Staging Tester"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      # Application users (staging access)
      "app-service-account-staging" = {
        username = "app-service-account-staging"
        path     = "/users/applications/staging/"
        groups   = ["ApplicationUsersStaging", "ReadOnlyAccess"]
        tags = {
          Role        = "Application Service Account - Staging"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
    }
    
    # IAM group configuration
    create_iam_groups = true
    iam_groups = {
      "StagingAdmins" = {
        group_name = "StagingAdmins"
        path       = "/groups/staging/"
        tags = {
          Purpose     = "Staging Administrators"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Staging"
        }
      }
      
      "StagingEngineers" = {
        group_name = "StagingEngineers"
        path       = "/groups/staging/"
        tags = {
          Purpose     = "Staging Engineers"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
      
      "StagingTesters" = {
        group_name = "StagingTesters"
        path       = "/groups/staging/"
        tags = {
          Purpose     = "Staging Testers"
          Department  = "QA"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      "ApplicationUsersStaging" = {
        group_name = "ApplicationUsersStaging"
        path       = "/groups/applications/staging/"
        tags = {
          Purpose     = "Application Users - Staging"
          Department  = "Engineering"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
      
      "SystemOperatorsStaging" = {
        group_name = "SystemOperatorsStaging"
        path       = "/groups/operations/staging/"
        tags = {
          Purpose     = "System Operators - Staging"
          Department  = "Operations"
          AccessLevel = "Operator"
          Environment = "Staging"
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
      "StagingEC2Role" = {
        role_name = "StagingEC2Role"
        path      = "/roles/staging/"
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
          Purpose     = "EC2 Instance Role - Staging"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
      
      "StagingLambdaRole" = {
        role_name = "StagingLambdaRole"
        path      = "/roles/staging/"
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
          Purpose     = "Lambda Function Role - Staging"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
    }
    
    # IAM policy configuration
    create_iam_policies = true
    iam_policies = {
      "StagingAdminPolicy" = {
        policy_name = "StagingAdminPolicy"
        path        = "/policies/staging/"
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
          Purpose     = "Staging Administrator Policy"
          Department  = "Engineering"
          AccessLevel = "Admin"
          Environment = "Staging"
        }
      }
      
      "StagingEngineerPolicy" = {
        policy_name = "StagingEngineerPolicy"
        path        = "/policies/staging/"
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
          Purpose     = "Staging Engineer Policy"
          Department  = "Engineering"
          AccessLevel = "Operator"
          Environment = "Staging"
        }
      }
      
      "StagingReadOnlyPolicy" = {
        policy_name = "StagingReadOnlyPolicy"
        path        = "/policies/staging/"
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
          Purpose     = "Staging Read-Only Policy"
          Department  = "All"
          AccessLevel = "ReadOnly"
          Environment = "Staging"
        }
      }
    }
    
    # Group policy attachments
    group_policy_attachments = {
      "StagingAdmins" = ["StagingAdminPolicy"]
      "StagingEngineers" = ["StagingEngineerPolicy"]
      "StagingTesters" = ["StagingReadOnlyPolicy"]
      "ApplicationUsersStaging" = ["StagingReadOnlyPolicy"]
      "SystemOperatorsStaging" = ["StagingEngineerPolicy"]
      "ReadOnlyAccess" = ["StagingReadOnlyPolicy"]
    }
    
    # Role policy attachments
    role_policy_attachments = {
      "StagingEC2Role" = ["AmazonEC2ReadOnlyAccess", "StagingEngineerPolicy"]
      "StagingLambdaRole" = ["AWSLambdaBasicExecutionRole", "StagingReadOnlyPolicy"]
    }
  }
} 