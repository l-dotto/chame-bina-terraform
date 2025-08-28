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
}