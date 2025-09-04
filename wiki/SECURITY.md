# Guia de Segurança

## Informações Sensíveis - NUNCA COMMITAR

Este projeto está configurado para **NUNCA** commitar informações sensíveis. Os seguintes tipos de dados são automaticamente ignorados:

### Arquivos Automaticamente Ignorados
- `*.tfvars` - Configurações com dados sensíveis
- `*.tfvars.json` - Configurações JSON
- `.env` e `.env.*` - Variáveis de ambiente
- `*token*` - Qualquer arquivo com "token" no nome
- `*secret*` - Qualquer arquivo com "secret" no nome
- `*password*` - Qualquer arquivo com "password" no nome

### Tokens e Credenciais Protegidas
- **Azure DevOps PAT** - Personal Access Tokens
- **AWS Access Keys** - Chaves de acesso AWS
- **SSH Keys** - Chaves privadas
- **Certificados** - Arquivos .pem, .key, .crt

## Configuração Segura

### 1. Configure Variáveis de Ambiente
```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite com seus valores REAIS (nunca será commitado)
nano .env

# Carregue as variáveis
source .env
```

### 2. Configure Terraform Variables
```bash
# Para QA
cp environments/qa/terraform.tfvars.example environments/qa/terraform.tfvars
# Edite com valores reais

# Para Produção  
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
# Edite com valores reais
```

### 3. Validar Configuração
```bash
# Verificar se arquivos sensíveis estão ignorados
git status

# Os seguintes arquivos NÃO devem aparecer:
# - .env
# - environments/*/terraform.tfvars
# - Qualquer arquivo com *token*, *secret*, *password*
```

## ⚠️ Em Caso de Exposição Acidental

Se você acidentalmente commitou informações sensíveis:

### 1. **Revogar Imediatamente**
- AWS: Desabilitar/deletar access keys
- Azure DevOps: Revogar Personal Access Token

### 2. **Limpar Histórico Git**
```bash
# Para remover do histórico (CUIDADO!)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch ARQUIVO_SENSIVEL' \
  --prune-empty --tag-name-filter cat -- --all

# Forçar push (irá reescrever histórico)
git push --force --all
```

### 3. **Recriar Credenciais**
- Gere novas credenciais
- Atualize todos os sistemas que usam as antigas
- Configure alertas de segurança
