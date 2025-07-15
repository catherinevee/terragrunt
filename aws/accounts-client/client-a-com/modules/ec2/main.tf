module "ec2_multiple" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "= 6.0.2"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  instance_type               = "t3.micro"
  key_name                   = "user1"
  monitoring                 = true
  vpc_security_group_ids     = ["sg-12345678"]
  subnet_id                  = "subnet-eddcdzz4"
  associate_public_ip_address = true

  user_data = base64encode(templatefile("user-data.sh", {
    instance_name = each.key
  }))

  tags = {
    Name        = "instance-${each.key}"
    Environment  = var.environment
    Region        = var.region
    CostCenter   = var.costcenter
    Project      = var.project
    Terraform   = True
  }

}