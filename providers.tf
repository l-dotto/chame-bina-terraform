terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=1.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }


  backend "s3" {
    bucket = "chame-bina"
    key    = "terraform/eks/state/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  # Provider configs will be set conditionally based on orchestrator choice
  # For now, keeping simple for validation
}

provider "helm" {
  # Provider configs will be set conditionally based on orchestrator choice
  # For now, keeping simple for validation
}

# Azure DevOps provider - configurado apenas quando necessário
provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/premiersoftbr"
  personal_access_token = var.azdo_personal_access_token
}