# ==============================================================================
# CloudTrail Security Module Configuration for Client B - Development Environment
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
  source = "git::https://github.com/catherinevee/cloudtrail.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "CloudTrail Security - Development"
  
  # CloudTrail security configuration for development environment
  cloudtrail_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "CloudTrail Security"
    
    # CloudTrail configuration
    cloudtrail = {
      name = "client-b-dev-cloudtrail"
      s3_bucket_name = "client-b-dev-cloudtrail-logs-${include.account.locals.account_id}"
      include_global_service_events = true
      is_multi_region_trail = true
      enable_log_file_validation = true
      
      # Encryption
      kms_key_id = dependency.kms.outputs.cloudtrail_kms_key_id
      
      # Logging configuration
      log_group_name = "/aws/cloudtrail/client-b-dev"
      log_group_retention_in_days = 30  # 30 days for dev
      
      # Event selectors
      event_selectors = [
        {
          read_write_type = "All"
          include_management_events = true
          data_resources = [
            {
              type = "AWS::S3::Object"
              values = ["arn:aws:s3:::client-b-dev-*/*"]
            },
            {
              type = "AWS::S3::Bucket"
              values = ["arn:aws:s3:::client-b-dev-*"]
            },
            {
              type = "AWS::RDS::DBInstance"
              values = ["arn:aws:rds:*:${include.account.locals.account_id}:db:*"]
            },
            {
              type = "AWS::EC2::Instance"
              values = ["arn:aws:ec2:*:${include.account.locals.account_id}:instance/*"]
            }
          ]
        }
      ]
      
      # Advanced event selectors
      advanced_event_selectors = [
        {
          name = "SensitiveDataEvents"
          field_selectors = [
            {
              field = "eventCategory"
              equals = ["Data"]
            },
            {
              field = "eventName"
              equals = ["PutObject", "GetObject", "DeleteObject"]
            }
          ]
        },
        {
          name = "ManagementEvents"
          field_selectors = [
            {
              field = "eventCategory"
              equals = ["Management"]
            }
          ]
        },
        {
          name = "SecurityEvents"
          field_selectors = [
            {
              field = "eventCategory"
              equals = ["Security"]
            }
          ]
        }
      ]
      
      # S3 bucket configuration
      s3_bucket = {
        bucket_name = "client-b-dev-cloudtrail-logs-${include.account.locals.account_id}"
        versioning_enabled = true
        encryption_algorithm = "aws:kms"
        kms_key_id = dependency.kms.outputs.cloudtrail_kms_key_id
        
        # Lifecycle rules
        lifecycle_rules = [
          {
            id = "cloudtrail-lifecycle"
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
              Sid = "AWSCloudTrailAclCheck"
              Effect = "Allow"
              Principal = {
                Service = "cloudtrail.amazonaws.com"
              }
              Action = "s3:GetBucketAcl"
              Resource = "arn:aws:s3:::client-b-dev-cloudtrail-logs-${include.account.locals.account_id}"
            },
            {
              Sid = "AWSCloudTrailWrite"
              Effect = "Allow"
              Principal = {
                Service = "cloudtrail.amazonaws.com"
              }
              Action = "s3:PutObject"
              Resource = "arn:aws:s3:::client-b-dev-cloudtrail-logs-${include.account.locals.account_id}/*"
              Condition = {
                StringEquals = {
                  "s3:x-amz-acl" = "bucket-owner-full-control"
                }
              }
            }
          ]
        })
        
        tags = {
          Name = "client-b-dev-cloudtrail-logs"
          Purpose = "CloudTrail Log Storage"
          Environment = "Development"
          DataClass = "Audit"
        }
      }
      
      # CloudWatch Logs configuration
      cloudwatch_logs = {
        enabled = true
        log_group_name = "/aws/cloudtrail/client-b-dev"
        retention_in_days = 30
        kms_key_id = dependency.kms.outputs.cloudtrail_kms_key_id
        
        # Metric filters
        metric_filters = [
          {
            name = "RootAccountUsage"
            pattern = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
            metric_transformation = {
              name = "RootAccountUsage"
              namespace = "CloudTrailMetrics"
              value = "1"
            }
          },
          {
            name = "UnauthorizedAPICalls"
            pattern = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
            metric_transformation = {
              name = "UnauthorizedAPICalls"
              namespace = "CloudTrailMetrics"
              value = "1"
            }
          },
          {
            name = "ConsoleSignInFailures"
            pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.errorMessage = \"Failed authentication\") }"
            metric_transformation = {
              name = "ConsoleSignInFailures"
              namespace = "CloudTrailMetrics"
              value = "1"
            }
          }
        ]
      }
      
      # Tags
      tags = {
        Name = "client-b-dev-cloudtrail"
        Purpose = "Security Audit Logging"
        Environment = "Development"
        Service = "CloudTrail"
      }
    }
  }
  
  # Tags for all CloudTrail security resources
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