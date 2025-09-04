resource "aws_eks_cluster" "aws_eks_cluster" {
  name = "${var.project_name}-eks-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.33"

  vpc_config {
    subnet_ids = concat(
      var.public_subnet_1a,
      var.public_subnet_1b,
      var.public_subnet_1c
    )

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_policy_attachment.eks-cluster-role-attachment
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-cluster"
    }
  )
}

resource "aws_eks_access_entry" "admin_user" {
  count         = var.admin_user_arn != null ? 1 : 0
  cluster_name  = aws_eks_cluster.aws_eks_cluster.name
  principal_arn = var.admin_user_arn
  type          = "STANDARD"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-admin-access-entry"
    }
  )
}

resource "aws_eks_access_policy_association" "admin_user_policy" {
  count         = var.admin_user_arn != null ? 1 : 0
  cluster_name  = aws_eks_cluster.aws_eks_cluster.name
  principal_arn = var.admin_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin_user
  ]
}
