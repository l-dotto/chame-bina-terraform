# Chame Bina Infrastructure Starter

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20ECS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.33+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)

> **Infraestrutura como Código (IaC) para acelerar projetos de Software House com Amazon EKS ou ECS**

Uma solução completa e padronizada para provisionar infraestrutura moderna baseada em containers, reduzindo em **90% o tempo de setup** e garantindo **segurança enterprise** desde o primeiro deploy.

## 🚀 Quick Deploy

**Deploy em 5 minutos** usando o script automatizado:

```bash
# 1. Configure suas credenciais AWS
aws configure

# 2. Clone o projeto
git clone git@ssh.dev.azure.com:v3/premiersoftbr/Engineering/terraform
cd terraform

# 3. Deploy ECS (Recomendado para início)
./deploy.sh ecs qa apply

# OU Deploy EKS (Para aplicações Kubernetes)
./deploy.sh eks qa apply
```

### Opções do Deploy Script

```bash
# Sintaxe: ./deploy.sh [orchestrator] [environment] [action]

# Orquestradores disponíveis:
./deploy.sh ecs qa apply     # Amazon ECS (Fargate)
./deploy.sh eks qa apply     # Amazon EKS (Kubernetes)

# Ambientes disponíveis:
./deploy.sh ecs qa apply     # Ambiente QA/Desenvolvimento
./deploy.sh ecs prod apply   # Ambiente Produção

# Ações disponíveis:
./deploy.sh ecs qa plan      # Ver mudanças
./deploy.sh ecs qa apply     # Aplicar infraestrutura
./deploy.sh ecs qa destroy   # Destruir infraestrutura
```

## O Que É Criado

### **Amazon ECS (Recomendado)**
- **ECS Cluster** com Fargate (serverless)
- **Services** dinâmicos: `backend-qa`, `frontend-qa`
- **Application Load Balancer** configurado
- **Auto Scaling** e **Health Checks**
- **CloudWatch Logs** automático

### **Amazon EKS (Para Kubernetes)**
- **EKS Cluster** totalmente gerenciado
- **Node Groups** com Auto Scaling
- **AWS Load Balancer Controller**
- **RBAC** e **Service Accounts**
- **OIDC** para Workload Identity

### **Recursos Compartilhados**
- **VPC** com 3 AZs (Alta Disponibilidade)
- **Subnets** públicas e privadas
- **NAT Gateways** para saída de internet
- **ECR** repositories para imagens Docker
- **Security Groups** otimizados

## Documentação

