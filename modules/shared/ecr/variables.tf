variable "project_name" {
  type        = string
  description = "Name of the project to be used in ressources"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS ressources"
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["backend", "frontend"]
}