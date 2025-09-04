variable "project_name" {
  type        = string
  description = "Name of the project to be used in resources"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS resources will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS services"
}

variable "environment" {
  description = "Environment name (e.g., qa, prod, dev)"
  type        = string
  default     = "qa"
}

variable "services" {
  description = "Map of ECS service configurations"
  type = map(object({
    cpu               = number
    memory            = number
    desired_count     = number
    port              = number
    health_check_path = string
  }))
  default = {
    backend = {
      cpu               = 256
      memory            = 512
      desired_count     = 1
      port              = 8080
      health_check_path = "/health"
    }
    frontend = {
      cpu               = 256
      memory            = 512
      desired_count     = 1
      port              = 3000
      health_check_path = "/"
    }
  }
}

variable "ecr_repositories" {
  description = "Map of ECR repository URLs"
  type        = map(string)
  default     = {}
}