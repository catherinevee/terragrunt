# Terragrunt config for EC2 instances


terraform {
  source = "../modules//ec2"
}

include {
  path = find_in_parent_folders()
}

dependency "subnets" {
# Terragrunt config for EC2 instances

terraform {
  source = "../modules//ec2"
}

include {
  path = find_in_parent_folders()
}

dependency "subnets" {
  config_path = "../subnets"
}

dependency "securitygroup" {
  config_path = "../securitygroup"
}

inputs = {
  environment = "prod"
  region      = "eu-west-1"
  project     = "catherinevee"
  costcenter  = "ITS"
  instances = [
    {
      name = "web-1"
      ami  = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.medium"
      subnet_id = dependency.subnets.outputs.public_subnet_ids[0]
      vpc_security_group_ids = [dependency.securitygroup.outputs.security_group_id]
      key_name = "user1"
      associate_public_ip_address = true
      user_data = "#!/bin/bash\necho Hello from web-1 > /var/tmp/hello.txt"
      root_block_device = {
        volume_size = 32
        volume_type = "gp3"
      }
      tags = {
        Name        = "web-1"
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name = "web-2"
      ami  = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.medium"
      subnet_id = dependency.subnets.outputs.public_subnet_ids[0]
      vpc_security_group_ids = [dependency.securitygroup.outputs.security_group_id]
      key_name = "user1"
      associate_public_ip_address = true
      user_data = "#!/bin/bash\necho Hello from web-2 > /var/tmp/hello.txt"
      root_block_device = {
        volume_size = 32
        volume_type = "gp3"
      }
      tags = {
        Name        = "web-2"
        Environment = "prod"
        Project     = "catherinevee"
        ManagedBy   = "terragrunt"
      }
    },
    {
      name = "app-1"
      ami  = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.large"
      subnet_id = dependency.subnets.outputs.private_subnet_ids[0]
      vpc_security_group_ids = [dependency.securitygroup.outputs.security_group_id]
      key_name = "prod-key"
      associate_public_ip_address = false
      monitoring = true
      iam_instance_profile = "ec2-prod-profile"
      user_data = "#!/bin/bash\nyum update -y\necho Hello from app-1 > /var/tmp/hello.txt"
      root_block_device = {
        volume_size = 64
        volume_type = "gp3"
        encrypted   = true
      }
      tags = {
        Name        = "app-1-prod"
        Environment = "prod"
        Project     = "catherinevee"
        Role        = "app"
        ManagedBy   = "terragrunt"
      }
    }
  ]
  enable_detailed_monitoring = true
  enable_termination_protection = true
  tags = {
    Owner       = "devops@catherinevee.com"
    Department  = "IT"
    Compliance  = "PCI-DSS"
  }
  # Example: add IAM instance profile, EBS volumes, or additional EC2 features here if supported by the module
}
