variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., qa, prod, dev)"
  default     = "qa"
}

variable "azure_devops_organization" {
  type        = string
  description = "Azure DevOps organization name"
}

variable "azure_devops_project" {
  type        = string
  description = "Azure DevOps project name"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
  default     = {}
}