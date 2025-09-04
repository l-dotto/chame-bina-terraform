# Commented out until cluster is created and configured
# resource "helm_release" "eks-helm-loadbalancer-controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set = [
#     {
#       name  = "clusterName"
#       value = var.cluster_name
#     },
#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-controller"
#     },
#     {
#       name  = "replicaCount"
#       value = "1"
#     },
#     {
#       name  = "vpcId"
#       value = data.aws_vpc.eks-vpc.id
#     }
#   ]
# }