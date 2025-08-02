terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/vpc?ref=main"
}

inputs = {
  name = "example-vpc"
  cidr_block = "10.0.0.0/16"
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
  }
}

outputs = {
  vpc_id = {
    value = module.vpc.vpc_id
    description = "The ID of the VPC."
  }
}
