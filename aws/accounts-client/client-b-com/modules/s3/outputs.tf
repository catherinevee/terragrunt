output "bucket_ids" {
  description = "List of S3 bucket IDs"
  value       = [for bucket in module.s3_buckets : bucket.bucket_id]
}

output "bucket_arns" {
  description = "List of S3 bucket ARNs"
  value       = [for bucket in module.s3_buckets : bucket.bucket_arn]
}

output "bucket_names" {
  description = "List of S3 bucket names"
  value       = [for bucket in module.s3_buckets : bucket.bucket_name]
}

output "bucket_regions" {
  description = "List of S3 bucket regions"
  value       = [for bucket in module.s3_buckets : bucket.bucket_region]
}

output "bucket_websites" {
  description = "List of S3 bucket website endpoints"
  value       = [for bucket in module.s3_buckets : bucket.bucket_website_endpoint]
}

output "bucket_website_domains" {
  description = "List of S3 bucket website domain names"
  value       = [for bucket in module.s3_buckets : bucket.bucket_website_domain]
}

output "buckets" {
  description = "Map of S3 buckets with all their attributes"
  value       = module.s3_buckets
} 