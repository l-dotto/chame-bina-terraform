resource "aws_eks_node_group" "aws_eks_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-backend-qa"
  node_role_arn   = aws_iam_role.eks-mng-role.arn
  subnet_ids = concat(
    var.private_subnet_1a,
    var.private_subnet_1b,
    var.private_subnet_1c
  )

  instance_types = ["t3.micro"]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_policy_attachment.eks-mng-role-attachment-worker,
    aws_iam_policy_attachment.eks-mng-role-attachment-cni,
    aws_iam_policy_attachment.eks-mng-role-attachment-ecr,
  ]

  tags = merge(
    var.tags,
    {
      name = "${var.project_name}-backend-qa"
    }
  )
}