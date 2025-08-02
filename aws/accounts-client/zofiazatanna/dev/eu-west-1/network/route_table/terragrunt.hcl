terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/route_table?ref=main"
}

dependency "vpc" {
  config_path = "../vpc"
}
dependency "subnet" {
  config_path = "../subnet"
}
dependency "natgateway" {
  config_path = "../natgateway"
}

inputs = {
  name        = "client-a-rtb"
  vpc_id      = dependency.vpc.outputs.vpc_id
  subnet_ids  = [dependency.subnet.outputs.subnet_id]
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = dependency.natgateway.outputs.nat_gateway_id
    }
  ]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}
