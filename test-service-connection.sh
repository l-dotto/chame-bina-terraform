#!/bin/bash

echo "=== Teste: Criar Service Connection via Terraform ==="
echo ""

# Verificar se PAT está configurado
if [ -z "$AZDO_PERSONAL_ACCESS_TOKEN" ]; then
    echo "❌ ERRO: AZDO_PERSONAL_ACCESS_TOKEN não está configurado"
    echo ""
    echo "Para configurar:"
    echo "1. Acesse: https://dev.azure.com/premiersoftbr/_usersSettings/tokens"
    echo "2. Crie um novo token com permissões: Service Connections (Read, query, & manage)"
    echo "3. Execute: export AZDO_PERSONAL_ACCESS_TOKEN='seu-token'"
    echo "4. Execute: export TF_VAR_azdo_personal_access_token='seu-token'"
    echo ""
    exit 1
fi

echo "✅ PAT configurado"
echo ""

# Verificar se variável Terraform está configurada
if [ -z "$TF_VAR_azdo_personal_access_token" ]; then
    echo "⚠️  Configurando TF_VAR_azdo_personal_access_token automaticamente"
    export TF_VAR_azdo_personal_access_token="$AZDO_PERSONAL_ACCESS_TOKEN"
fi

echo "✅ Variáveis Terraform configuradas"
echo ""

echo "🔍 Verificando configuração atual:"
echo "Organization: premiersoftbr"
echo "Project: SoftwareStudio"
echo "Service Connection: aws-chame-bina"
echo ""

echo "📋 Executando terraform plan..."
terraform plan -target=module.azure_devops_connection -var-file=environments/qa/terraform.tfvars

echo ""
read -p "🚀 Aplicar as mudanças? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo ""
    echo "🚀 Aplicando service connection..."
    terraform apply -target=module.azure_devops_connection -var-file=environments/qa/terraform.tfvars -auto-approve
    
    echo ""
    echo "✅ Service Connection criada!"
    echo ""
    echo "📋 Para configurar OIDC manualmente:"
    echo "1. Acesse: https://dev.azure.com/premiersoftbr/SoftwareStudio/_settings/adminservices"
    echo "2. Encontre a conexão 'aws-chame-bina'"
    echo "3. Edite e configure:"
    echo "   - Authentication Method: OpenID Connect (OIDC)"
    echo "   - AWS Role to Assume: arn:aws:iam::358884521745:role/chame-bina-azure-devops-role"
    echo "   - Role session name: chame-bina-session"
    echo ""
    echo "🧪 Teste a conexão com: test-oidc-connection.yml"
    
else
    echo ""
    echo "❌ Operação cancelada pelo usuário"
fi