module "s3_buckets" {
  source = "github.com/catherinevee/s3"
  version = "1.0.0"  # Version pinning for the module

  for_each = var.buckets

  bucket_name = each.value.bucket_name
  bucket_acl = each.value.bucket_acl
  versioning_enabled = each.value.versioning_enabled
  encryption_enabled = each.value.encryption_enabled
  encryption_algorithm = each.value.encryption_algorithm
  encryption_key_arn = each.value.encryption_key_arn

  # Lifecycle configuration
  lifecycle_rules = each.value.lifecycle_rules

  # Server-side encryption
  server_side_encryption_configuration = each.value.server_side_encryption_configuration

  # Public access block settings
  block_public_acls = each.value.block_public_acls
  block_public_policy = each.value.block_public_policy
  ignore_public_acls = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets

  # CORS configuration
  cors_rules = each.value.cors_rules

  # Website configuration
  website_configuration = each.value.website_configuration

  # Notification configuration
  notification_configuration = each.value.notification_configuration

  # Object ownership
  object_ownership = each.value.object_ownership

  # Intelligent tiering
  intelligent_tiering_configuration = each.value.intelligent_tiering_configuration

  # Replication configuration
  replication_configuration = each.value.replication_configuration

  # Object lock configuration
  object_lock_configuration = each.value.object_lock_configuration

  # Tags
  tags = merge(
    {
      Name = each.value.bucket_name
      Environment = var.environment
      Region = var.region
      CostCenter = var.costcenter
      Project = var.project
      Terraform = true
    },
    each.value.tags
  )
} 