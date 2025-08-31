module "eks-network" {
  source = "./modules/network"

  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.tags
}

module "eks-cluster" {
  source = "./modules/cluster"

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.tags
  public_subnet_1a     = [module.eks-network.subnet-public-1a]
  public_subnet_1b     = [module.eks-network.subnet-public-1b]
  public_subnet_1c     = [module.eks-network.subnet-public-1c]
  admin_user_arn       = var.admin_user_arn
}

module "managed_node_group" {
  source = "./modules/managed-node-group"

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.tags
  private_subnet_1a    = [module.eks-network.subnet-private-1a]
  private_subnet_1b    = [module.eks-network.subnet-private-1b]
  private_subnet_1c    = [module.eks-network.subnet-private-1c]
  admin_user_arn       = var.admin_user_arn
  cluster_name         = module.eks-cluster.cluster_name
}

module "load_balancer" {
  source = "./modules/load-balancer"

  project_name = var.project_name
  tags         = local.tags
  cluster_name = module.eks-cluster.cluster_name
}