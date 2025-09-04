data "tls_certificate" "cluster_eks" {
  url = aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "aws_eks_cluster_oidc" {
  url = data.tls_certificate.cluster_eks.url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = data.tls_certificate.cluster_eks.certificates[*].sha1_fingerprint

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-oidc"
    }
  )
}