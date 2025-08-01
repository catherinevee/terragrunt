# ==============================================================================
# IAM Module Configuration for Client B - Development Environment (eu-west-2)
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

inputs = {
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "IAM Management - Development (eu-west-2)"
  
  iam_config = {
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "IAM Management"
    create_iam_users = true
    
    iam_users = {
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
      
      "dev-developer" = {
        username = "dev-developer"
        path     = "/users/dev/"
        groups   = ["DevDevelopers", "SystemOperatorsDev"]
        tags = {
          Role        = "Development Developer"
          Department  = "Engineering"
          AccessLevel = "Developer"
          Environment = "Development"
        }
      }
      
      "dev-tester" = {
        username = "dev-tester"
        path     = "/users/dev/"
        groups   = ["DevTesters"]
        tags = {
          Role        = "Development Tester"
          Department  = "QA"
          AccessLevel = "Tester"
          Environment = "Development"
        }
      }
    }
    
    iam_groups = {
      "DevAdmins" = {
        name = "DevAdmins"
        path = "/groups/dev/"
        tags = {
          Purpose     = "Development Administrators"
          Environment = "Development"
          AccessLevel = "Admin"
        }
      }
      
      "DevDevelopers" = {
        name = "DevDevelopers"
        path = "/groups/dev/"
        tags = {
          Purpose     = "Development Developers"
          Environment = "Development"
          AccessLevel = "Developer"
        }
      }
      
      "DevTesters" = {
        name = "DevTesters"
        path = "/groups/dev/"
        tags = {
          Purpose     = "Development Testers"
          Environment = "Development"
          AccessLevel = "Tester"
        }
      }
      
      "SystemOperatorsDev" = {
        name = "SystemOperatorsDev"
        path = "/groups/dev/"
        tags = {
          Purpose     = "Development System Operators"
          Environment = "Development"
          AccessLevel = "Operator"
        }
      }
    }
    
    iam_roles = {
      "DevEcommerceRole" = {
        name = "DevEcommerceRole"
        path = "/roles/dev/"
        assume_role_policy = {
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
        }
        tags = {
          Purpose     = "Ecommerce Application Role"
          Environment = "Development"
          Service     = "Ecommerce"
        }
      }
      
      "DevMonitoringRole" = {
        name = "DevMonitoringRole"
        path = "/roles/dev/"
        assume_role_policy = {
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
        }
        tags = {
          Purpose     = "Monitoring Role"
          Environment = "Development"
          Service     = "Monitoring"
        }
      }
    }
    
    iam_policies = {
      "DevEcommercePolicy" = {
        name = "DevEcommercePolicy"
        path = "/policies/dev/"
        description = "Policy for ecommerce application in development environment"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
              ]
              Resource = "arn:aws:s3:::client-b-dev-*/*"
            },
            {
              Effect = "Allow"
              Action = [
                "rds:DescribeDBInstances",
                "rds:DescribeDBClusters"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "elasticache:DescribeCacheClusters",
                "elasticache:DescribeReplicationGroups"
              ]
              Resource = "*"
            }
          ]
        }
        tags = {
          Purpose     = "Ecommerce Application Policy"
          Environment = "Development"
          Service     = "Ecommerce"
        }
      }
      
      "DevMonitoringPolicy" = {
        name = "DevMonitoringPolicy"
        path = "/policies/dev/"
        description = "Policy for monitoring services in development environment"
        policy = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricData",
                "cloudwatch:ListMetrics"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ]
              Resource = "arn:aws:logs:eu-west-2:*:log-group:/aws/applicationloadbalancer/*"
            }
          ]
        }
        tags = {
          Purpose     = "Monitoring Policy"
          Environment = "Development"
          Service     = "Monitoring"
        }
      }
    }
    
    group_memberships = {
      "dev-admin-group" = {
        group = "DevAdmins"
        users = ["dev-admin"]
      }
      "dev-developer-group" = {
        group = "DevDevelopers"
        users = ["dev-developer"]
      }
      "dev-tester-group" = {
        group = "DevTesters"
        users = ["dev-tester"]
      }
      "dev-operator-group" = {
        group = "SystemOperatorsDev"
        users = ["dev-admin", "dev-developer"]
      }
    }
    
    role_policy_attachments = {
      "dev-ecommerce-policy" = {
        role       = "DevEcommerceRole"
        policy_arn = "arn:aws:iam::aws:policy/DevEcommercePolicy"
      }
      "dev-monitoring-policy" = {
        role       = "DevMonitoringRole"
        policy_arn = "arn:aws:iam::aws:policy/DevMonitoringPolicy"
      }
    }
    
    group_policy_attachments = {
      "dev-admins-policy" = {
        group      = "DevAdmins"
        policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
      }
      "dev-developers-policy" = {
        group      = "DevDevelopers"
        policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
      }
      "dev-testers-policy" = {
        group      = "DevTesters"
        policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
    }
  }
} 