terraform {
  source = "terraform-aws-modules/macie/aws"
}

inputs = {
  enable_macie = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "Security"
    Owner       = "Zofia Zatanna"
  }
}
