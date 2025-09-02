# Chame Bina Infrastructure Starter

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.33+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)

> **Infraestrutura como Código (IaC) para acelerar projetos de Software House com Amazon EKS**

Uma solução completa e padronizada para provisionar infraestrutura moderna baseada em containers, reduzindo em **90% o tempo de setup** e garantindo **segurança enterprise** desde o primeiro deploy.

## Quick Start

```bash
# 1. Configure suas credenciais AWS
aws configure

# 2. Clone e configure
git clone [repository-url]
cd chame-bina-terraform
cp terraform.tfvars.example terraform.tfvars

# 3. Deploy em 20 minutos
terraform init
terraform plan
terraform apply
```

## Documentação

| Documento | Descrição | Quando Consultar |
|-----------|-----------|------------------|
| **[Objetivos do Projeto](PROJECT_OBJECTIVE.md)** | Por que este projeto existe, benefícios e roadmap | Antes de implementar |
| **[Documentação de Arquitetura](ARCHITECTURE.md)** | Guia técnico completo, instalação e configuração | Durante implementação |
| **[Referência Terraform](#-referência-terraform)** | Inputs, outputs e recursos (abaixo) | Durante desenvolvimento |

## O Que Este Projeto Resolve

✅ **Setup de infraestrutura** em minutos ao invés de semanas  
✅ **Padronização completa** entre todos os projetos  
✅ **Segurança enterprise** sem configuração manual  
✅ **Custos otimizados** com recursos right-sized  
✅ **Alta disponibilidade** multi-AZ automática  

### Ideal Para

- **Aplicações Web** (React, Vue, Angular)
- **APIs RESTful** (Node.js, Python, Java, PHP)
- **Microserviços** containerizados
- **E-commerce** e dashboards
- **Aplicações full-stack** de qualquer porte

## Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                    AWS Cloud                        │
│  ┌───────────────────────────────────────────────┐  │
│  │              VPC 10.0.0.0/16                 │  │
│  │  ┌─────────────┐    ┌──────────────────────┐  │  │
│  │  │   Public    │    │      Private         │  │  │
│  │  │   Subnets   │    │      Subnets         │  │  │
│  │  │             │    │                      │  │  │
│  │  │ NAT Gateway │    │   EKS Worker Nodes   │  │  │
│  │  │Load Balancer│    │      + Pods          │  │  │
│  │  └─────────────┘    └──────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

** [Ver arquitetura completa e detalhes técnicos](ARCHITECTURE.md)**

## ⚡ Custos Estimados

| Ambiente | Mensal (USD) | Componentes |
|----------|-------------|-------------|
| **Desenvolvimento** | ~$142 | EKS + 1x t3.micro + NAT + ALB |
| **Produção** | ~$219-324 | EKS + 2-3x t3.medium + NAT + ALB |

** [Ver análise completa de custo-benefício](PROJECT_OBJECTIVE.md#análise-de-custo-benefício)**

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.10.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.38.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks-cluster"></a> [eks-cluster](#module\_eks-cluster) | ./modules/cluster | n/a |
| <a name="module_eks-network"></a> [eks-network](#module\_eks-network) | ./modules/network | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load-balancer | n/a |
| <a name="module_managed_node_group"></a> [managed\_node\_group](#module\_managed\_node\_group) | ./modules/managed-node-group | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_arn"></a> [admin\_user\_arn](#input\_admin\_user\_arn) | ARN of the IAM user that should have admin access to the EKS cluster | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to AWS resources | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_eks-cluster-endpoint"></a> [eks-cluster-endpoint](#input\_eks-cluster-endpoint) | EKS cluster endpoint | `string` | `null` | no |
| <a name="input_oidc-identity"></a> [oidc-identity](#input\_oidc-identity) | OIDC identity provider URL | `string` | `null` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | The CIDR blocks for the private subnets | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to be used in ressources | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | The CIDR blocks for the public subnets | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->