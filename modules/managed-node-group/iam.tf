resource "aws_iam_role" "eks-mng-role" {
  name = "${var.project_name}-eks-mng-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      name = "${var.project_name}-eks-mng-role"
    }
  )
}

resource "aws_iam_policy_attachment" "eks-mng-role-attachment-worker" {
  name       = "${var.project_name}-eks-mng-role-attachment-worker"
  roles      = [aws_iam_role.eks-mng-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "eks-mng-role-attachment-ecr" {
  name       = "${var.project_name}-eks-mng-role-attachment-ecr"
  roles      = [aws_iam_role.eks-mng-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_policy_attachment" "eks-mng-role-attachment-cni" {
  name       = "${var.project_name}-eks-mng-role-attachment-cni"
  roles      = [aws_iam_role.eks-mng-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}