| Documento | Descrição | Quando Consultar |
|-----------|-----------|------------------|
| **[Objetivos do Projeto](PROJECT_OBJECTIVE.md)** | Por que este projeto existe, benefícios e roadmap | Antes de implementar |
| **[Documentação de Arquitetura](ARCHITECTURE.md)** | Guia técnico completo, instalação e configuração | Durante implementação |
| **[Azure DevOps OIDC](README-OIDC.md)** | Configurar pipelines sem chaves de acesso | Para CI/CD automatizado |
| **[Guia de Segurança](SECURITY.md)** | Proteção de tokens e credenciais sensíveis | Durante configuração |
| **[Referência Terraform](#-referência-terraform)** | Inputs, outputs e recursos (abaixo) | Durante desenvolvimento |

## O Que Este Projeto Resolve

**Setup de infraestrutura** em minutos ao invés de semanas  
**Padronização completa** entre todos os projetos  
**Segurança enterprise** sem configuração manual  
**Custos otimizados** com recursos right-sized  
**Alta disponibilidade** multi-AZ automática  
**Flexibilidade total** - ECS ou EKS conforme necessidade  

### Ideal Para

- **Aplicações Web** (React, Vue, Angular)
- **APIs RESTful** (Node.js, Python, Java, PHP)
- **Microserviços** containerizados
- **E-commerce** e dashboards
- **Aplicações full-stack** de qualquer porte

## Arquitetura

### ECS Architecture (Serverless)
```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud                            │
│  ┌─────────────────────────────────────────────────┐     │
│  │                VPC 10.1.0.0/16                 │     │
│  │  ┌─────────────┐    ┌─────────────────────────┐ │     │
│  │  │   Public    │    │        Private          │ │     │
│  │  │   Subnets   │    │        Subnets          │ │     │
│  │  │             │    │                         │ │     │
│  │  │ NAT Gateway │    │    ECS Services         │ │     │
│  │  │Load Balancer│    │    (Fargate)            │ │     │
│  │  │             │    │  ┌─────────────────┐    │ │     │
│  │  │             │    │  │ backend-qa      │    │ │     │
│  │  │             │    │  │ frontend-qa     │    │ │     │
│  │  │             │    │  └─────────────────┘    │ │     │
│  │  └─────────────┘    └─────────────────────────┘ │     │
│  └─────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### EKS Architecture (Kubernetes)
```
┌─────────────────────────────────────────────────────────┐
│                    AWS Cloud                            │
│  ┌─────────────────────────────────────────────────┐     │
│  │                VPC 10.1.0.0/16                 │     │
│  │  ┌─────────────┐    ┌─────────────────────────┐ │     │
│  │  │   Public    │    │        Private          │ │     │
│  │  │   Subnets   │    │        Subnets          │ │     │
│  │  │             │    │                         │ │     │
│  │  │ NAT Gateway │    │   EKS Worker Nodes      │ │     │
│  │  │Load Balancer│    │      + Pods             │ │     │
│  │  │ Controller  │    │  ┌─────────────────┐    │ │     │
│  │  │             │    │  │ backend-qa      │    │ │     │
│  │  │             │    │  │ frontend-qa     │    │ │     │
│  │  │             │    │  └─────────────────┘    │ │     │
│  │  └─────────────┘    └─────────────────────────┘ │     │
│  └─────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

**[Ver arquitetura completa e detalhes técnicos](ARCHITECTURE.md)**

## Custos Estimados

| Orchestrator | Ambiente | Mensal (USD) | Componentes |
|--------------|----------|-------------|-------------|
| **ECS** | Desenvolvimento | ~$94 | ECS + Fargate + NAT + ALB |
| **ECS** | Produção | ~$156-218 | ECS + Fargate (HA) + NAT + ALB |
| **EKS** | Desenvolvimento | ~$142 | EKS + 1x t3.micro + NAT + ALB |
| **EKS** | Produção | ~$219-324 | EKS + 2-3x t3.medium + NAT + ALB |

**ECS é mais econômico para começar, EKS oferece mais flexibilidade para escalar**

**[Ver análise completa de custo-benefício](PROJECT_OBJECTIVE.md#análise-de-custo-benefício)**

## Configuração Avançada

### Personalizar Ambientes

Edite os arquivos em `environments/`:
- `environments/qa/terraform.tfvars` - Ambiente de desenvolvimento
- `environments/prod/terraform.tfvars` - Ambiente de produção

### Configurar Azure DevOps OIDC

Para pipelines automatizados sem chaves de acesso:

```bash
# 1. Aplicar OIDC Provider
terraform apply -target=module.aws_oidc_provider

# 2. Configurar Service Connection
# Ver guia completo em README-OIDC.md
```

### Segurança e Proteção de Tokens

Este projeto implementa proteção completa contra exposição acidental de credenciais:

```bash
# Verificar configuração de segurança
./scripts/security-check.sh

# Arquivos protegidos automaticamente:
# - *.tfvars (configurações do terraform)
# - *.env (variáveis de ambiente)
# - *token*, *secret*, *password* (qualquer arquivo sensível)
```

**Importante**: Use sempre os arquivos `.example` como referência e nunca commite credenciais reais.

## Módulos Terraform

| Módulo | Tipo | Descrição |
|--------|------|-----------|
| **`shared/network`** | Infraestrutura | VPC, Subnets, NAT Gateways |
| **`shared/ecr`** | Container Registry | Repositórios Docker dinâmicos |
| **`shared/aws-oidc-provider`** | CI/CD | OIDC para Azure DevOps |
| **`orchestrators/ecs`** | Container Orchestration | ECS Cluster + Services |
| **`orchestrators/eks/cluster`** | Container Orchestration | EKS Cluster |
| **`orchestrators/eks/managed-node-group`** | Container Orchestration | EKS Worker Nodes |
| **`load-balancer/alb-ecs`** | Load Balancing | ALB para ECS |
| **`load-balancer/alb-eks`** | Load Balancing | ALB Controller para EKS |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.10.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >=1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.38.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_oidc_provider"></a> [aws\_oidc\_provider](#module\_aws\_oidc\_provider) | ./modules/shared/aws-oidc-provider | n/a |
| <a name="module_azure_devops_connection"></a> [azure\_devops\_connection](#module\_azure\_devops\_connection) | ./modules/shared/azure-devops-connection | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/shared/ecr | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ./modules/orchestrators/ecs | n/a |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | ./modules/orchestrators/eks/cluster | n/a |
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ./modules/orchestrators/eks/managed-node-group | n/a |
| <a name="module_load_balancer_ecs"></a> [load\_balancer\_ecs](#module\_load\_balancer\_ecs) | ./modules/load-balancer/alb-ecs | n/a |
| <a name="module_load_balancer_eks"></a> [load\_balancer\_eks](#module\_load\_balancer\_eks) | ./modules/load-balancer/alb-eks | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/shared/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_arn"></a> [admin\_user\_arn](#input\_admin\_user\_arn) | ARN of the IAM user that should have admin access to the EKS cluster | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to AWS resources | `string` | n/a | yes |
| <a name="input_azure_devops_organization"></a> [azure\_devops\_organization](#input\_azure\_devops\_organization) | Azure DevOps organization name | `string` | `null` | no |
| <a name="input_azure_devops_project"></a> [azure\_devops\_project](#input\_azure\_devops\_project) | Azure DevOps project name | `string` | `null` | no |
| <a name="input_azdo_personal_access_token"></a> [azdo\_personal\_access\_token](#input\_azdo\_personal\_access\_token) | Azure DevOps Personal Access Token (configure via env var AZDO_PERSONAL_ACCESS_TOKEN) | `string` | `null` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_container_orchestrator"></a> [container\_orchestrator](#input\_container\_orchestrator) | Container orchestrator to use: 'eks' or 'ecs' | `string` | `"eks"` | no |
| <a name="input_ecs_services"></a> [ecs\_services](#input\_ecs\_services) | Map of ECS service configurations | <pre>map(object({<br>    cpu               = number<br>    memory            = number<br>    desired_count     = number<br>    port              = number<br>    health_check_path = string<br>  }))</pre> | <pre>{<br>  "backend": {<br>    "cpu": 256,<br>    "desired_count": 1,<br>    "health_check_path": "/health",<br>    "memory": 512,<br>    "port": 8080<br>  },<br>  "frontend": {<br>    "cpu": 256,<br>    "desired_count": 1,<br>    "health_check_path": "/",<br>    "memory": 512,<br>    "port": 3000<br>  }<br>}</pre> | no |
| <a name="input_eks-cluster-endpoint"></a> [eks-cluster-endpoint](#input\_eks-cluster-endpoint) | EKS cluster endpoint | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., qa, prod, dev) | `string` | `"qa"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Configuration for EKS node groups | <pre>map(object({<br>    instance_types  = list(string)<br>    capacity_type   = string<br>    desired_size    = number<br>    max_size        = number<br>    min_size        = number<br>    max_unavailable = number<br>  }))</pre> | <pre>{<br>  "backend": {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_size": 1,<br>    "instance_types": [<br>      "t3.micro"<br>    ],<br>    "max_size": 2,<br>    "max_unavailable": 1,<br>    "min_size": 1<br>  },<br>  "frontend": {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_size": 1,<br>    "instance_types": [<br>      "t3.micro"<br>    ],<br>    "max_size": 2,<br>    "max_unavailable": 1,<br>    "min_size": 1<br>  }<br>}</pre> | no |
| <a name="input_oidc-identity"></a> [oidc-identity](#input\_oidc-identity) | OIDC identity provider URL | `string` | `null` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | The CIDR blocks for the private subnets | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to be used in ressources | `string` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | The CIDR blocks for the public subnets | `list(string)` | n/a | yes |
| <a name="input_repository_names"></a> [repository\_names](#input\_repository\_names) | List of ECR repository names to create | `list(string)` | <pre>[<br>  "backend",<br>  "frontend"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_devops_oidc_info"></a> [azure\_devops\_oidc\_info](#output\_azure\_devops\_oidc\_info) | Azure DevOps OIDC provider information (null if not configured) |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint of the EKS cluster (null if ECS is used) |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the cluster (EKS or ECS) |
| <a name="output_ecr_backend_repository_name"></a> [ecr\_backend\_repository\_name](#output\_ecr\_backend\_repository\_name) | Name of the ECR repository for backend |
| <a name="output_ecr_backend_repository_url"></a> [ecr\_backend\_repository\_url](#output\_ecr\_backend\_repository\_url) | URL of the ECR repository for backend |
| <a name="output_ecr_frontend_repository_name"></a> [ecr\_frontend\_repository\_name](#output\_ecr\_frontend\_repository\_name) | Name of the ECR repository for frontend |
| <a name="output_ecr_frontend_repository_url"></a> [ecr\_frontend\_repository\_url](#output\_ecr\_frontend\_repository\_url) | URL of the ECR repository for frontend |
| <a name="output_ecr_repositories"></a> [ecr\_repositories](#output\_ecr\_repositories) | Map of ECR repository information |
| <a name="output_ecs_cluster_info"></a> [ecs\_cluster\_info](#output\_ecs\_cluster\_info) | ECS cluster information (null if EKS is used) |
| <a name="output_eks_cluster_info"></a> [eks\_cluster\_info](#output\_eks\_cluster\_info) | EKS cluster information (null if ECS is used) |
| <a name="output_load_balancer_dns"></a> [load\_balancer\_dns](#output\_load\_balancer\_dns) | Load balancer DNS name (ECS only - EKS uses controller-managed ALBs) |
| <a name="output_load_balancer_info"></a> [load\_balancer\_info](#output\_load\_balancer\_info) | Load balancer information based on orchestrator |
| <a name="output_orchestrator_type"></a> [orchestrator\_type](#output\_orchestrator\_type) | Type of container orchestrator deployed |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END_TF_DOCS -->