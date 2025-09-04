output "service_arns" {
  description = "ARNs of the ECS services"
  value = {
    for key, service in aws_ecs_service.app : key => service.id
  }
}

output "task_definition_arns" {
  description = "ARNs of the ECS task definitions"
  value = {
    for key, task_def in aws_ecs_task_definition.app : key => task_def.arn
  }
}

output "security_group_ids" {
  description = "Security group IDs for the ECS services"
  value = {
    for key, sg in aws_security_group.ecs_service : key => sg.id
  }
}

output "log_group_names" {
  description = "CloudWatch log group names"
  value = {
    for key, log_group in aws_cloudwatch_log_group.app : key => log_group.name
  }
}