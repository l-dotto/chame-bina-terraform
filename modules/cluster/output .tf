output "oidc" {
  value = data.tls_certificate.cluster_eks.certificates[*].sha1_fingerprint
}

output "cluster_name" {
  value = aws_eks_cluster.aws_eks_cluster.name
}