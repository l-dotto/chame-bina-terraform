# Chame Bina Infrastructure Starter

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20ECS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.33+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)

> **Infraestrutura como Código (IaC) para acelerar projetos de Software House com Amazon EKS ou ECS**

Uma solução completa e padronizada para provisionar infraestrutura moderna baseada em containers, reduzindo em **90% o tempo de setup** e garantindo **segurança enterprise** desde o primeiro deploy.

## Quick Deploy

**Deploy em 5 minutos** usando o script automatizado:

```bash
# 1. Configure suas credenciais AWS
aws configure

# 2. Clone o projeto  
git clone [repository-url]
cd chame-bina-terraform

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
- **RDS PostgreSQL** com variáveis automaticamente injetadas
- **Security Groups** otimizados

## Documentação

| Documento | Descrição | Quando Consultar |
|-----------|-----------|------------------|
| **[Objetivos do Projeto](wiki/PROJECT_OBJECTIVE.md)** | Por que este projeto existe, benefícios e roadmap | Antes de implementar |
| **[Documentação de Arquitetura](wiki/ARCHITECTURE.md)** | Guia técnico completo, instalação e configuração | Durante implementação |
| **[Azure DevOps OIDC](wiki/README-OIDC.md)** | Configurar pipelines sem chaves de acesso | Para CI/CD automatizado |
| **[Guia de Segurança](wiki/SECURITY.md)** | Proteção de tokens e credenciais sensíveis | Durante configuração |

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

## Database Integration

O projeto inclui **RDS PostgreSQL** totalmente integrado:

- **Criação automática** do banco de dados PostgreSQL
- **Variáveis de ambiente** injetadas automaticamente nos containers:
  - `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`
  - `DATABASE_URL` completa para conexão direta
- **Segurança** com AWS Secrets Manager
- **Backup automático** e monitoramento
- **Alta disponibilidade** multi-AZ

### Variáveis Disponíveis na Aplicação

```bash
# Suas aplicações backend terão acesso automático a:
DB_HOST=your-db-endpoint
DB_PORT=5432
DB_NAME=your_database
DB_USERNAME=postgres
DB_PASSWORD=auto-generated-password
DATABASE_URL=postgresql://user:pass@host:port/db
```

## Configuração Avançada

### Personalizar Ambientes

Edite os arquivos em `environments/`:
- `environments/qa/terraform.tfvars` - Ambiente de desenvolvimento
- `environments/prod/terraform.tfvars` - Ambiente de produção

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

## Custos Estimados

| Orchestrator | Ambiente | Mensal (USD) | Componentes |
|--------------|----------|-------------|-------------|
| **ECS** | Desenvolvimento | ~$110 | ECS + Fargate + RDS + NAT + ALB |
| **ECS** | Produção | ~$190-250 | ECS + Fargate (HA) + RDS + NAT + ALB |
| **EKS** | Desenvolvimento | ~$160 | EKS + 1x t3.micro + RDS + NAT + ALB |
| **EKS** | Produção | ~$250-350 | EKS + 2-3x t3.medium + RDS + NAT + ALB |

**ECS é mais econômico para começar, EKS oferece mais flexibilidade para escalar**

---

> **Ver documentação completa na pasta [`wiki/`](wiki/) para detalhes técnicos e configurações avançadas.**