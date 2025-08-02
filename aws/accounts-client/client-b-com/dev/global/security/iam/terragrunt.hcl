# ==============================================================================
# IAM Security Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/iam.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "IAM Security - Development"
  
  # IAM security configuration for development environment
  iam_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "IAM Security Management"
    
    # Security-focused IAM policies
    create_security_policies = true
    security_policies = {
      # Least privilege policy
      least_privilege = {
        name = "ClientB-Dev-LeastPrivilegePolicy"
        description = "Enforces least privilege access for development environment"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Deny"
              Action = "*"
              Resource = "*"
              Condition = {
                StringNotEquals = {
                  "aws:RequestedRegion" = ["eu-west-1", "eu-west-2", "eu-west-3"]
                }
              }
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
              Condition = {
                StringNotEquals = {
                  "aws:PrincipalTag/Environment" = "Development"
                }
              }
            }
          ]
        })
        tags = {
          Purpose = "Security Policy"
          Environment = "Development"
          PolicyType = "LeastPrivilege"
        }
      }
      
      # Data protection policy
      data_protection = {
        name = "ClientB-Dev-DataProtectionPolicy"
        description = "Enforces data protection and encryption requirements"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Deny"
              Action = [
                "s3:PutObject"
              ]
              Resource = "*"
              Condition = {
                StringNotEquals = {
                  "s3:x-amz-server-side-encryption" = "AES256"
                }
              }
            },
            {
              Effect = "Deny"
              Action = [
                "rds:CreateDBInstance"
              ]
              Resource = "*"
              Condition = {
                Bool = {
                  "rds:StorageEncrypted" = "false"
                }
              }
            }
          ]
        })
        tags = {
          Purpose = "Data Protection"
          Environment = "Development"
          PolicyType = "Encryption"
        }
      }
      
      # Compliance policy
      compliance = {
        name = "ClientB-Dev-CompliancePolicy"
        description = "Enforces compliance and audit requirements"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Deny"
              Action = [
                "cloudtrail:DeleteTrail",
                "cloudtrail:StopLogging"
              ]
              Resource = "*"
            },
            {
              Effect = "Deny"
              Action = [
                "config:DeleteConfigurationRecorder",
                "config:StopConfigurationRecorder"
              ]
              Resource = "*"
            }
          ]
        })
        tags = {
          Purpose = "Compliance"
          Environment = "Development"
          PolicyType = "Audit"
        }
      }
    }
    
    # Security-focused IAM roles
    create_security_roles = true
    security_roles = {
      # Security administrator role
      security_admin = {
        name = "ClientB-Dev-SecurityAdminRole"
        description = "Role for security administrators in development environment"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                AWS = "arn:aws:iam::${include.account.locals.account_id}:root"
              }
              Action = "sts:AssumeRole"
              Condition = {
                StringEquals = {
                  "aws:PrincipalTag/Department" = "Security"
                }
              }
            }
          ]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/SecurityAudit",
          "arn:aws:iam::aws:policy/ViewOnlyAccess"
        ]
        tags = {
          Purpose = "Security Administration"
          Environment = "Development"
          RoleType = "Security"
        }
      }
      
      # Compliance auditor role
      compliance_auditor = {
        name = "ClientB-Dev-ComplianceAuditorRole"
        description = "Role for compliance auditors in development environment"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                AWS = "arn:aws:iam::${include.account.locals.account_id}:root"
              }
              Action = "sts:AssumeRole"
              Condition = {
                StringEquals = {
                  "aws:PrincipalTag/Department" = "Compliance"
                }
              }
            }
          ]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/SecurityAudit",
          "arn:aws:iam::aws:policy/ViewOnlyAccess"
        ]
        tags = {
          Purpose = "Compliance Auditing"
          Environment = "Development"
          RoleType = "Audit"
        }
      }
    }
    
    # Security-focused IAM groups
    create_security_groups = true
    security_groups = {
      # Security administrators group
      security_admins = {
        name = "ClientB-Dev-SecurityAdmins"
        path = "/groups/security/"
        tags = {
          Purpose = "Security Administration"
          Environment = "Development"
          GroupType = "Security"
        }
      }
      
      # Compliance auditors group
      compliance_auditors = {
        name = "ClientB-Dev-ComplianceAuditors"
        path = "/groups/compliance/"
        tags = {
          Purpose = "Compliance Auditing"
          Environment = "Development"
          GroupType = "Audit"
        }
      }
    }
    
    # Security-focused IAM users
    create_security_users = true
    security_users = {
      # Security administrator user
      security_admin = {
        username = "security-admin-dev"
        path = "/users/security/"
        groups = ["ClientB-Dev-SecurityAdmins"]
        tags = {
          Role = "Security Administrator"
          Department = "Security"
          AccessLevel = "Admin"
          Environment = "Development"
        }
      }
      
      # Compliance auditor user
      compliance_auditor = {
        username = "compliance-auditor-dev"
        path = "/users/compliance/"
        groups = ["ClientB-Dev-ComplianceAuditors"]
        tags = {
          Role = "Compliance Auditor"
          Department = "Compliance"
          AccessLevel = "ReadOnly"
          Environment = "Development"
        }
      }
    }
  }
  
  # Tags for all IAM security resources
  tags = {
    Environment = "Development"
    Project     = "Ollie Bacterianos Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    SecurityLevel = "High"
    Client      = "Ollie Bacterianos"
  }
} 