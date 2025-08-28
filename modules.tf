module "eks-network" {
  source = "./modules/network"

  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region           = var.aws_region
  project_name         = var.project_name
  tags                 = local.tags
}