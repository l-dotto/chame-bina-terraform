data "aws_caller_identity" "account-id" {}

data "aws_region" "aws-region" {}

data "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
}

data "aws_vpc" "eks-vpc" {
  id = data.aws_eks_cluster.eks-cluster.vpc_config[0].vpc_id
}