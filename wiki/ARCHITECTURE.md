# Documentação de Arquitetura

## INPUTS OBRIGATÓRIOS - LEIA PRIMEIRO

> ⚠️ **IMPORTANTE**: Antes de provisionar a infraestrutura, você **DEVE** configurar os seguintes parâmetros no arquivo `terraform.tfvars`. O `project_name` é especialmente crítico pois será replicado em toda a infraestrutura e utilizado nas pipelines futuras.

```hcl
# ===== CONFIGURAÇÃO OBRIGATÓRIA =====
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
aws_region           = "us-east-1"
project_name         = "projeto-cliente"  # CRÍTICO: Use nome único por cliente
admin_user_arn       = "arn:aws:iam::ACCOUNT:user/USERNAME"  # Seu ARN IAM
```

### **Importância do `project_name`**

O `project_name` é o **DNA** da sua infraestrutura:

-  **Nomeia todos os recursos AWS** (VPC, EKS, Load Balancers, etc.)
-  **Organiza custos** por cliente/projeto no AWS Cost Explorer
-  **Identifica recursos** em dashboards e logs
-  **Base para pipelines CI/CD** futuras
-  **Compliance e auditoria** por projeto

**Exemplos de nomenclatura:**
```bash
# ✅ Bons exemplos
project_name = "banco-digital"
project_name = "ecommerce-startup"  
project_name = "dashboard-analytics"

# ❌ Evite
project_name = "test123"
project_name = "projeto-teste"
project_name = "cliente-x"
```

---

## Índice

