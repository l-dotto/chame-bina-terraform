# Shared outputs (always available)
output "orchestrator_type" {
  description = "Type of container orchestrator deployed"
  value       = var.container_orchestrator
}

output "ecr_repositories" {
  description = "Map of ECR repository information"
  value       = module.ecr.repositories
}

# Backwards compatibility for ECR outputs
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

# Network outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    module.network.subnet-public-1a,
    module.network.subnet-public-1b,
    module.network.subnet-public-1c
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [
    module.network.subnet-private-1a,
    module.network.subnet-private-1b,
    module.network.subnet-private-1c
  ]
}

# Conditional EKS outputs
output "eks_cluster_info" {
  description = "EKS cluster information (null if ECS is used)"
  value = local.is_eks ? {
    cluster_name     = module.eks_cluster[0].cluster_name
    cluster_endpoint = module.eks_cluster[0].eks-cluster-endpoint
    oidc_issuer      = module.eks_cluster[0].oidc-identity
  } : null
}

# Conditional ECS outputs
output "ecs_cluster_info" {
  description = "ECS cluster information (null if EKS is used)"
  value = local.is_ecs ? {
    cluster_name       = module.ecs_cluster[0].cluster_name
    cluster_arn        = module.ecs_cluster[0].cluster_arn
    capacity_providers = module.ecs_cluster[0].capacity_providers
  } : null
}

# Load balancer outputs based on orchestrator
output "load_balancer_dns" {
  description = "Load balancer DNS name (ECS only - EKS uses controller-managed ALBs)"
  value       = local.is_ecs && length(module.load_balancer_ecs) > 0 ? module.load_balancer_ecs[0].dns_name : null
}

output "load_balancer_info" {
  description = "Load balancer information based on orchestrator"
  value = local.is_eks ? (
    length(module.load_balancer_eks) > 0 ? {
      type                 = "eks-controller"
      controller_installed = module.load_balancer_eks[0].controller_installed
      service_account      = "${module.load_balancer_eks[0].service_account_namespace}/${module.load_balancer_eks[0].service_account_name}"
      note                 = "ALBs are created dynamically by the controller based on Ingress resources"
    } : null
    ) : (
    length(module.load_balancer_ecs) > 0 ? {
      type              = "ecs-alb"
      dns_name          = module.load_balancer_ecs[0].dns_name
      target_group_arn  = module.load_balancer_ecs[0].target_group_arn
      security_group_id = module.load_balancer_ecs[0].security_group_id
    } : null
  )
}

# Backwards compatibility outputs (for EKS)
output "cluster_name" {
  description = "Name of the cluster (EKS or ECS)"
  value = local.is_eks ? (
    length(module.eks_cluster) > 0 ? module.eks_cluster[0].cluster_name : null
    ) : (
    length(module.ecs_cluster) > 0 ? module.ecs_cluster[0].cluster_name : null
  )
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster (null if ECS is used)"
  value       = local.is_eks && length(module.eks_cluster) > 0 ? module.eks_cluster[0].eks-cluster-endpoint : null
}