output "service_account_name" {
  description = "Name of the Kubernetes service account for AWS Load Balancer Controller"
  value       = "aws-load-balancer-controller"
}

output "service_account_namespace" {
  description = "Namespace of the Kubernetes service account"
  value       = "kube-system"
}

output "iam_role_arn" {
  description = "ARN of the IAM role for the load balancer controller"
  value       = aws_iam_role.load-balancer-role.arn
}

output "helm_release_name" {
  description = "Name of the Helm release for AWS Load Balancer Controller"
  value       = "aws-load-balancer-controller"
}

output "helm_release_status" {
  description = "Status of the Helm release"
  value       = "ready-for-manual-install"
}

# Note: EKS doesn't create an ALB directly - ALBs are created by the controller
# based on Ingress resources. This is different from ECS which creates ALB directly.
output "controller_installed" {
  description = "Whether AWS Load Balancer Controller is installed"
  value       = false
}