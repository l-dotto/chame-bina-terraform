resource "aws_eks_node_group" "aws_eks_node_group" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-${each.key}-${var.environment}"
  node_role_arn   = aws_iam_role.eks-mng-role.arn
  subnet_ids = concat(
    var.private_subnet_1a,
    var.private_subnet_1b,
    var.private_subnet_1c
  )

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  depends_on = [
    aws_iam_policy_attachment.eks-mng-role-attachment-worker,
    aws_iam_policy_attachment.eks-mng-role-attachment-cni,
    aws_iam_policy_attachment.eks-mng-role-attachment-ecr,
  ]

  tags = merge(
    var.tags,
    {
      name        = "${var.project_name}-${each.key}-${var.environment}"
      application = each.key
    }
  )
}