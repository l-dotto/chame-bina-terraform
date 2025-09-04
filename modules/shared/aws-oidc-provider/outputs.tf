output "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider"
  value       = aws_iam_openid_connect_provider.azure_devops.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC identity provider"
  value       = aws_iam_openid_connect_provider.azure_devops.url
}

output "role_arn" {
  description = "ARN of the IAM role for Azure DevOps"
  value       = aws_iam_role.azure_devops_role.arn
}

output "role_name" {
  description = "Name of the IAM role for Azure DevOps"
  value       = aws_iam_role.azure_devops_role.name
}