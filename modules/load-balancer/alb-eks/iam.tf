resource "aws_iam_role" "load-balancer-role" {
  name               = "${var.project_name}-load-balancer-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.account-id.account_id}:oidc-provider/${split("//", var.oidc_identity[0])[1]}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${split("//", var.oidc_identity[0])[1]}:aud": "sts.amazonaws.com",
                    "${split("//", var.oidc_identity[0])[1]}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

  tags = merge(
    var.tags,
    {
      name = "${var.project_name}-load-balancer-role"
    }
  )
}

resource "aws_iam_policy_attachment" "eks-load-balancer-role" {
  name       = "${var.project_name}-load-balancer-policy"
  roles      = [aws_iam_role.load-balancer-role.name]
  policy_arn = aws_iam_policy.load-balancer-policy.arn
}