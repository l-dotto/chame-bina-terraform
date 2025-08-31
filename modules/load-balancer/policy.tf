resource "aws_iam_policy" "policy_load_balancer" {
  name        = "${var.project_name}-load-balancer-policy"
  path        = "/"
  description = "Policy needed for load balancer controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}