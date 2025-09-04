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
  description = "VPC ID where ALB will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ALB"
}