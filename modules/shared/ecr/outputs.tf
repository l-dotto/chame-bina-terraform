output "repositories" {
  description = "Map of ECR repository information"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => {
      name           = repo.name
      repository_url = repo.repository_url
      registry_id    = repo.registry_id
      arn            = repo.arn
    }
  }
}

# Backwards compatibility outputs
output "backend_repository_url" {
  description = "URL of the ECR repository for backend"
  value       = try(aws_ecr_repository.repositories["backend"].repository_url, null)
}

output "backend_repository_name" {
  description = "Name of the ECR repository for backend"
  value       = try(aws_ecr_repository.repositories["backend"].name, null)
}

output "backend_registry_id" {
  description = "Registry ID where the backend repository resides"
  value       = try(aws_ecr_repository.repositories["backend"].registry_id, null)
}

output "frontend_repository_url" {
  description = "URL of the ECR repository for frontend"
  value       = try(aws_ecr_repository.repositories["frontend"].repository_url, null)
}

output "frontend_repository_name" {
  description = "Name of the ECR repository for frontend"
  value       = try(aws_ecr_repository.repositories["frontend"].name, null)
}

output "frontend_registry_id" {
  description = "Registry ID where the frontend repository resides"
  value       = try(aws_ecr_repository.repositories["frontend"].registry_id, null)
}