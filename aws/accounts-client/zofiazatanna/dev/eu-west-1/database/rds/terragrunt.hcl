terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/rds?ref=main"
}

dependency "subnet" {
  config_path = "../../network/subnet"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  db_instance_identifier = "client-a-db"
  engine                = "mysql"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  username              = "adminuser"
  password              = "examplepassword123"
  db_subnet_group_name  = dependency.subnet.outputs.subnet_group_name
  vpc_security_group_ids = ["sg-xxxxxxxx"]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}

outputs = {
  endpoint = {
    value = module.rds.endpoint
    description = "The endpoint of the RDS instance."
  }
  db_instance_identifier = {
    value = module.rds.db_instance_identifier
    description = "The DB instance identifier."
  }
}
