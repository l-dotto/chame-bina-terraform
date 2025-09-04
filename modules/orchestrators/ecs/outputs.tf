output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "capacity_providers" {
  description = "List of capacity providers"
  value       = aws_ecs_cluster_capacity_providers.main.capacity_providers
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "service_arns" {
  description = "ARNs of the ECS services"
  value       = module.ecs_services.service_arns
}

output "task_definition_arns" {
  description = "ARNs of the ECS task definitions"
  value       = module.ecs_services.task_definition_arns
}

output "log_group_names" {
  description = "CloudWatch log group names"
  value       = module.ecs_services.log_group_names
}