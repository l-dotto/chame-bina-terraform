# Local variables for conditional logic
locals {
  is_eks = var.container_orchestrator == "eks"
  is_ecs = var.container_orchestrator == "ecs"

  common_tags = merge(
    local.tags,
    {
      Orchestrator = var.container_orchestrator
    }
  )
}

# Shared resources (always created)
module "network" {
  source = "./modules/shared/network"

  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.common_tags
}

module "ecr" {
  source = "./modules/shared/ecr"

  project_name     = var.project_name
  repository_names = var.repository_names
  tags             = local.common_tags
}

# EKS - Conditional resources
module "eks_cluster" {
  count  = local.is_eks ? 1 : 0
  source = "./modules/orchestrators/eks/cluster"

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.common_tags
  public_subnet_1a     = [module.network.subnet-public-1a]
  public_subnet_1b     = [module.network.subnet-public-1b]
  public_subnet_1c     = [module.network.subnet-public-1c]
  admin_user_arn       = var.admin_user_arn
}

module "eks_managed_node_group" {
  count  = local.is_eks ? 1 : 0
  source = "./modules/orchestrators/eks/managed-node-group"

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  environment          = var.environment
  tags                 = local.common_tags
  private_subnet_1a    = [module.network.subnet-private-1a]
  private_subnet_1b    = [module.network.subnet-private-1b]
  private_subnet_1c    = [module.network.subnet-private-1c]
  admin_user_arn       = var.admin_user_arn
  cluster_name         = module.eks_cluster[0].cluster_name
  oidc-identity        = module.eks_cluster[0].oidc-identity
  node_groups          = var.node_groups

  depends_on = [module.eks_cluster]
}

# ECS - Conditional resources
module "ecs_cluster" {
  count  = local.is_ecs ? 1 : 0
  source = "./modules/orchestrators/ecs"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  subnet_ids = [
    module.network.subnet-private-1a,
    module.network.subnet-private-1b,
    module.network.subnet-private-1c
  ]
  services = var.ecs_services
  ecr_repositories = {
    for repo_name in var.repository_names : repo_name => "${module.ecr.repositories[repo_name].repository_url}:latest"
  }
  tags = local.common_tags
}

# Load Balancer - Conditional based on orchestrator
module "load_balancer_eks" {
  count  = local.is_eks ? 1 : 0
  source = "./modules/load-balancer/alb-eks"

  project_name  = var.project_name
  tags          = local.common_tags
  cluster_name  = module.eks_cluster[0].cluster_name
  oidc_identity = [module.eks_cluster[0].oidc-identity]

  depends_on = [module.eks_cluster]
}

module "load_balancer_ecs" {
  count  = local.is_ecs ? 1 : 0
  source = "./modules/load-balancer/alb-ecs"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  subnet_ids = [
    module.network.subnet-public-1a,
    module.network.subnet-public-1b,
    module.network.subnet-public-1c
  ]
  tags = local.common_tags
}