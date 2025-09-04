#!/bin/bash

# ===================================================================
# CHAME BINA INFRASTRUCTURE STARTER - VERIFICADOR DE DEPENDÊNCIAS
# ===================================================================
# Este script verifica se todas as ferramentas necessárias estão instaladas
# e configuradas corretamente antes do deploy da infraestrutura.
# ===================================================================

set -e  # Exit on any error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para printar com cores
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

print_header() {
    echo ""
    echo "======================================="
    echo "$1"
    echo "======================================="
}

# Função para verificar se um comando existe
check_command() {
    local cmd=$1
    local min_version=$2
    local install_url=$3
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
        if [[ -n "$version" ]]; then
            print_status "$cmd está instalado: v$version"
        else
            print_status "$cmd está instalado"
        fi
        return 0
    else
        print_error "$cmd não encontrado"
        if [[ -n "$install_url" ]]; then
            print_info "Instale em: $install_url"
        fi
        return 1
    fi
}

# Função para verificar arquivo
check_file() {
    local file=$1
    local description=$2
    
    if [[ -f "$file" ]]; then
        print_status "$description encontrado: $file"
        return 0
    else
        print_error "$description não encontrado: $file"
        return 1
    fi
}

print_header "🔍 VERIFICADOR DE DEPENDÊNCIAS - CHAME BINA STARTER"

echo "Verificando ferramentas obrigatórias..."

# Contador de erros
errors=0

# Verificar ferramentas principais
echo ""
print_header "🛠️ FERRAMENTAS PRINCIPAIS"

check_command "terraform" "1.5.0" "https://www.terraform.io/downloads" || ((errors++))
check_command "aws" "2.0.0" "https://aws.amazon.com/cli/" || ((errors++))
check_command "kubectl" "1.28.0" "https://kubernetes.io/docs/tasks/tools/" || ((errors++))
check_command "helm" "3.12.0" "https://helm.sh/docs/intro/install/" || ((errors++))

echo ""
print_header "🔧 FERRAMENTAS OPCIONAIS"

check_command "eksctl" "" "https://eksctl.io/installation/" || print_warning "eksctl é opcional mas recomendado para troubleshooting"
check_command "terraform-docs" "" "https://github.com/terraform-docs/terraform-docs" || print_warning "terraform-docs é opcional mas útil para documentação"

# Verificar configuração AWS - CRÍTICO
echo ""
print_header "☁️ CONFIGURAÇÃO AWS - CRÍTICO"

if aws sts get-caller-identity &> /dev/null; then
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    local user_arn=$(aws sts get-caller-identity --query Arn --output text)
    local user_name=$(echo "$user_arn" | cut -d'/' -f2)
    
    print_status "AWS CLI configurado corretamente"
    print_info "Account ID: $account_id"
    print_info "User ARN: $user_arn"
    
    # Verificar se não é root user
    if [[ "$user_arn" == *":root" ]]; then
        print_error "DETECTADO USO DE CONTA ROOT!"
        print_error "NUNCA use a conta root para desenvolvimento!"
        print_info "Crie um usuário IAM com AdministratorAccess"
        ((errors++))
    else
        print_status "Usuário IAM detectado (não é root) ✅"
    fi
    
    # Verificar permissões básicas
    print_info "Testando permissões básicas..."
    
    if aws iam get-user &> /dev/null; then
        print_status "Permissões IAM: OK"
    else
        print_warning "Não foi possível verificar permissões IAM"
    fi
    
    if aws ec2 describe-regions --region us-east-1 &> /dev/null; then
        print_status "Permissões EC2: OK"
    else
        print_warning "Não foi possível verificar permissões EC2"
    fi
    
    if aws eks list-clusters --region us-east-1 &> /dev/null; then
        print_status "Permissões EKS: OK"
    else
        print_warning "Não foi possível verificar permissões EKS"
    fi
    
    # Verificar Key Pairs
    if aws ec2 describe-key-pairs &> /dev/null; then
        local key_count=$(aws ec2 describe-key-pairs --query 'length(KeyPairs)' --output text)
        if [[ "$key_count" -gt 0 ]]; then
            print_status "Key Pairs EC2 encontradas: $key_count"
        else
            print_warning "Nenhuma Key Pair EC2 encontrada - considere criar uma"
            print_info "aws ec2 create-key-pair --key-name chame-bina-key"
        fi
    else
        print_warning "Não foi possível verificar Key Pairs EC2"
    fi
    
