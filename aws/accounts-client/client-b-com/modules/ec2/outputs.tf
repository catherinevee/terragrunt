output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = [for instance in module.ec2_instances : instance.instance_id]
}

output "instance_private_ips" {
  description = "List of EC2 instance private IP addresses"
  value       = [for instance in module.ec2_instances : instance.private_ip]
}

output "instance_public_ips" {
  description = "List of EC2 instance public IP addresses"
  value       = [for instance in module.ec2_instances : instance.public_ip]
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = [for instance in module.ec2_instances : instance.arn]
}

output "instances" {
  description = "Map of EC2 instances with all their attributes"
  value       = module.ec2_instances
} 