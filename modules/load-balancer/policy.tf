resource "aws_iam_policy" "load-balancer-policy" {
  description = "Policy needed for load balancer controller"

  policy = (
    file("${path.module}/iam-policy.json")
  )

  tags = merge(
    var.tags,
    {
      name = "${var.project_name}-load-balancer-policy"
    }
  )
}