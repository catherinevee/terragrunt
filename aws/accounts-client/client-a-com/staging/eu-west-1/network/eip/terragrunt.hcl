terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/eip?ref=main"
}

inputs = {
  name = "example-eip"
  tags = {
    Environment = "staging"
    Project     = "client-a-com"
  }
}

outputs = {
  allocation_id = {
    value = module.eip.allocation_id
    description = "The allocation ID of the EIP."
  }
}
