output "oidc" {
  value = data.tls_certificate.cluster_eks.certificates[*].sha1_fingerprint
}