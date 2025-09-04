# Configurar Personal Access Token (PAT) do Azure DevOps

## 1. Criar PAT no Azure DevOps

### Acessar configurações:
```
https://dev.azure.com/premiersoftbr/_usersSettings/tokens
```

### Criar novo token:
1. Clique em **"New Token"**
2. **Name:** `Terraform Service Connections`
3. **Organization:** `premiersoftbr`
4. **Expiration:** `Custom defined` (recomendado: 90 dias)
5. **Scopes:** Selecione **"Custom defined"**

### Permissões necessárias:
- **Service Connections:** `Read, query, & manage`
- **Project and Team:** `Read` 

### Salvar token:
1. Clique em **"Create"**
2. **IMPORTANTE:** Copie o token imediatamente (não será mostrado novamente)
3. Salve em local seguro

## 2. Configurar Token no Terraform

### Opção 1: Variável de Ambiente (Recomendado)
```bash
export AZDO_PERSONAL_ACCESS_TOKEN="seu-token-aqui"
export TF_VAR_azdo_personal_access_token="seu-token-aqui"
```

### Opção 2: Arquivo .env (Local)
Crie arquivo `.env`:
```bash
AZDO_PERSONAL_ACCESS_TOKEN=seu-token-aqui
TF_VAR_azdo_personal_access_token=seu-token-aqui
```

Execute:
```bash
source .env
```

### Opção 3: Terraform tfvars (Menos seguro)
Adicione ao `environments/qa/terraform.tfvars`:
```hcl
azdo_personal_access_token = "seu-token-aqui"
```

## 3. Aplicar Service Connection

```bash
# Inicializar com novo provider
terraform init

# Verificar se detecta a configuração
terraform plan -var-file=environments/qa/terraform.tfvars

# Aplicar apenas o módulo da service connection
terraform apply -target=module.azure_devops_connection -var-file=environments/qa/terraform.tfvars -auto-approve
```

## 4. Verificar Resultado

### No Azure DevOps:
```
https://dev.azure.com/premiersoftbr/SoftwareStudio/_settings/adminservices
```

Deve aparecer uma nova service connection chamada `aws-chame-bina`.

### Terraform Output:
```bash
terraform output azure_devops_oidc_info
```

## 5. Testar Service Connection

Use o pipeline de teste `test-oidc-connection.yml` para validar se a conexão está funcionando.

## ⚠️ Segurança

- **Nunca commite o PAT no Git**
- Use variáveis de ambiente sempre que possível
- Configure expiration adequada do token
- Revogue tokens não utilizados regularmente
- Use princípio do menor privilégio nas permissões

## 🔧 Troubleshooting

### Erro: "Unauthorized"
- Verificar se o PAT tem as permissões corretas
- Confirmar se o token não expirou

### Erro: "Project not found"
- Verificar se o nome da organização está correto
- Confirmar se o nome do projeto está correto
- Verificar se o token tem acesso ao projeto

### Erro: "Provider configuration"
- Executar `terraform init` novamente após adicionar o provider
- Verificar se a variável de ambiente está definida corretamente