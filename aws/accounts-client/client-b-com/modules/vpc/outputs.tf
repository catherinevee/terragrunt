output "vpc_ids" {
  description = "List of VPC IDs"
  value       = [for vpc in module.vpc : vpc.vpc_id]
}

output "vpc_arns" {
  description = "List of VPC ARNs"
  value       = [for vpc in module.vpc : vpc.vpc_arn]
}

output "vpc_cidr_blocks" {
  description = "List of VPC CIDR blocks"
  value       = [for vpc in module.vpc : vpc.vpc_cidr_block]
}

output "vpc_names" {
  description = "List of VPC names"
  value       = [for vpc in module.vpc : vpc.vpc_name]
}

output "public_subnet_ids" {
  description = "Map of VPC names to public subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.public_subnets }
}

output "private_subnet_ids" {
  description = "Map of VPC names to private subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.private_subnets }
}

output "database_subnet_ids" {
  description = "Map of VPC names to database subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.database_subnets }
}

output "elasticache_subnet_ids" {
  description = "Map of VPC names to ElastiCache subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.elasticache_subnets }
}

output "redshift_subnet_ids" {
  description = "Map of VPC names to Redshift subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.redshift_subnets }
}

output "intra_subnet_ids" {
  description = "Map of VPC names to intra subnet IDs"
  value       = { for k, vpc in module.vpc : k => vpc.intra_subnets }
}

output "public_subnet_arns" {
  description = "Map of VPC names to public subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.public_subnet_arns }
}

output "private_subnet_arns" {
  description = "Map of VPC names to private subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.private_subnet_arns }
}

output "database_subnet_arns" {
  description = "Map of VPC names to database subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.database_subnet_arns }
}

output "elasticache_subnet_arns" {
  description = "Map of VPC names to ElastiCache subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.elasticache_subnet_arns }
}

output "redshift_subnet_arns" {
  description = "Map of VPC names to Redshift subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.redshift_subnet_arns }
}

output "intra_subnet_arns" {
  description = "Map of VPC names to intra subnet ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.intra_subnet_arns }
}

output "nat_gateway_ids" {
  description = "Map of VPC names to NAT Gateway IDs"
  value       = { for k, vpc in module.vpc : k => vpc.nat_ids }
}

output "nat_public_ips" {
  description = "Map of VPC names to NAT Gateway public IPs"
  value       = { for k, vpc in module.vpc : k => vpc.nat_public_ips }
}

output "nat_private_ips" {
  description = "Map of VPC names to NAT Gateway private IPs"
  value       = { for k, vpc in module.vpc : k => vpc.nat_private_ips }
}

output "internet_gateway_id" {
  description = "Map of VPC names to Internet Gateway IDs"
  value       = { for k, vpc in module.vpc : k => vpc.igw_id }
}

output "internet_gateway_arn" {
  description = "Map of VPC names to Internet Gateway ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.igw_arn }
}

output "vpn_gateway_id" {
  description = "Map of VPC names to VPN Gateway IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vgw_id }
}

output "vpn_gateway_arn" {
  description = "Map of VPC names to VPN Gateway ARNs"
  value       = { for k, vpc in module.vpc : k => vpc.vgw_arn }
}

output "default_security_group_id" {
  description = "Map of VPC names to default security group IDs"
  value       = { for k, vpc in module.vpc : k => vpc.default_security_group_id }
}

output "default_network_acl_id" {
  description = "Map of VPC names to default network ACL IDs"
  value       = { for k, vpc in module.vpc : k => vpc.default_network_acl_id }
}

output "default_route_table_id" {
  description = "Map of VPC names to default route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.default_route_table_id }
}

output "public_route_table_ids" {
  description = "Map of VPC names to public route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.public_route_table_ids }
}

output "private_route_table_ids" {
  description = "Map of VPC names to private route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.private_route_table_ids }
}

output "database_route_table_ids" {
  description = "Map of VPC names to database route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.database_route_table_ids }
}

output "elasticache_route_table_ids" {
  description = "Map of VPC names to ElastiCache route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.elasticache_route_table_ids }
}

output "redshift_route_table_ids" {
  description = "Map of VPC names to Redshift route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.redshift_route_table_ids }
}

output "intra_route_table_ids" {
  description = "Map of VPC names to intra route table IDs"
  value       = { for k, vpc in module.vpc : k => vpc.intra_route_table_ids }
}

output "vpc_endpoints" {
  description = "Map of VPC names to VPC endpoint information"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoints }
}

output "vpc_endpoint_s3_id" {
  description = "Map of VPC names to S3 VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_s3_id }
}

output "vpc_endpoint_s3_pl_id" {
  description = "Map of VPC names to S3 VPC endpoint prefix list IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_s3_pl_id }
}

