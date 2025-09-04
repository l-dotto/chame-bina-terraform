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

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS ressources"
}

variable "private_subnet_1a" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "private_subnet_1b" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "private_subnet_1c" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "admin_user_arn" {
  type        = string
  description = "ARN of the IAM user that should have admin access to the EKS cluster"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "oidc-identity" {
  type        = string
  description = "HTTPS OIDC identity provider URL of the cluster EKS"
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., qa, prod, dev)"
  type        = string
  default     = "qa"
}

variable "node_groups" {
  description = "Map of node group configurations"
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
  }
}

variable "database_environment_vars" {
  description = "Database environment variables to inject into Kubernetes deployments"
  type        = map(string)
  default     = {}
  sensitive   = true
}
