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

variable "admin_user_arn" {
  type        = string
  description = "ARN of the IAM user that should have admin access to the EKS cluster"
  default     = null
}

variable "oidc-identity" {
  type        = string
  description = "OIDC identity provider URL"
  default     = null
}

variable "eks-cluster-endpoint" {
  type        = string
  description = "EKS cluster endpoint"
  default     = null
}