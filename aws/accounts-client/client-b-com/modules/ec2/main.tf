module "ec2_instances" {
  source = "github.com/catherinevee/ec2"
  version = "1.0.0"  # Version pinning for the module

  for_each = var.instances

  name = each.value.name
  instance_type = each.value.instance_type
  key_name = each.value.key_name
  monitoring = each.value.monitoring
  vpc_security_group_ids = each.value.vpc_security_group_ids
  subnet_id = each.value.subnet_id
  associate_public_ip_address = each.value.associate_public_ip_address

  user_data = each.value.user_data != null ? base64encode(templatefile(each.value.user_data.template, each.value.user_data.vars)) : null

  tags = merge(
    {
      Name = each.value.name
      Environment = var.environment
      Region = var.region
      CostCenter = var.costcenter
      Project = var.project
      Terraform = true
    },
    each.value.tags
  )
} 