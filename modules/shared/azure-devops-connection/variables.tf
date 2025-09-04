variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "azure_devops_organization" {
  type        = string
  description = "Azure DevOps organization name"
}

variable "azure_devops_project" {
  type        = string
  description = "Azure DevOps project name"
}

variable "aws_role_arn" {
  type        = string
  description = "ARN of the AWS IAM role to assume"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "qa"
}

variable "azdo_personal_access_token" {
  type        = string
  description = "Azure DevOps Personal Access Token"
  sensitive   = true
}