variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "costcenter" {
  description = "Cost center for resource tagging"
  type        = string
  default     = "IT"
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
  default     = "Infrastructure"
}

variable "buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    bucket_name = string
    bucket_acl = optional(string, "private")
    versioning_enabled = optional(bool, true)
    encryption_enabled = optional(bool, true)
    encryption_algorithm = optional(string, "AES256")
    encryption_key_arn = optional(string, null)
    
    # Lifecycle configuration
    lifecycle_rules = optional(list(object({
      id = string
      status = string
      enabled = bool
      abort_incomplete_multipart_upload_days = optional(number)
      expiration = optional(object({
        days = optional(number)
        expired_object_delete_marker = optional(bool)
      }))
      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }))
      transitions = optional(list(object({
        days = number
        storage_class = string
      })))
      noncurrent_version_transitions = optional(list(object({
        noncurrent_days = number
        storage_class = string
      })))
    })), [])
    
    # Server-side encryption
    server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm = string
          kms_master_key_id = optional(string)
        })
        bucket_key_enabled = optional(bool)
      })
    }), null)
    
    # Public access block settings
    block_public_acls = optional(bool, true)
    block_public_policy = optional(bool, true)
    ignore_public_acls = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
    
    # CORS configuration
    cors_rules = optional(list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers = optional(list(string))
      max_age_seconds = optional(number)
    })), [])
    
    # Website configuration
    website_configuration = optional(object({
      index_document = optional(string)
      error_document = optional(string)
      redirect_all_requests_to = optional(string)
      routing_rules = optional(string)
    }), null)
    
    # Notification configuration
    notification_configuration = optional(object({
      lambda_configurations = optional(list(object({
        lambda_function_arn = string
        events = list(string)
        filter_prefix = optional(string)
        filter_suffix = optional(string)
      })), [])
      queue_configurations = optional(list(object({
        queue_arn = string
        events = list(string)
        filter_prefix = optional(string)
        filter_suffix = optional(string)
      })), [])
      topic_configurations = optional(list(object({
        topic_arn = string
        events = list(string)
        filter_prefix = optional(string)
        filter_suffix = optional(string)
      })), [])
    }), null)
    
    # Object ownership
    object_ownership = optional(string, "BucketOwnerPreferred")
    
    # Intelligent tiering
    intelligent_tiering_configuration = optional(list(object({
      id = string
      status = string
      tiering = list(object({
        access_tier = string
        days = number
      }))
    })), [])
    
    # Replication configuration
    replication_configuration = optional(object({
      role = string
      rules = list(object({
        id = string
        status = string
        priority = optional(number)
        prefix = optional(string)
        destination = object({
          bucket = string
          storage_class = optional(string)
          replica_kms_key_id = optional(string)
          account = optional(string)
          access_control_translation = optional(object({
            owner = string
          }))
        })
        source_selection_criteria = optional(object({
          sse_kms_encrypted_objects = optional(object({
            status = string
          }))
        }))
      }))
    }), null)
    
    # Object lock configuration
    object_lock_configuration = optional(object({
      object_lock_enabled = string
      rule = optional(object({
        default_retention = object({
          mode = string
          days = optional(number)
          years = optional(number)
        })
      }))
    }), null)
    
    tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for bucket in var.buckets : 
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", bucket.bucket_name))
    ])
    error_message = "Bucket names must be between 3 and 63 characters long, contain only lowercase letters, numbers, dots, and hyphens, and must start and end with a letter or number."
  }
} 