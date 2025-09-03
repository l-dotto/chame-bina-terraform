output "backend_repository_url" {
  description = "URL of the ECR repository for backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "backend_repository_name" {
  description = "Name of the ECR repository for backend"
  value       = aws_ecr_repository.backend.name
}

output "backend_registry_id" {
  description = "Registry ID where the backend repository resides"
  value       = aws_ecr_repository.backend.registry_id
}

output "frontend_repository_url" {
  description = "URL of the ECR repository for frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "frontend_repository_name" {
  description = "Name of the ECR repository for frontend"
  value       = aws_ecr_repository.frontend.name
}

output "frontend_registry_id" {
  description = "Registry ID where the frontend repository resides"
  value       = aws_ecr_repository.frontend.registry_id
}