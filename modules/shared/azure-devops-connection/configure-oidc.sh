#!/bin/bash
set -e

echo "=== Configurando OIDC via Azure DevOps REST API ==="

# Verificar variáveis necessárias
if [ -z "$SERVICE_ENDPOINT_ID" ] || [ -z "$PROJECT_ID" ] || [ -z "$AZDO_PAT" ] || [ -z "$ORGANIZATION" ] || [ -z "$PROJECT_NAME" ] || [ -z "$ROLE_ARN" ]; then
    echo "❌ Variáveis necessárias não definidas:"
    echo "   SERVICE_ENDPOINT_ID, PROJECT_ID, AZDO_PAT, ORGANIZATION, PROJECT_NAME, ROLE_ARN"
    exit 1
fi

echo "Configuração:"
echo "   Organization: $ORGANIZATION"  
echo "   Project: $PROJECT_NAME"
echo "   Service Connection ID: $SERVICE_ENDPOINT_ID"
echo "   Role ARN: $ROLE_ARN"
echo ""

# Base64 encode do PAT para autenticação básica
AUTH_HEADER=$(echo -n ":$AZDO_PAT" | base64)

# URL da API
API_URL="https://dev.azure.com/$ORGANIZATION/$PROJECT_NAME/_apis/serviceendpoint/endpoints/$SERVICE_ENDPOINT_ID?api-version=7.1-preview.4"

echo "Buscando configuração atual..."

# Buscar a configuração atual da service connection
CURRENT_CONFIG=$(curl -s -H "Authorization: Basic $AUTH_HEADER" "$API_URL")

if [ $? -ne 0 ]; then
    echo "❌ Erro ao buscar configuração atual"
    exit 1
fi

# Extrair dados necessários
NAME=$(echo "$CURRENT_CONFIG" | jq -r '.name // "aws-chame-bina"')
DESCRIPTION=$(echo "$CURRENT_CONFIG" | jq -r '.description // "AWS OIDC connection"')

echo "✅ Configuração atual obtida"
echo ""

# Criar payload JSON para atualização OIDC
cat > /tmp/oidc-update.json << EOF
{
  "data": {
    "environment": "AzureCloud",
    "scopeLevel": "Subscription", 
    "creationMode": "Manual",
    "authenticationScheme": "WorkloadIdentityFederation",
    "workloadIdentityFederationIssuer": "https://vstoken.dev.azure.com/$ORGANIZATION",
    "workloadIdentityFederationSubject": "sc://$ORGANIZATION/$PROJECT_NAME/aws-chame-bina",
    "region": "us-east-1"
  },
  "name": "$NAME",
  "type": "AWS", 
  "url": "https://aws.amazon.com/",
  "description": "$DESCRIPTION - configured with OIDC",
  "authorization": {
    "scheme": "WorkloadIdentityFederation",
    "parameters": {
      "region": "us-east-1",
      "RoleArn": "$ROLE_ARN",
      "RoleSessionName": "chame-bina-session"
    }
  },
  "isShared": false,
  "isReady": true,
  "owner": "Library"
}
EOF

echo "Aplicando configuração OIDC..."

# Aplicar configuração OIDC
RESPONSE=$(curl -s -X PUT \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $AUTH_HEADER" \
  -d @/tmp/oidc-update.json \
  "$API_URL")

if [ $? -eq 0 ]; then
    echo "✅ Configuração OIDC aplicada com sucesso!"
    echo ""
    echo "Service Connection configurada:"
    echo "   Nome: $NAME"
    echo "   Tipo: AWS (OIDC)"
    echo "   Role ARN: $ROLE_ARN"
    echo "   OIDC Issuer: https://vstoken.dev.azure.com/$ORGANIZATION"
    echo ""
    echo "🧪 Agora você pode testar com o pipeline test-oidc-connection.yml"
else
    echo "❌ Erro ao aplicar configuração OIDC:"
    echo "$RESPONSE"
    exit 1
fi

# Cleanup
rm -f /tmp/oidc-update.json

echo ""
echo "✅ Configuração OIDC concluída com sucesso!"