1. [Pré-requisitos e Instalação](#-pré-requisitos-e-instalação)
2. [Referência Completa - Terraform Docs](#-referência-completa---terraform-docs)
3. [Visão Geral da Arquitetura](#-visão-geral-da-arquitetura)
4. [Arquitetura de Rede](#️-arquitetura-de-rede)
5. [Segurança e Compliance](#-segurança-e-compliance)
6. [Módulos da Solução](#-módulos-da-solução)
7. [Fluxo de Dados](#-fluxo-de-dados)
8. [Monitoramento e Observabilidade](#-monitoramento-e-observabilidade)
9. [Disaster Recovery e Backup](#-disaster-recovery-e-backup)
10. [Custos e Otimizações](#-custos-e-otimizações)

---

## Pré-requisitos e Instalação

### Ferramentas Obrigatórias

Antes de começar, certifique-se de ter todas as ferramentas instaladas:

#### 1. **Terraform** (v1.5+)
```bash
# macOS via Homebrew
brew install terraform

# Linux via package manager
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows via Chocolatey
choco install terraform

# Verificar instalação
terraform version
```

#### 2. **AWS CLI** (v2.x)
```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download do instalador oficial: https://aws.amazon.com/cli/

# Configurar credenciais
aws configure
```

#### 3. **kubectl** (v1.28+)
```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Windows via Chocolatey
choco install kubernetes-cli

# Verificar instalação
kubectl version --client
```

#### 4. **Helm** (v3.12+)
```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows via Chocolatey
choco install kubernetes-helm

# Verificar instalação
helm version
```

#### 5. **eksctl** (Opcional - para troubleshooting)
```bash
# macOS
brew install eksctl

# Linux
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verificar instalação
eksctl version
```

#### 6. **terraform-docs** (Para documentação)
```bash
# macOS
brew install terraform-docs

# Linux
GO111MODULE="on" go install github.com/terraform-docs/terraform-docs@latest

# Windows via Chocolatey
choco install terraform-docs

# Verificar instalação
terraform-docs --version
```

### Configuração AWS - EXTREMAMENTE IMPORTANTE

> ⚠️ **ATENÇÃO**: Sem esta configuração correta, NADA funcionará! Esta é a parte mais crítica do setup.

#### 1. **Criação de Usuário IAM (NÃO USE ROOT!)**

**NUNCA use a conta root da AWS para desenvolvimento!** Você precisa criar um usuário IAM dedicado:

##### **Passo 1: Criar Usuário IAM**
```bash
# 1. Acesse o AWS Console como root
# 2. Vá para IAM > Users > Create User
# 3. Nome sugerido: "terraform-admin" ou "devops-admin"
# 4. ✅ Marque: "Provide user access to the AWS Management Console"
# 5. ✅ Marque: "I want to create an IAM user" 
```

##### **Passo 2: Anexar Policy AdministratorAccess**
```bash
# No processo de criação do usuário:
# 1. Permissions > Attach policies directly
# 2. ✅ Marque: "AdministratorAccess"
# 3. ⚠️ IMPORTANTE: Esta policy é necessária para criar recursos EKS, VPC, IAM, etc.
```

#### 2. **Access Keys - OBRIGATÓRIO**

**Sem Access Keys, o Terraform não consegue se conectar à AWS!**

##### **Como Criar Access Keys:**
```bash
# 1. Usuário criado > Security credentials
# 2. Access keys > Create access key
# 3. Escolha: "Command Line Interface (CLI)"
# 4. Confirme que entende as recomendações
# 5. Baixe ou copie:
#    - Access Key ID (ex: AKIAXXXXXXXXXXXXXXXX)
#    - Secret Access Key (ex: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
```

##### **Como Configurar no Sistema:**
```bash
# Opção 1: Via AWS CLI (Recomendado)
aws configure
# AWS Access Key ID [None]: AKIAXXXXXXXXXXXXXXXX
# AWS Secret Access Key [None]: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Default region name [None]: us-east-1
# Default output format [None]: json

# Opção 2: Via Variáveis de Ambiente
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export AWS_DEFAULT_REGION="us-east-1"

# Opção 3: Via Arquivo de Credenciais
# ~/.aws/credentials
[default]
aws_access_key_id = AKIAXXXXXXXXXXXXXXXX
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 3. **Chave PEM - Para Acesso SSH (Opcional mas Recomendado)**

**Embora o EKS não requeira SSH direto, é útil ter uma chave para troubleshooting:**

##### **Criar Key Pair EC2:**
```bash
# Via AWS Console:
# 1. EC2 > Key Pairs > Create key pair
# 2. Nome: "chame-bina-key" ou "projeto-cliente-key"
# 3. Type: RSA
# 4. Format: .pem
# 5. ⚠️ IMPORTANTE: Baixe e guarde em local seguro!

# Via AWS CLI:
aws ec2 create-key-pair \
  --key-name chame-bina-key \
  --query 'KeyMaterial' \
  --output text > chame-bina-key.pem

# Definir permissões corretas:
chmod 400 chame-bina-key.pem
```

#### 4. **Verificação de Configuração - TESTE OBRIGATÓRIO**

**Execute estes comandos para garantir que tudo está funcionando:**

```bash
# 1. Testar autenticação
aws sts get-caller-identity

# Resultado esperado:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXX", 
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
# }

# 2. Testar permissões
aws iam get-user

# 3. Testar região
aws configure get region
# Deve retornar: us-east-1

# 4. Testar EC2 (para key pairs)
aws ec2 describe-key-pairs
```

#### 5. **Permissões Mínimas Necessárias (Para Referência)**

Se sua empresa não permitir `AdministratorAccess`, estas são as permissões **mínimas**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "elasticloadbalancing:*",
        "route53:*",
        "logs:*",
        "sts:GetCallerIdentity",
        "kms:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 6. **S3 Backend (Recomendado)**
```bash
# Criar bucket para Terraform state
aws s3 mb s3://seu-projeto-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket seu-projeto-terraform-state --versioning-configuration Status=Enabled
```

#### **CHECKLIST FINAL - AWS**

Antes de prosseguir, confirme que você tem:

- [ ] Usuário IAM criado (NÃO root)
- [ ] Policy `AdministratorAccess` anexada
- [ ] Access Key ID obtida
- [ ] Secret Access Key obtida  
- [ ] `aws configure` executado com sucesso
- [ ] `aws sts get-caller-identity` funcionando
- [ ] Key Pair EC2 criada (.pem baixada)
- [ ] ARN do usuário copiado para `admin_user_arn`

**Se QUALQUER item não estiver ✅, PARE e resolva antes de continuar!**

### Verificação da Instalação

Execute este script para verificar todas as dependências:

```bash
#!/bin/bash
echo "🔍 Verificando dependências..."

check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 está instalado: $($1 --version | head -1)"
    else
        echo "❌ $1 não encontrado"
        exit 1
    fi
}

check_command terraform
check_command aws
check_command kubectl
check_command helm
check_command terraform-docs

echo "🎉 Todas as dependências estão instaladas!"
echo "📋 Próximo passo: Configure o terraform.tfvars"
```

---

## Referência Completa - Terraform Docs

> Esta seção contém a documentação técnica completa gerada automaticamente pelo `terraform-docs`. Mantenha sempre atualizada executando: `terraform-docs markdown table . > wiki/terraform-reference.md`

### Requirements

| Name | Version |
|------|---------|
| aws | 6.10.0 |
| helm | 3.0.2 |
| kubernetes | 2.38.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| eks-cluster | ./modules/cluster | n/a |
| eks-network | ./modules/network | n/a |
| load_balancer | ./modules/load-balancer | n/a |
| managed_node_group | ./modules/managed-node-group | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| **cidr_block** | The CIDR block for the VPC | `string` | n/a | **YES** |
| **public_subnet_cidrs** | The CIDR blocks for the public subnets | `list(string)` | n/a | **YES** |
| **private_subnet_cidrs** | The CIDR blocks for the private subnets | `list(string)` | n/a | **YES** |
| **aws_region** | The AWS region to AWS resources | `string` | n/a | **YES** |
| **project_name** | Name of the project to be used in resources | `string` | n/a | **YES** |
| admin_user_arn | ARN of the IAM user that should have admin access to the EKS cluster | `string` | `null` | no |
| eks-cluster-endpoint | EKS cluster endpoint | `string` | `null` | no |
| oidc-identity | OIDC identity provider URL | `string` | `null` | no |

### Exemplo de Configuração Completa

```hcl
# terraform.tfvars - Configuração de Produção
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
aws_region           = "us-east-1"
project_name         = "banking-app-prod"
admin_user_arn       = "arn:aws:iam::123456789012:user/devops-admin"
```

### Estrutura de Arquivos

```
chame-bina-terraform/
├── modules.tf              # Configuração principal dos módulos
├── variables.tf             # Definições de variáveis
├── providers.tf             # Configuração dos providers
├── terraform.tfvars         # ⚠️  Seus valores (não committar)
├── terraform.tfvars.example # Template para configuração
├── modules/
│   ├── network/             # Infraestrutura de rede
│   ├── cluster/             # Cluster EKS
│   ├── managed-node-group/  # Worker nodes
│   └── load-balancer/       # AWS Load Balancer Controller
└── wiki/
    ├── ARCHITECTURE.md      # Este documento
    └── PROJECT_OBJECTIVE.md # Objetivos do projeto
```

---

## Visão Geral da Arquitetura

O **Chame Bina Infrastructure Starter** implementa uma arquitetura moderna baseada em containers utilizando Amazon EKS (Elastic Kubernetes Service) como orquestrador principal. A solução foi projetada seguindo os princípios de **Security by Design**, **High Availability** e **Cost Optimization**.

### Componentes Principais

```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "VPC 10.0.0.0/16"
            subgraph "Public Subnets"
                PUB1[Public 1A<br/>10.0.1.0/24]
                PUB2[Public 1B<br/>10.0.3.0/24]
                PUB3[Public 1C<br/>10.0.5.0/24]
            end
            
            subgraph "Private Subnets"
                PRIV1[Private 1A<br/>10.0.2.0/24]
                PRIV2[Private 1B<br/>10.0.4.0/24]
                PRIV3[Private 1C<br/>10.0.6.0/24]
            end
            
            IGW[Internet Gateway]
            NAT1[NAT Gateway 1A]
            NAT2[NAT Gateway 1B]
            NAT3[NAT Gateway 1C]
            
            subgraph "EKS Cluster"
                CP[Control Plane<br/>Managed by AWS]
                WN1[Worker Node 1A<br/>t3.micro]
                WN2[Worker Node 1B<br/>t3.micro - Optional]
                WN3[Worker Node 1C<br/>t3.micro - Optional]
            end
            
            ALB[Application<br/>Load Balancer]
        end
    end
    
    INTERNET[Internet] --> IGW
    IGW --> PUB1
    IGW --> PUB2
    IGW --> PUB3
    
    PUB1 --> NAT1
    PUB2 --> NAT2
    PUB3 --> NAT3
    
    NAT1 --> PRIV1
    NAT2 --> PRIV2
    NAT3 --> PRIV3
    
    PRIV1 --> WN1
    PRIV2 --> WN2
    PRIV3 --> WN3
    
    ALB --> WN1
    ALB --> WN2
    ALB --> WN3
```

---

## Arquitetura de Rede

### Estrutura de VPC

A infraestrutura utiliza uma **Virtual Private Cloud (VPC)** dedicada com o CIDR `10.0.0.0/16`, fornecendo **65.536 endereços IP** disponíveis para crescimento futuro.

#### Distribuição de Subnets

| Tipo | AZ | CIDR | IPs Disponíveis | Uso |
|------|----|----|-----------------|-----|
| **Public** | us-east-1a | `10.0.1.0/24` | 256 | NAT Gateway, Load Balancers |
| **Public** | us-east-1b | `10.0.3.0/24` | 256 | NAT Gateway, Load Balancers |
| **Public** | us-east-1c | `10.0.5.0/24` | 256 | NAT Gateway, Load Balancers |
| **Private** | us-east-1a | `10.0.2.0/24` | 256 | Worker Nodes, Pods |
| **Private** | us-east-1b | `10.0.4.0/24` | 256 | Worker Nodes, Pods |
| **Private** | us-east-1c | `10.0.6.0/24` | 256 | Worker Nodes, Pods |

### NAT Gateways - Alta Disponibilidade

A arquitetura implementa **3 NAT Gateways** (um por Availability Zone) garantindo:

- ✅ **Zero Single Point of Failure** para conectividade externa
- ✅ **Redundância completa** entre zonas de disponibilidade
- ✅ **Performance otimizada** com latência reduzida
- ✅ **Isolamento de falhas** por zona

#### Roteamento Inteligente

```yaml
Tabelas de Rota:
  Public Route Table:
    - 0.0.0.0/0 → Internet Gateway
    - 10.0.0.0/16 → Local
  
  Private Route Table 1A:
    - 0.0.0.0/0 → NAT Gateway 1A
    - 10.0.0.0/16 → Local
  
  Private Route Table 1B:
    - 0.0.0.0/0 → NAT Gateway 1B
    - 10.0.0.0/16 → Local
    
  Private Route Table 1C:
    - 0.0.0.0/0 → NAT Gateway 1C
    - 10.0.0.0/16 → Local
```

### Internet Gateway

- **Função**: Portal de entrada/saída para tráfego público
- **Gerenciamento**: Totalmente gerenciado pela AWS
- **Redundância**: Automática e transparente
- **Performance**: Escalabilidade ilimitada

---

## Segurança e Compliance

### Modelo de Segurança em Camadas

#### 1. **Camada de Rede (Network Layer)**

```yaml
Network ACLs:
  - Default: Allow all traffic within VPC
  - Custom: Deny all by default, allow specific rules
  
Security Groups:
  EKS Control Plane:
    - Inbound: Port 443 (HTTPS) from Worker Nodes
    - Outbound: All traffic to Worker Nodes
  
  Worker Nodes:
    - Inbound: 
      - Port 443 from Control Plane
      - Ports 1025-65535 from other Worker Nodes
      - Port 80/443 from Load Balancer
    - Outbound: All traffic
```

#### 2. **Camada de Identidade (Identity Layer)**

```yaml
IAM Roles e Policies:
  EKS Cluster Role:
    - AmazonEKSClusterPolicy
    - Custom cluster management permissions
  
  Worker Node Role:
    - AmazonEKSWorkerNodePolicy
    - AmazonEKS_CNI_Policy
    - AmazonEC2ContainerRegistryReadOnly
  
  Load Balancer Controller Role:
    - Custom IAM policy com 200+ permissions específicas
    - OIDC Web Identity Federation
    - Service Account annotations (IRSA)
```

#### 3. **Camada de Aplicação (Application Layer)**

```yaml
EKS Access Control:
  Authentication Mode: API
  Access Entries:
    - Admin User: cluster-admin permissions
    - Service Accounts: namespace-scoped permissions
  
OIDC Provider:
  - Federated identity para Service Accounts
  - Integration com AWS IAM
  - Token-based authentication
```

### Compliance e Auditoria

- ✅ **CloudTrail**: Logging completo de todas as APIs
- ✅ **VPC Flow Logs**: Análise de tráfego de rede
- ✅ **EKS Audit Logs**: Auditoria de ações no cluster
- ✅ **IAM Access Analyzer**: Análise de permissões
- ✅ **AWS Config**: Compliance de configurações

---

## Módulos da Solução

### 1. Módulo Network (`modules/network`)

**Responsabilidade**: Provisionar toda a infraestrutura de rede base

#### Recursos Provisionados (23 recursos)

| Recurso | Quantidade | Função |
|---------|------------|--------|
| VPC | 1 | Container de rede principal |
| Internet Gateway | 1 | Acesso à internet |
| Public Subnets | 3 | Recursos públicos (1 por AZ) |
| Private Subnets | 3 | Recursos privados (1 por AZ) |
| Elastic IPs | 3 | IPs fixos para NAT Gateways |
| NAT Gateways | 3 | Conectividade externa para subnets privadas |
| Route Tables | 4 | Roteamento (1 pública + 3 privadas) |
| Route Table Associations | 6 | Associação subnet-route |

#### Inputs Obrigatórios
```hcl
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
aws_region           = "us-east-1"
project_name         = "projeto-cliente"
```

#### Outputs Fornecidos
- 6 Subnet IDs (3 públicas + 3 privadas)
- VPC ID para referência por outros módulos

---

### 2. Módulo Cluster (`modules/cluster`)

**Responsabilidade**: Provisionar e configurar o cluster EKS

#### Recursos Provisionados (7 recursos)

| Recurso | Função |
|---------|--------|
| `aws_eks_cluster` | Cluster Kubernetes gerenciado |
| `aws_iam_role` | Role de serviço para o cluster |
| `aws_iam_policy_attachment` | Anexar políticas ao role |
| `aws_iam_openid_connect_provider` | Provider OIDC para IRSA |
| `aws_eks_access_entry` | Controle de acesso ao cluster |
| `aws_eks_access_policy_association` | Associação de políticas de acesso |
| `aws_security_group_rule` | Regras de segurança customizadas |

#### Configuração de Segurança

```yaml
EKS Cluster Configuration:
  Version: 1.33 (Latest)
  Endpoint Access:
    Public: Yes (restrito por CIDR)
    Private: Yes
  Authentication Mode: API
  Encryption:
    Secrets: Enabled (AWS KMS)
    EBS: Enabled
  Logging:
    - api
    - audit
    - authenticator
    - controllerManager
    - scheduler
```

#### Data Sources Utilizados
- `tls_certificate.cluster_eks`: Certificados TLS do cluster

---

### 3. Módulo Managed Node Group (`modules/managed-node-group`)

**Responsabilidade**: Provisionar worker nodes para o cluster

#### Recursos Provisionados (5 recursos)

| Recurso | Função |
|---------|--------|
| `aws_eks_node_group` | Grupo de nós gerenciado |
| `aws_iam_role` | Role para os worker nodes |
| `aws_iam_policy_attachment` (3x) | Políticas AWS obrigatórias |

#### Configuração dos Nodes

```yaml
Node Group Specifications:
  Instance Type: t3.micro (Free Tier Compatible)
  AMI Type: AL2023_x86_64_STANDARD
  Capacity Type: ON_DEMAND
  
  Scaling Configuration:
    Desired: 1
    Maximum: 3
    Minimum: 1
  
  Networking:
    Subnets: Private only (security best practice)
    Remote Access: Disabled (managed via EKS)
```

#### IAM Policies Anexadas
- `AmazonEKSWorkerNodePolicy`: Política base para worker nodes
- `AmazonEKS_CNI_Policy`: Networking (CNI) permissions
- `AmazonEC2ContainerRegistryReadOnly`: Pull de imagens do ECR

---

### 4. Módulo Load Balancer (`modules/load-balancer`)

**Responsabilidade**: Provisionar AWS Load Balancer Controller

#### Recursos Provisionados (5 recursos + 4 data sources)

| Recurso | Função |
|---------|--------|
| `aws_iam_role` | Role com web identity federation |
| `aws_iam_policy` | 200+ permissions para ELB management |
| `aws_iam_policy_attachment` | Anexar policy ao role |
| `kubernetes_service_account` | Service account com anotações IAM |
| `helm_release` | Deploy do controller via Helm |

#### Configuração Dinâmica

```yaml
Dynamic Configuration:
  VPC ID: Detectado automaticamente via EKS cluster
  OIDC Provider: Configurado via cluster output
  Service Account: Anotado com IAM role ARN
  
Helm Configuration:
  Chart: aws-load-balancer-controller v1.13.4
  Repository: https://aws.github.io/eks-charts
  Namespace: kube-system
  Replica Count: 1 (otimizado para t3.micro)
```

#### Data Sources para Auto-descoberta
- `aws_eks_cluster`: Informações do cluster
- `aws_vpc`: VPC ID dinâmico
- `aws_caller_identity`: Account ID
- `aws_region`: Região atual

---

##  Fluxo de Dados

### Tráfego de Entrada (Ingress)

```mermaid
sequenceDiagram
    participant User as Usuario
    participant ALB as Application Load Balancer
    participant K8s as Kubernetes Service
    participant Pod as Application Pod
    
    User->>ALB: HTTPS Request
    ALB->>K8s: Forward to Service
    K8s->>Pod: Route to healthy Pod
    Pod->>K8s: Response
    K8s->>ALB: Response
    ALB->>User: HTTPS Response
```

### Tráfego de Saída (Egress)

```mermaid
sequenceDiagram
    participant Pod as Application Pod
    participant Node as Worker Node
    participant NAT as NAT Gateway
    participant IGW as Internet Gateway
    participant Ext as External Service
    
    Pod->>Node: Outbound request
    Node->>NAT: Via private route table
    NAT->>IGW: Via public route table
    IGW->>Ext: To external service
    Ext->>IGW: Response
    IGW->>NAT: Response
    NAT->>Node: Response
    Node->>Pod: Response
```

### Comunicação Interna

```yaml
Pod-to-Pod Communication:
  - Within Node: Direct communication via CNI
  - Cross-Node: Via VPC networking (10.0.0.0/16)
  - Cross-AZ: Automatic routing via AWS backbone

Service Discovery:
  - CoreDNS: Resolução de nomes internos
  - Kubernetes Services: Load balancing interno
  - AWS Cloud Map: Service mesh (futuro)
```

---

## Recursos Adicionais

### Documentação de Referência
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Ferramentas de Desenvolvimento
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [helm](https://helm.sh/) - Package manager for Kubernetes  
- [terraform](https://www.terraform.io/) - Infrastructure as Code
- [aws-cli](https://aws.amazon.com/cli/) - AWS Command Line Interface

### Comunidade e Suporte
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [CNCF Landscape](https://landscape.cncf.io/)
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [AWS re:Invent Sessions](https://reinvent.awsevents.com/)