variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks for the public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "The CIDR blocks for the private subnets"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to AWS resources"
}

variable "project_name" {
  type        = string
  description = "Name of the project to be used in ressources"
}

variable "container_orchestrator" {
  description = "Container orchestrator to use: 'eks' or 'ecs'"
  type        = string
  default     = "eks"

  validation {
    condition     = contains(["eks", "ecs"], var.container_orchestrator)
    error_message = "Container orchestrator must be either 'eks' or 'ecs'."
  }
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["backend", "frontend"]
}

variable "admin_user_arn" {
  type        = string
  description = "ARN of the IAM user that should have admin access to the EKS cluster"
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., qa, prod, dev)"
  type        = string
  default     = "qa"
}

variable "node_groups" {
  description = "Configuration for EKS node groups"
  type = map(object({
    instance_types  = list(string)
    capacity_type   = string
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
  }))
  default = {
    backend = {
      instance_types  = ["t3.micro"]
      capacity_type   = "ON_DEMAND"
      desired_size    = 1
      max_size        = 2
      min_size        = 1
      max_unavailable = 1
    }
    frontend = {
      instance_types  = ["t3.micro"]
      capacity_type   = "ON_DEMAND"
      desired_size    = 1
      max_size        = 2
      min_size        = 1
      max_unavailable = 1
    }
  }
}

variable "oidc-identity" {
  type        = string
  description = "OIDC identity provider URL"
  default     = null
}

variable "ecs_services" {
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

variable "eks-cluster-endpoint" {
  type        = string
  description = "EKS cluster endpoint"
  default     = null
}