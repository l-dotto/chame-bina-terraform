output "service_endpoint_id" {
  description = "ID of the Azure DevOps service endpoint"
  value       = azuredevops_serviceendpoint_aws.oidc_connection.id
}

output "service_endpoint_name" {
  description = "Name of the Azure DevOps service endpoint"
  value       = azuredevops_serviceendpoint_aws.oidc_connection.service_endpoint_name
}