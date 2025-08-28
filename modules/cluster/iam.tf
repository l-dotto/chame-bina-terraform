resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      name = "${var.project_name}-eks-cluster-role"
    }
  )
}

resource "aws_iam_policy_attachment" "eks-cluster-role-attachment" {
  name       = "${var.project_name}-eks-cluster-role-attachment"
  roles      = [aws_iam_role.eks-cluster-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}