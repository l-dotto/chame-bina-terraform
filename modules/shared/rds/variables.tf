variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., qa, prod, dev)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks for security group rules"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "List of security group IDs that should have access to RDS"
  type        = list(string)
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.8"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage in GB for autoscaling"
  type        = number
  default     = 100
}

variable "backup_window" {
  description = "Daily time range during which automated backups are performed"
  type        = string
  default     = "03:00-04:00"
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "apply_immediately" {
  description = "Apply changes immediately or during maintenance window"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for the database"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the database"
  type        = bool
  default     = false
}