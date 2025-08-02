terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/natgateway?ref=main"
}

dependency "subnet" {
  config_path = "../../network/subnet"
}
dependency "eip" {
  config_path = "../../network/eip"
}

inputs = {
  name         = "client-a-natgw"
  subnet_id    = dependency.subnet.outputs.subnet_id
  allocation_id = dependency.eip.outputs.allocation_id
  tags = {
    Environment = "staging"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}

outputs = {
  nat_gateway_id = {
    value = module.natgateway.nat_gateway_id
    description = "The ID of the NAT Gateway."
  }
}
