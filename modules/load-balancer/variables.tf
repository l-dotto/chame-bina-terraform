variable "project_name" {
  type        = string
  description = "Name of the project to be used in ressources"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS ressources"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}


variable "oidc_identity" {
  type        = list(string)
  description = "OIDC identity provider URL of the cluster EKS"
}