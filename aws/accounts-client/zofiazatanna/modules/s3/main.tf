module "s3-bucket" {
    source = "terraform-aws-modules/s3-bucket/aws"
    version = "= 5.2.0"
    bucket = "s3-${var.environment}-${var.region}-${var.bucket_name}-${random_string.suffix.id}"

    versioning = {
        enabled = true
    }
    
    server_side_encryption_configuration = {
        rule = {
        apply_server_side_encryption_by_default = {
            sse_algorithm = "AES256"
        }
        }
    }
    
    # Block all public access
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    lifecycle_rule = [
        {
        id      = "log"
        enabled = true
        
        expiration = {
            days = 90
        }
        
        noncurrent_version_expiration = {
            days = 30
        }
        
        transition = [
            {
            days          = 30
            storage_class = "STANDARD_IA"
            },
            {
            days          = 60
            storage_class = "GLACIER"
            }
        ]
        }
    ]


    tags = {
    Name        = "${var.bucket}"
    Environment  = var.environment
    Region        = var.region
    CostCenter   = var.costcenter
    Project      = var.project
    Terraform   = "true"
    }
}

resource "random_string" "suffix" {
    length = 8
    special = false
    upper = false
}