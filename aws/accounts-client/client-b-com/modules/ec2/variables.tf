variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "costcenter" {
  description = "Cost center for resource tagging"
  type        = string
  default     = "IT"
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
  default     = "Infrastructure"
}

variable "instances" {
  description = "Map of EC2 instances to create"
  type = map(object({
    name                        = string
    instance_type              = string
    key_name                   = string
    monitoring                 = bool
    vpc_security_group_ids     = list(string)
    subnet_id                  = string
    associate_public_ip_address = bool
    user_data = optional(object({
      template = string
      vars     = map(any)
    }))
    tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for instance in var.instances : 
      can(regex("^[a-zA-Z0-9-]+$", instance.name))
    ])
    error_message = "Instance names must contain only alphanumeric characters and hyphens."
  }
} 