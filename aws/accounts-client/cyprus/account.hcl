locals {
  aws_account_id   = "123456789012"  # Replace with actual AWS account ID
  aws_account_role = "arn:aws:iam::123456789012:role/TerragruntRole"  # Replace with actual role ARN
  environment      = "cyprus"
  project          = "accounts-client"
  company          = "your-company"
  
  # Environment-specific configurations
  vpc_config = {
    cidr_block           = "10.0.0.0/16"
    availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    database_subnets     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
    enable_nat_gateway   = true
    single_nat_gateway   = false
    enable_vpn_gateway   = false
  }
  
  # RDS configuration
  rds_config = {
    instance_class      = "db.t3.micro"
    allocated_storage   = 20
    storage_encrypted   = true
    backup_retention_period = 7
    deletion_protection = true
    skip_final_snapshot = false
  }
  
  # ECS configuration
  ecs_config = {
    cluster_name        = "cyprus-cluster"
    service_name        = "accounts-client-service"
    cpu                 = 256
    memory             = 512
    desired_count      = 2
    max_count          = 4
    min_count          = 1
  }
  
  # ALB configuration
  alb_config = {
    name               = "cyprus-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = []
    subnets            = []
  }
} 