output "vpc_endpoint_dynamodb_id" {
  description = "Map of VPC names to DynamoDB VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_dynamodb_id }
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "Map of VPC names to DynamoDB VPC endpoint prefix list IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_dynamodb_pl_id }
}

output "vpc_endpoint_ssm_id" {
  description = "Map of VPC names to SSM VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ssm_id }
}

output "vpc_endpoint_ssm_network_interface_ids" {
  description = "Map of VPC names to SSM VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ssm_network_interface_ids }
}

output "vpc_endpoint_ssmmessages_id" {
  description = "Map of VPC names to SSMMessages VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ssmmessages_id }
}

output "vpc_endpoint_ssmmessages_network_interface_ids" {
  description = "Map of VPC names to SSMMessages VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ssmmessages_network_interface_ids }
}

output "vpc_endpoint_ec2_id" {
  description = "Map of VPC names to EC2 VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ec2_id }
}

output "vpc_endpoint_ec2_network_interface_ids" {
  description = "Map of VPC names to EC2 VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ec2_network_interface_ids }
}

output "vpc_endpoint_ec2messages_id" {
  description = "Map of VPC names to EC2Messages VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ec2messages_id }
}

output "vpc_endpoint_ec2messages_network_interface_ids" {
  description = "Map of VPC names to EC2Messages VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ec2messages_network_interface_ids }
}

output "vpc_endpoint_ecr_api_id" {
  description = "Map of VPC names to ECR API VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecr_api_id }
}

output "vpc_endpoint_ecr_api_network_interface_ids" {
  description = "Map of VPC names to ECR API VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecr_api_network_interface_ids }
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "Map of VPC names to ECR DKR VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecr_dkr_id }
}

output "vpc_endpoint_ecr_dkr_network_interface_ids" {
  description = "Map of VPC names to ECR DKR VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecr_dkr_network_interface_ids }
}

output "vpc_endpoint_ecs_id" {
  description = "Map of VPC names to ECS VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_id }
}

output "vpc_endpoint_ecs_network_interface_ids" {
  description = "Map of VPC names to ECS VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_network_interface_ids }
}

output "vpc_endpoint_ecs_agent_id" {
  description = "Map of VPC names to ECS Agent VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_agent_id }
}

output "vpc_endpoint_ecs_agent_network_interface_ids" {
  description = "Map of VPC names to ECS Agent VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_agent_network_interface_ids }
}

output "vpc_endpoint_ecs_telemetry_id" {
  description = "Map of VPC names to ECS Telemetry VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_telemetry_id }
}

output "vpc_endpoint_ecs_telemetry_network_interface_ids" {
  description = "Map of VPC names to ECS Telemetry VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_ecs_telemetry_network_interface_ids }
}

output "vpc_endpoint_sqs_id" {
  description = "Map of VPC names to SQS VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_sqs_id }
}

output "vpc_endpoint_sqs_network_interface_ids" {
  description = "Map of VPC names to SQS VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_sqs_network_interface_ids }
}

output "vpc_endpoint_sns_id" {
  description = "Map of VPC names to SNS VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_sns_id }
}

output "vpc_endpoint_sns_network_interface_ids" {
  description = "Map of VPC names to SNS VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_sns_network_interface_ids }
}

output "vpc_endpoint_logs_id" {
  description = "Map of VPC names to CloudWatch Logs VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_logs_id }
}

output "vpc_endpoint_logs_network_interface_ids" {
  description = "Map of VPC names to CloudWatch Logs VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_logs_network_interface_ids }
}

output "vpc_endpoint_monitoring_id" {
  description = "Map of VPC names to CloudWatch Monitoring VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_monitoring_id }
}

output "vpc_endpoint_monitoring_network_interface_ids" {
  description = "Map of VPC names to CloudWatch Monitoring VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_monitoring_network_interface_ids }
}

output "vpc_endpoint_events_id" {
  description = "Map of VPC names to CloudWatch Events VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_events_id }
}

output "vpc_endpoint_events_network_interface_ids" {
  description = "Map of VPC names to CloudWatch Events VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_events_network_interface_ids }
}

output "vpc_endpoint_elasticloadbalancing_id" {
  description = "Map of VPC names to Elastic Load Balancing VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_elasticloadbalancing_id }
}

output "vpc_endpoint_elasticloadbalancing_network_interface_ids" {
  description = "Map of VPC names to Elastic Load Balancing VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_elasticloadbalancing_network_interface_ids }
}

output "vpc_endpoint_access_analyzer_id" {
  description = "Map of VPC names to Access Analyzer VPC endpoint IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_access_analyzer_id }
}

output "vpc_endpoint_access_analyzer_network_interface_ids" {
  description = "Map of VPC names to Access Analyzer VPC endpoint network interface IDs"
  value       = { for k, vpc in module.vpc : k => vpc.vpc_endpoint_access_analyzer_network_interface_ids }
}

output "vpcs" {
  description = "Map of all VPC attributes"
  value       = module.vpc
} 