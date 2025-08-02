include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  ecs_config   = local.account_vars.locals.ecs_config
  
  # Input validation for ECS service module
  validate_service_name = length(local.ecs_config.service_name) <= 255 ? null : file("ERROR: ECS service name must be <= 255 characters")
  validate_service_name_format = can(regex("^[a-zA-Z0-9_-]+$", local.ecs_config.service_name)) ? null : file("ERROR: ECS service name must contain only alphanumeric characters, hyphens, and underscores")
  validate_ecs_cpu = contains([256, 512, 1024, 2048, 4096], local.ecs_config.cpu) ? null : file("ERROR: ECS CPU must be one of: 256, 512, 1024, 2048, 4096")
  validate_ecs_memory = contains([512, 1024, 2048, 4096, 8192, 16384, 30720], local.ecs_config.memory) ? null : file("ERROR: ECS memory must be one of: 512, 1024, 2048, 4096, 8192, 16384, 30720")
  validate_ecs_desired_count = local.ecs_config.desired_count >= 1 && local.ecs_config.desired_count <= 10 ? null : file("ERROR: ECS desired count must be between 1 and 10")
  validate_ecs_max_count = local.ecs_config.max_count >= local.ecs_config.desired_count ? null : file("ERROR: ECS max count must be >= desired count")
  validate_ecs_min_count = local.ecs_config.min_count <= local.ecs_config.desired_count ? null : file("ERROR: ECS min count must be <= desired count")
  validate_ecs_container_port = local.ecs_config.container_port >= 1 && local.ecs_config.container_port <= 65535 ? null : file("ERROR: Container port must be between 1 and 65535")
  validate_health_check_path = length(local.ecs_config.health_check_path) > 0 ? null : file("ERROR: Health check path cannot be empty")
  validate_health_check_path_format = can(regex("^/", local.ecs_config.health_check_path)) ? null : file("ERROR: Health check path must start with /")
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id          = "vpc-mock"
    private_subnets = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
    public_subnets  = ["subnet-mock-4", "subnet-mock-5", "subnet-mock-6"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "alb" {
  config_path = "../alb"
  
  mock_outputs = {
    lb_arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:loadbalancer/app/mock-alb/1234567890123456"
    lb_id  = "mock-alb-id"
    target_group_arns = ["arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/mock-tg/1234567890123456"]
    security_group_ids = ["sg-mock"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "ecs_cluster" {
  config_path = "../ecs-cluster"
  
  mock_outputs = {
    cluster_id = "mock-cluster-id"
    cluster_arn = "arn:aws:ecs:eu-west-1:123456789012:cluster/mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "rds" {
  config_path = "../rds"
  
  mock_outputs = {
    db_instance_endpoint = "mock-db.region.rds.amazonaws.com"
    db_instance_master_user_secret_arn = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:mock-secret"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/ecs/aws//modules/service?version=5.7.4"
}

inputs = {
  # Service configuration
  service_name = local.ecs_config.service_name
  cluster_arn  = dependency.ecs_cluster.outputs.cluster_arn
  
  # Task definition
  cpu    = local.ecs_config.cpu
  memory = local.ecs_config.memory
  
  # Container definition
  container_definitions = {
    accounts_client = {
      cpu       = local.ecs_config.cpu
      memory    = local.ecs_config.memory
      essential = true
      
      image = "your-registry/accounts-client:latest"
      portMappings = [
        {
          containerPort = local.ecs_config.container_port
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "DB_HOST"
          value = dependency.rds.outputs.db_instance_endpoint
        },
        {
          name  = "DB_NAME"
          value = "accounts_client"
        },
        {
          name  = "DB_PORT"
          value = "5432"
        }
      ]
      
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = dependency.rds.outputs.db_instance_master_user_secret_arn
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.ecs_config.service_name}"
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }
  
  # Service configuration
  desired_count                      = local.ecs_config.desired_count
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  # Load balancer configuration
  load_balancer = {
    service = {
      target_group_arn = dependency.alb.outputs.target_group_arns[0]
      container_name   = "accounts_client"
      container_port   = local.ecs_config.container_port
    }
  }
  
  # Network configuration
  subnet_ids = dependency.vpc.outputs.private_subnets
  security_group_rules = {
    ecs_tasks = {
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = aws_security_group.ecs.id
    }
  }
  
  # Auto scaling
  enable_execute_command = true
  
  # Tags
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    ManagedBy   = "Terragrunt"
    Purpose     = "application-service"
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs" {
  name_prefix = "cyprus-ecs-"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  ingress {
    from_port       = local.ecs_config.container_port
    to_port         = local.ecs_config.container_port
    protocol        = "tcp"
    security_groups = [dependency.alb.outputs.security_group_ids[0]]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "cyprus-ecs-sg"
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "application-access"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.ecs_config.service_name}"
  retention_in_days = 7
  
  tags = {
    Environment = "cyprus"
    Project     = "accounts-client"
    Purpose     = "application-logs"
  }
} 