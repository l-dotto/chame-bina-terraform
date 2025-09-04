# Commented out until cluster is created
# resource "kubernetes_service_account" "eks-load-balancer-controller-sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#     "eks.amazonaws.com/role-arn" = aws_iam_role.load-balancer-role.arn }
#   }
# }