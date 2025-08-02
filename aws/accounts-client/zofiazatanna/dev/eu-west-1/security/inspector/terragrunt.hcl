terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/inspector?ref=main"
}

inputs = {
  enable = true
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "Security"
    Owner       = "Zofia Zatanna"
  }
}
