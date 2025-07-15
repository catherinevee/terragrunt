output "bucket_name" {
  value = module.s3-bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.s3-bucket.s3_bucket_arn
}