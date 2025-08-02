# ==============================================================================
# AWS Config Security Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

# Dependencies
dependency "kms" {
  config_path = "../kms"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/config.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "AWS Config Security - Development"
  
  # AWS Config security configuration for development environment
  config_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "AWS Config Security"
    
    # AWS Config configuration
    config = {
      name = "client-b-dev-config"
      
      # Recording configuration
      recording_group = {
        all_supported = true
        include_global_resources = true
        recording_strategy = "ALL_SUPPORTED"
      }
      
      # Delivery channel configuration
      delivery_channel = {
        name = "client-b-dev-config-delivery"
        s3_bucket_name = "client-b-dev-config-logs-${include.account.locals.account_id}"
        s3_key_prefix = "config"
        sns_topic_arn = "arn:aws:sns:us-east-1:${include.account.locals.account_id}:client-b-dev-config-notifications"
      }
      
      # S3 bucket configuration
      s3_bucket = {
        bucket_name = "client-b-dev-config-logs-${include.account.locals.account_id}"
        versioning_enabled = true
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.config_kms_key_id
        
        # Lifecycle rules
        lifecycle_rules = [
          {
            id = "config-lifecycle"
            status = "Enabled"
            transitions = [
              {
                days = 30
                storage_class = "STANDARD_IA"
              },
              {
                days = 90
                storage_class = "GLACIER"
              },
              {
                days = 365
                storage_class = "DEEP_ARCHIVE"
              }
            ]
            expiration = {
              days = 2555  # 7 years
            }
          }
        ]
        
        # Bucket policy
        bucket_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid = "AWSConfigBucketPermissionsCheck"
              Effect = "Allow"
              Principal = {
                Service = "config.amazonaws.com"
              }
              Action = "s3:GetBucketAcl"
              Resource = "arn:aws:s3:::client-b-dev-config-logs-${include.account.locals.account_id}"
            },
            {
              Sid = "AWSConfigBucketDelivery"
              Effect = "Allow"
              Principal = {
                Service = "config.amazonaws.com"
              }
              Action = "s3:PutObject"
              Resource = "arn:aws:s3:::client-b-dev-config-logs-${include.account.locals.account_id}/*"
              Condition = {
                StringEquals = {
                  "s3:x-amz-acl" = "bucket-owner-full-control"
                }
              }
            }
          ]
        })
        
        tags = {
          Name = "client-b-dev-config-logs"
          Purpose = "AWS Config Log Storage"
          Environment = "Development"
          DataClass = "Audit"
        }
      }
      
      # SNS topic configuration
      sns_topic = {
        name = "client-b-dev-config-notifications"
        display_name = "Client B Development Config Notifications"
        kms_master_key_id = dependency.kms.outputs.config_kms_key_id
        
        subscriptions = {
          security_email = {
            protocol = "email"
            endpoint = "security@clientb.com"
          }
          devops_email = {
            protocol = "email"
            endpoint = "devops@clientb.com"
          }
        }
        
        tags = {
          Name = "client-b-dev-config-notifications"
          Purpose = "Config Notifications"
          Environment = "Development"
          Service = "Config"
        }
      }
      
      # Configuration rules
      config_rules = {
        # S3 bucket encryption
        s3_bucket_encryption = {
          name = "s3-bucket-encryption"
          description = "Checks that S3 buckets have encryption enabled"
          source = {
            owner = "AWS"
            source_identifier = "S3_BUCKET_ENCRYPTION"
          }
          scope = {
            compliance_resource_types = ["AWS::S3::Bucket"]
          }
        }
        
        # RDS encryption
        rds_encryption = {
          name = "rds-encryption"
          description = "Checks that RDS instances have encryption enabled"
          source = {
            owner = "AWS"
            source_identifier = "RDS_STORAGE_ENCRYPTED"
          }
          scope = {
            compliance_resource_types = ["AWS::RDS::DBInstance"]
          }
        }
        
        # CloudTrail enabled
        cloudtrail_enabled = {
          name = "cloudtrail-enabled"
          description = "Checks that CloudTrail is enabled"
          source = {
            owner = "AWS"
            source_identifier = "CLOUD_TRAIL_ENABLED"
          }
        }
        
        # IAM password policy
        iam_password_policy = {
          name = "iam-password-policy"
          description = "Checks that IAM password policy meets requirements"
          source = {
            owner = "AWS"
            source_identifier = "IAM_PASSWORD_POLICY"
          }
        }
        
        # Root account MFA
        root_account_mfa = {
          name = "root-account-mfa"
          description = "Checks that root account has MFA enabled"
          source = {
            owner = "AWS"
            source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
          }
        }
        
        # VPC default security group
        vpc_default_security_group = {
          name = "vpc-default-security-group"
          description = "Checks that default security groups do not allow inbound traffic"
          source = {
            owner = "AWS"
            source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
          }
        }
        
        # EBS encryption
        ebs_encryption = {
          name = "ebs-encryption"
          description = "Checks that EBS volumes have encryption enabled"
          source = {
            owner = "AWS"
            source_identifier = "ENCRYPTED_VOLUMES"
          }
          scope = {
            compliance_resource_types = ["AWS::EC2::Volume"]
          }
        }
        
        # Lambda function encryption
        lambda_encryption = {
          name = "lambda-encryption"
          description = "Checks that Lambda functions have encryption enabled"
          source = {
            owner = "AWS"
            source_identifier = "LAMBDA_FUNCTION_ENCRYPTION"
          }
          scope = {
            compliance_resource_types = ["AWS::Lambda::Function"]
          }
        }
      }
      
      # Remediation actions
      remediation_configurations = {
        # S3 bucket encryption remediation
        s3_bucket_encryption_remediation = {
          config_rule_name = "s3-bucket-encryption"
          target_type = "SSM_DOCUMENT"
          target_id = "AWS-EnableS3BucketEncryption"
          target_version = "1"
          parameters = {
            BucketName = {
              StaticValue = {
                Values = ["REMEDIATION_TARGET"]
              }
            }
          }
          maximum_automatic_attempts = 3
          retry_attempt_seconds = 60
        }
        
        # RDS encryption remediation
        rds_encryption_remediation = {
          config_rule_name = "rds-encryption"
          target_type = "SSM_DOCUMENT"
          target_id = "AWS-EnableRDSEncryption"
          target_version = "1"
          parameters = {
            DBInstanceIdentifier = {
              StaticValue = {
                Values = ["REMEDIATION_TARGET"]
              }
            }
          }
          maximum_automatic_attempts = 3
          retry_attempt_seconds = 60
        }
      }
      
      # Tags
      tags = {
        Name = "client-b-dev-config"
        Purpose = "Compliance Monitoring"
        Environment = "Development"
        Service = "Config"
      }
    }
  }
  
  # Tags for all AWS Config security resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
    SecurityLevel = "High"
  }
} 