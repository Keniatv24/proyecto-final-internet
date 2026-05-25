#!/bin/bash

# 🚀 Script de Deploy Rápido a AWS
# Uso: ./quick-deploy.sh [HOST] [USER] [KEY_PATH]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
AWS_HOST=${1:-"54.123.45.67"}  # Cambiar por IP real
AWS_USER=${2:-"ubuntu"}
SSH_KEY=${3:-"~/.ssh/proyecto-aws.pem"}

# Variables derivadas
SSH_KEY="${SSH_KEY/#\~/$HOME}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 DEPLOY RÁPIDO A AWS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Verificar que existe la clave SSH
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}❌ Error: No se encontró clave SSH en: $SSH_KEY${NC}"
    echo -e "${YELLOW}Uso: ./quick-deploy.sh [HOST] [USER] [KEY_PATH]${NC}"
    echo -e "${YELLOW}Ejemplo: ./quick-deploy.sh 54.123.45.67 ubuntu ~/.ssh/proyecto-aws.pem${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuración:${NC}"
echo "   Host: $AWS_HOST"
echo "   User: $AWS_USER"
echo "   SSH Key: $SSH_KEY"
echo ""

# Verificar que git está actualizado
echo -e "${BLUE}📥 Verificando cambios locales...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Hay cambios sin commit${NC}"
    echo "   Ejecuta primero:"
    echo "   git add ."
    echo "   git commit -m 'Tu mensaje'"
    echo "   git push"
    exit 1
fi

echo -e "${GREEN}✅ Todo en orden${NC}"
echo ""

# Deploy
echo -e "${BLUE}🔌 Conectando a AWS...${NC}"

ssh -i "$SSH_KEY" -o ConnectTimeout=10 "$AWS_USER@$AWS_HOST" << 'REMOTE_EOF'
    set -e
    
    echo -e "\033[0;34m📂 Entrando al proyecto...\033[0m"
    cd ~/proyecto-final-internet || {
        echo -e "\033[0;31m❌ Directorio no encontrado\033[0m"
        exit 1
    }
    
    echo -e "\033[0;34m📥 Descargando cambios...\033[0m"
    git fetch origin main || {
        echo -e "\033[0;31m❌ Error al hacer fetch\033[0m"
        exit 1
    }
    
    git reset --hard origin/main || {
        echo -e "\033[0;31m❌ Error al actualizar rama\033[0m"
        exit 1
    }
    
    echo -e "\033[0;32m✅ Cambios descargados\033[0m"
    echo ""
    
    echo -e "\033[0;34m🐳 Reiniciando contenedores...\033[0m"
    docker-compose restart web-app-es web-app-en || docker-compose restart
    
    echo ""
    echo -e "\033[0;32m✅ Contenedores reiniciados\033[0m"
    echo ""
    
    echo -e "\033[0;34m📊 Estado actual:\033[0m"
    docker-compose ps
    
    echo ""
    echo -e "\033[0;32m✅ Deploy completado\033[0m"
    echo -e "\033[0;34m📌 Accesible en: https://proyectotelematica-kenia.duckdns.org\033[0m"

REMOTE_EOF

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 ¡Deploy completado exitosamente!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Verificación
echo ""
echo -e "${BLUE}🔍 Verificando acceso...${NC}"
sleep 2

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://proyectotelematica-kenia.duckdns.org/health" 2>/dev/null || echo "000")

if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Servidor responde correctamente${NC}"
else
    echo -e "${YELLOW}⚠️  No se obtuvo respuesta (código: $RESPONSE)${NC}"
    echo -e "${YELLOW}   Verifica manualmente en: https://proyectotelematica-kenia.duckdns.org${NC}"
fi

exit 0