else
    print_error "AWS CLI não configurado ou sem credenciais válidas"
    print_error "🚨 SETUP OBRIGATÓRIO:"
    print_info "1. Crie usuário IAM (NÃO use root!)"
    print_info "2. Anexe policy AdministratorAccess"
    print_info "3. Crie Access Keys"
    print_info "4. Execute: aws configure"
    print_info "5. Teste: aws sts get-caller-identity"
    ((errors++))
fi

# Verificar se admin_user_arn está configurado no terraform.tfvars
if [[ -f "terraform.tfvars" ]]; then
    if grep -q "admin_user_arn.*=.*arn:aws:iam::" terraform.tfvars; then
        local configured_arn=$(grep "admin_user_arn" terraform.tfvars | cut -d'"' -f2)
        if [[ "$configured_arn" == *"YOUR-ACCOUNT-ID"* ]] || [[ "$configured_arn" == *"123456789012"* ]]; then
            print_error "admin_user_arn ainda contém valor de exemplo!"
            print_info "Configure com seu ARN real: $user_arn"
            ((errors++))
        else
            print_status "admin_user_arn configurado no terraform.tfvars"
        fi
    else
        print_warning "admin_user_arn não encontrado no terraform.tfvars"
        print_info "Adicione: admin_user_arn = \"$user_arn\""
    fi
fi

# Verificar arquivos de configuração
echo ""
print_header "📁 ARQUIVOS DE CONFIGURAÇÃO"

if check_file "terraform.tfvars" "Arquivo de configuração principal"; then
    print_info "Verifique se todos os valores estão preenchidos corretamente"
else
    if check_file "terraform.tfvars.example" "Template de configuração"; then
        print_warning "Copie terraform.tfvars.example para terraform.tfvars"
        print_info "Comando: cp terraform.tfvars.example terraform.tfvars"
    else
        ((errors++))
    fi
fi

check_file ".gitignore" "Arquivo .gitignore" || print_warning ".gitignore não encontrado - crie para proteger arquivos sensíveis"

# Verificar estrutura do projeto
echo ""
print_header "🏗️ ESTRUTURA DO PROJETO"

local required_dirs=("modules/network" "modules/cluster" "modules/managed-node-group" "modules/load-balancer")

for dir in "${required_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        print_status "Diretório encontrado: $dir"
    else
        print_error "Diretório não encontrado: $dir"
        ((errors++))
    fi
done

# Verificar providers
echo ""
print_header "🔌 PROVIDERS TERRAFORM"

if terraform version &> /dev/null; then
    print_info "Executando terraform init para verificar providers..."
    if terraform init -backend=false &> /dev/null; then
        print_status "Providers Terraform inicializados com sucesso"
    else
        print_warning "Erro ao inicializar providers - execute 'terraform init' manualmente"
    fi
fi

# Resumo final
echo ""
print_header "📊 RESUMO DA VERIFICAÇÃO"

if [[ $errors -eq 0 ]]; then
    print_status "Todas as dependências estão configuradas corretamente!"
    echo ""
    print_info "Próximos passos:"
    print_info "1. Verifique o arquivo terraform.tfvars"
    print_info "2. Execute: terraform plan"
    print_info "3. Execute: terraform apply"
    echo ""
    print_status "🚀 Você está pronto para deploy!"
else
    print_error "Encontrados $errors erro(s) que precisam ser corrigidos"
    echo ""
    print_info "Corrija os erros acima e execute este script novamente"
    exit 1
fi

echo ""
print_header "🎯 INFORMAÇÕES ÚTEIS"
print_info "Documentação: README.md e wiki/ARCHITECTURE.md"
print_info "Suporte: https://github.com/seu-usuario/chame-bina-terraform"
print_info "Versão do script: 1.0"
echo ""