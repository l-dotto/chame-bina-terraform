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
