# AWS OIDC Integration com Azure DevOps

Esta configuração permite que pipelines do Azure DevOps acessem AWS sem usar chaves de acesso, utilizando OIDC (OpenID Connect). **Implementação 100% automatizada via Terraform.**

## Pré-requisitos

1. **Extensão AWS Toolkit**: Instale a extensão "AWS Toolkit for Azure DevOps" na sua organização Azure DevOps
2. **Personal Access Token**: Crie um PAT no Azure DevOps com permissões para Service Connections

## 🚀 Configuração Automatizada

### 1. Usar com deploy.sh (Recomendado)

O deploy script já configura automaticamente o OIDC quando as variáveis estão definidas:

```bash
# Configure as variáveis de ambiente
export AZDO_PERSONAL_ACCESS_TOKEN="seu-token-aqui"

# Deploy com OIDC automático
./deploy.sh ecs qa apply
```

### 2. Configuração Manual

#### 2.1. Variáveis necessárias

Adicione ao seu `environments/qa/terraform.tfvars`:

```hcl
# Azure DevOps Configuration
azure_devops_organization = "premiersoftbr"
azure_devops_project      = "SoftwareStudio"
```

#### 2.2. Aplicar OIDC Provider + Service Connection

```bash
# Definir PAT
export AZDO_PERSONAL_ACCESS_TOKEN="seu-token-aqui"

# Aplicar tudo automaticamente
terraform apply -var-file=environments/qa/terraform.tfvars \
  -var="azdo_personal_access_token=$AZDO_PERSONAL_ACCESS_TOKEN" \
  -auto-approve
```

## Uso no Pipeline

### Pipeline YAML exemplo:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  AWS_REGION: 'us-east-1'

stages:
- stage: Deploy
  jobs:
  - job: TerraformDeploy
    steps:
    - task: TerraformInstaller@0
      displayName: 'Install Terraform'
      inputs:
        terraformVersion: 'latest'
    
    - task: AWSShellScript@1
      displayName: 'AWS CLI Commands'
      inputs:
        awsCredentials: 'chame-bina-aws-connection'  # Nome da Service Connection
        regionName: '$(AWS_REGION)'
        scriptType: 'inline'
        inlineScript: |
          # Comandos AWS CLI aqui
          aws sts get-caller-identity
          
    - task: TerraformTaskV4@4
      displayName: 'Terraform Apply'
      inputs:
        provider: 'aws'
        command: 'apply'
        workingDirectory: '$(System.DefaultWorkingDirectory)'
        environmentServiceNameAWS: 'chame-bina-aws-connection'
        commandOptions: '-auto-approve'
```

## Recursos Criados Automaticamente

### AWS:
- **OIDC Identity Provider**: `https://vstoken.dev.azure.com/premiersoftbr`
- **IAM Role**: `chame-bina-azure-devops-role`
- **IAM Policy**: Permissões completas para Terraform (EC2, ECS, ECR, EKS, RDS, Lambda, IAM limitado, etc.)

### Azure DevOps:
- **Service Connection**: `aws-chame-bina` (criada e configurada automaticamente)
- **OIDC Authentication**: Configurado via API REST automaticamente

## Troubleshooting

### Erro de Subject Mismatch:
Verifique se o nome da Service Connection corresponde ao esperado na condition da Role:
```
"sc://{organization}/{project}/{project-name}-aws-connection"
```

### Erro de Thumbprint:
Se houver erro de certificado, atualize os thumbprints no OIDC Provider com os valores mais recentes da DigiCert.

### Permissões Insuficientes:
Ajuste a policy `terraform_policy` no módulo `aws-oidc-provider` conforme necessário para suas operações específicas.