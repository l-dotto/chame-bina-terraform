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
