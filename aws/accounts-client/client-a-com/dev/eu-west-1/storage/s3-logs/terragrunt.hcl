terraform {
  source = "terraform-aws-modules/s3-bucket/aws"
}

inputs = {
  bucket = "client-a-com-logs"
  acl    = "private"
  versioning = {
    enabled = true
  }
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}
