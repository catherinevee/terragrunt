# ==============================================================================
# Compute Module Configuration for Client B - Development Environment (eu-west-3)
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

include "region" {
  path = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  expose = true
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../security-groups"
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/compute.git//?ref=v1.0.0"
}

inputs = {
  # Environment and region configuration
  environment = include.account.locals.environment
  region      = include.region.locals.region
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Compute Resources - Development"
  
  # VPC and subnet references
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  
  # Security group references
  web_security_group_id = dependency.security_groups.outputs.web_security_group_id
  app_security_group_id = dependency.security_groups.outputs.app_security_group_id
  
  # Compute configuration for development environment
  compute_config = {
    # EC2 instances configuration
    instances = {
      # Web server instance
      web_server = {
        name = "client-b-dev-web-server"
        instance_type = "t3.micro"  # Small instance for dev
        ami_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for eu-west-3
        subnet_id = dependency.vpc.outputs.public_subnet_ids[0]  # First public subnet
        security_group_ids = [dependency.security_groups.outputs.web_security_group_id]
        key_name = "client-b-dev-key"
        associate_public_ip = true
        root_volume_size = 20
        root_volume_type = "gp3"
        user_data = base64encode(<<-EOF
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Client B Development Web Server</h1>" > /var/www/html/index.html
        EOF
        )
        tags = {
          Name = "client-b-dev-web-server"
          Purpose = "Web Server"
          Environment = "Development"
          Tier = "Web"
        }
      }
      
      # Application server instance
      app_server = {
        name = "client-b-dev-app-server"
        instance_type = "t3.micro"  # Small instance for dev
        ami_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for eu-west-3
        subnet_id = dependency.vpc.outputs.private_subnet_ids[0]  # First private subnet
        security_group_ids = [dependency.security_groups.outputs.app_security_group_id]
        key_name = "client-b-dev-key"
        associate_public_ip = false
        root_volume_size = 30
        root_volume_type = "gp3"
        user_data = base64encode(<<-EOF
          #!/bin/bash
          yum update -y
          yum install -y java-11-amazon-corretto
          yum install -y nginx
          systemctl start nginx
          systemctl enable nginx
        EOF
        )
        tags = {
          Name = "client-b-dev-app-server"
          Purpose = "Application Server"
          Environment = "Development"
          Tier = "Application"
        }
      }
    }
    
    # Auto Scaling Groups configuration
    auto_scaling_groups = {
      # Web tier auto scaling group
      web_asg = {
        name = "client-b-dev-web-asg"
        min_size = 1
        max_size = 3
        desired_capacity = 1
        health_check_type = "ELB"
        health_check_grace_period = 300
        vpc_zone_identifier = dependency.vpc.outputs.public_subnet_ids
        target_group_arns = []  # Will be updated when ALB is created
        launch_template_name = "client-b-dev-web-lt"
        tags = {
          Name = "client-b-dev-web-asg"
          Purpose = "Web Tier Auto Scaling Group"
          Environment = "Development"
          Tier = "Web"
        }
      }
      
      # Application tier auto scaling group
      app_asg = {
        name = "client-b-dev-app-asg"
        min_size = 1
        max_size = 3
        desired_capacity = 1
        health_check_type = "ELB"
        health_check_grace_period = 300
        vpc_zone_identifier = dependency.vpc.outputs.private_subnet_ids
        target_group_arns = []  # Will be updated when ALB is created
        launch_template_name = "client-b-dev-app-lt"
        tags = {
          Name = "client-b-dev-app-asg"
          Purpose = "Application Tier Auto Scaling Group"
          Environment = "Development"
          Tier = "Application"
        }
      }
    }
    
    # Launch Templates configuration
    launch_templates = {
      # Web tier launch template
      web_lt = {
        name = "client-b-dev-web-lt"
        description = "Launch template for web tier in Client B development environment"
        image_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for eu-west-3
        instance_type = "t3.micro"
        key_name = "client-b-dev-key"
        vpc_security_group_ids = [dependency.security_groups.outputs.web_security_group_id]
        user_data = base64encode(<<-EOF
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Client B Development Web Server</h1>" > /var/www/html/index.html
        EOF
        )
        block_device_mappings = [
          {
            device_name = "/dev/xvda"
            ebs = {
              volume_size = 20
              volume_type = "gp3"
              delete_on_termination = true
              encrypted = true
            }
          }
        ]
        tags = {
          Name = "client-b-dev-web-lt"
          Purpose = "Web Tier Launch Template"
          Environment = "Development"
          Tier = "Web"
        }
      }
      
      # Application tier launch template
      app_lt = {
        name = "client-b-dev-app-lt"
        description = "Launch template for application tier in Client B development environment"
        image_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for eu-west-3
        instance_type = "t3.micro"
        key_name = "client-b-dev-key"
        vpc_security_group_ids = [dependency.security_groups.outputs.app_security_group_id]
        user_data = base64encode(<<-EOF
          #!/bin/bash
          yum update -y
          yum install -y java-11-amazon-corretto
          yum install -y nginx
          systemctl start nginx
          systemctl enable nginx
        EOF
        )
        block_device_mappings = [
          {
            device_name = "/dev/xvda"
            ebs = {
              volume_size = 30
              volume_type = "gp3"
              delete_on_termination = true
              encrypted = true
            }
          }
        ]
        tags = {
          Name = "client-b-dev-app-lt"
          Purpose = "Application Tier Launch Template"
          Environment = "Development"
          Tier = "Application"
        }
      }
    }
  }
  
  # Tags for all compute resources
  tags = {
    Environment = "Development"
    Project     = "Client B Infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    DataClass   = "Internal"
  }
} 