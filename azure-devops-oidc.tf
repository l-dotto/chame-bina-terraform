# OIDC Provider e Role AWS para Azure DevOps
module "aws_oidc_provider" {
  count  = var.azure_devops_organization != null ? 1 : 0
  source = "./modules/shared/aws-oidc-provider"

  project_name              = var.project_name
  environment               = var.environment
  azure_devops_organization = var.azure_devops_organization
  azure_devops_project      = var.azure_devops_project
  tags                      = local.common_tags
}


module "azure_devops_connection" {
  count  = var.azure_devops_organization != null && var.azdo_personal_access_token != null ? 1 : 0
  source = "./modules/shared/azure-devops-connection"

  project_name               = var.project_name
  environment                = var.environment
  azure_devops_organization  = var.azure_devops_organization
  azure_devops_project       = var.azure_devops_project
  aws_role_arn               = module.aws_oidc_provider[0].role_arn
  aws_region                 = var.aws_region
  azdo_personal_access_token = var.azdo_personal_access_token
}