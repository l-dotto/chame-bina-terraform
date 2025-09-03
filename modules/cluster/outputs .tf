output "oidc" {
  value = data.tls_certificate.cluster_eks.certificates[*].sha1_fingerprint
}

output "oidc-identity" {
  value = aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_name" {
  value = aws_eks_cluster.aws_eks_cluster.name
}

output "eks-certificate-authority" {
  value = aws_eks_cluster.aws_eks_cluster.certificate_authority[0].data
}

output "eks-cluster-endpoint" {
  value = aws_eks_cluster.aws_eks_cluster.endpoint
}