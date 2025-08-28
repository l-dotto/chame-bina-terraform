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

variable "public_subnet_1a" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "public_subnet_1b" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "public_subnet_1c" {
  type        = list(string)
  description = "List of public subnet IDs"
}