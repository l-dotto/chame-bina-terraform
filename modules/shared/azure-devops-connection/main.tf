terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

# Get project data
data "azuredevops_project" "project" {
  name = var.azure_devops_project
}

# Service Connection AWS básica (OIDC será configurado via UI ou API após criação)
resource "azuredevops_serviceendpoint_aws" "oidc_connection" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "aws-${var.project_name}"
  description           = "AWS connection for ${var.project_name} project - configure OIDC manually"

  # Configuração mínima - OIDC precisa ser configurado depois
  access_key_id     = "placeholder"
  secret_access_key = "placeholder"
}