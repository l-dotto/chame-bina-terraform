output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres.id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.postgres.hosted_zone_id
}

output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.postgres.identifier
}

output "db_instance_resource_id" {
  description = "RDS instance resource ID"
  value       = aws_db_instance.postgres.resource_id
}

output "db_instance_status" {
  description = "RDS instance status"
  value       = aws_db_instance.postgres.status
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_instance_username" {
  description = "Database username"
  value       = aws_db_instance.postgres.username
}

output "db_instance_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.postgres.port
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.postgres.arn
}

output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "AWS Secrets Manager secret ARN for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "AWS Secrets Manager secret name for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

# Environment variables ready for injection
output "database_environment_vars" {
  description = "Database environment variables for container deployment"
  value = {
    DB_HOST      = aws_db_instance.postgres.endpoint
    DB_PORT      = tostring(aws_db_instance.postgres.port)
    DB_NAME      = aws_db_instance.postgres.db_name
    DB_USERNAME  = aws_db_instance.postgres.username
    DB_PASSWORD  = random_password.db_password.result
    DATABASE_URL = "postgresql://${aws_db_instance.postgres.username}:${random_password.db_password.result}@${aws_db_instance.postgres.endpoint}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
  }
  sensitive = true
}