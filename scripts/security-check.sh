#!/bin/bash

echo "Verificação de Segurança - Chame Bina Terraform"
echo "=================================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

echo "Verificando configuração de segurança..."
echo ""

# 1. Verificar se .gitignore existe e tem as proteções necessárias
echo "1. Verificando .gitignore..."
if [ -f ".gitignore" ]; then
    echo -e "   ${GREEN}OK .gitignore encontrado${NC}"
    
    # Verificar se há proteções para arquivos sensíveis
    PROTECTED_PATTERNS=("*.tfvars" "*.env" "*token*" "*secret*" "*password*")
    for pattern in "${PROTECTED_PATTERNS[@]}"; do
        if grep -q "$pattern" .gitignore; then
            echo -e "   ${GREEN}OK Protegido: $pattern${NC}"
        else
            echo -e "   ${RED}❌ Faltando proteção: $pattern${NC}"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done
else
    echo -e "   ${RED}❌ .gitignore não encontrado${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 2. Verificar se há arquivos sensíveis commitados
echo "2. Verificando arquivos sensíveis no repositório..."
SENSITIVE_FILES=$(git ls-files | grep -E "(\.tfvars$|\.env$|token|secret|password)" | grep -v "\.example$" | grep -v "\.md$")
if [ -z "$SENSITIVE_FILES" ]; then
    echo -e "   ${GREEN}OK Nenhum arquivo sensível encontrado no repositório${NC}"
else
    echo -e "   ${RED}❌ Arquivos sensíveis encontrados:${NC}"
    echo "$SENSITIVE_FILES" | while read file; do
        echo -e "   ${RED}   - $file${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    done
fi
echo ""

# 3. Verificar se arquivos de exemplo existem
echo "3. Verificando arquivos de exemplo..."
EXAMPLE_FILES=(".env.example" "environments/qa/terraform.tfvars.example" "environments/prod/terraform.tfvars.example")
for file in "${EXAMPLE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}OK $file existe${NC}"
    else
        echo -e "   ${YELLOW}AVISO $file não encontrado${NC}"
    fi
done
echo ""

# 4. Verificar variáveis de ambiente
echo "4. Verificando variáveis de ambiente..."
if [ -n "$AZDO_PERSONAL_ACCESS_TOKEN" ]; then
    echo -e "   ${GREEN}OK AZDO_PERSONAL_ACCESS_TOKEN definido${NC}"
    # Mascarar o token para não mostrar
    TOKEN_MASKED="${AZDO_PERSONAL_ACCESS_TOKEN:0:8}***${AZDO_PERSONAL_ACCESS_TOKEN: -4}"
    echo -e "   ${GREEN}   Token (mascarado): $TOKEN_MASKED${NC}"
else
    echo -e "   ${YELLOW}AVISO AZDO_PERSONAL_ACCESS_TOKEN não definido${NC}"
    echo -e "   ${YELLOW}   Configure com: export AZDO_PERSONAL_ACCESS_TOKEN='your-token'${NC}"
fi

if [ -n "$TF_VAR_azdo_personal_access_token" ]; then
    echo -e "   ${GREEN}OK TF_VAR_azdo_personal_access_token definido${NC}"
else
    echo -e "   ${YELLOW}AVISO TF_VAR_azdo_personal_access_token não definido${NC}"
    echo -e "   ${YELLOW}   Configure com: export TF_VAR_azdo_personal_access_token='your-token'${NC}"
fi
echo ""

# 5. Verificar se há mudanças staged que podem ser sensíveis
echo "5. Verificando mudanças staged..."
STAGED_SENSITIVE=$(git diff --cached --name-only | grep -E "(\.tfvars$|\.env$|token|secret|password)" | grep -v "\.example$" | grep -v "\.md$")
if [ -z "$STAGED_SENSITIVE" ]; then
    echo -e "   ${GREEN}OK Nenhum arquivo sensível staged para commit${NC}"
else
    echo -e "   ${RED}❌ ATENÇÃO: Arquivos sensíveis staged:${NC}"
    echo "$STAGED_SENSITIVE" | while read file; do
        echo -e "   ${RED}   - $file${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    done
fi
echo ""

# 6. Verificar permissões de arquivos sensíveis existentes
echo "6. Verificando permissões de arquivos locais..."
LOCAL_SENSITIVE_FILES=(".env" "environments/qa/terraform.tfvars" "environments/prod/terraform.tfvars")
for file in "${LOCAL_SENSITIVE_FILES[@]}"; do
    if [ -f "$file" ]; then
        PERMS=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
        if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
            echo -e "   ${GREEN}OK $file tem permissões seguras ($PERMS)${NC}"
        else
            echo -e "   ${YELLOW}AVISO $file tem permissões: $PERMS (recomendado: 600)${NC}"
            echo -e "   ${YELLOW}   Execute: chmod 600 $file${NC}"
        fi
    fi
done
echo ""

# Resumo final
echo "=================================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}CONFIGURAÇÃO DE SEGURANÇA OK!${NC}"
    echo -e "${GREEN}Nenhum problema crítico encontrado.${NC}"
    exit 0
else
    echo -e "${RED}❌ PROBLEMAS DE SEGURANÇA ENCONTRADOS: $ISSUES_FOUND${NC}"
    echo -e "${RED}Revise os itens marcados acima antes de continuar.${NC}"
    exit 1
fi