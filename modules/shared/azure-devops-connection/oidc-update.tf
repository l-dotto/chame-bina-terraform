# Configurar OIDC na service connection via API REST
resource "null_resource" "configure_oidc" {
  depends_on = [azuredevops_serviceendpoint_aws.oidc_connection]

  provisioner "local-exec" {
    command = "${path.module}/configure-oidc.sh"

    environment = {
      SERVICE_ENDPOINT_ID = azuredevops_serviceendpoint_aws.oidc_connection.id
      PROJECT_ID          = data.azuredevops_project.project.id
      AZDO_PAT            = var.azdo_personal_access_token
      ORGANIZATION        = var.azure_devops_organization
      PROJECT_NAME        = var.azure_devops_project
      ROLE_ARN            = var.aws_role_arn
      AWS_REGION          = var.aws_region
    }
  }

  # Trigger recreation when key values change
  triggers = {
    role_arn     = var.aws_role_arn
    organization = var.azure_devops_organization
    project      = var.azure_devops_project
    service_name = "aws-${var.project_name}"
    endpoint_id  = azuredevops_serviceendpoint_aws.oidc_connection.id
  }
}