output "ecr_backend_repository_url" {
  description = "URL of the ECR repository for backend"
  value       = module.ecr.backend_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the ECR repository for frontend"
  value       = module.ecr.frontend_repository_url
}

output "ecr_backend_repository_name" {
  description = "Name of the ECR repository for backend"
  value       = module.ecr.backend_repository_name
}

output "ecr_frontend_repository_name" {
  description = "Name of the ECR repository for frontend"
  value       = module.ecr.frontend_repository_name
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks-cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks-cluster.eks-cluster-endpoint
}