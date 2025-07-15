variable "bucket" {
    type = string
    description = "The concatenated bucket name that will be in the tags"
    default = ""
}

variable "bucket_name" {
    type = string
    description = "name of S3 bucket"
    default = ""
}

variable "project" {
    type = string
    default = "client-a-com"

    validation {
        condition     = length(var.project) > 0 && length(var.project) <= 50
        error_message = "Project name must be between 1 and 50 characters long."
    }    
}

variable "environment" {
    type = string
    default = "dev"
    validation {
        condition     = contains(["dev", "staging", "prod", "test"], var.environment)
        error_message = "Environment must be one of: dev, staging, prod, test."
    }
}

variable "region" {
    type = string
    default = "eu-west-1"
    validation {
        condition     = length(var.region) > 0
        error_message = "Region must be specified."
    }    
}

variable "costcenter" {
    type = string
    default = "ITS"
    validation {
        condition     = length(var.costcenter) > 0
        error_message = "Cost center must be specified."
    }    
}

variable "tags" {
    type = map(string)
    default = {
        Environment = var.environment
        Project = var.project
        Region = var.region
        CostCenter = var.costcenter
        Terraform = True
    }
}
