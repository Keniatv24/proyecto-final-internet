#!/bin/bash

# 🔄 UPDATE - Actualizar la Interfaz en Servidor Remoto
# 
# Script ligero para actualizar solo los cambios (sin re-deploy completo)
# Ideal para cambios rápidos en HTML/CSS/JS
#
# Uso: ./update.sh [host] [user]

set -e

echo "🔄 UPDATE - Actualizar Interfaz Remota"
echo "======================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REMOTE_HOST=${1:-""}
REMOTE_USER=${2:-"ubuntu"}

# Si no hay host, leer de .env.production
if [ -z "$REMOTE_HOST" ]; then
    if [ -f ".env.production" ]; then
        REMOTE_HOST=$(grep "^REMOTE_HOST=" .env.production | cut -d '=' -f2)
        REMOTE_USER=$(grep "^REMOTE_USER=" .env.production | cut -d '=' -f2)
    else
        echo -e "${RED}❌ Especifica el host: ./update.sh [host] [user]${NC}"
        exit 1
    fi
fi

echo "Host: $REMOTE_HOST"
echo "Usuario: $REMOTE_USER"
echo ""

# 1. Commit cambios locales
echo -e "${YELLOW}1️⃣  Preparando cambios locales...${NC}"

read -p "Descripción de los cambios (ej: Mejorar formulario mobile): " COMMIT_MSG

git add .
git commit -m "ui: $COMMIT_MSG" || echo "Sin cambios nuevos"
git push origin $(git rev-parse --abbrev-ref HEAD)

echo -e "${GREEN}✅ Cambios pusheados${NC}"

echo ""

# 2. Actualizar en servidor
echo -e "${YELLOW}2️⃣  Actualizando en servidor remoto...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
cd proyecto-final-internet
git fetch origin
git pull origin main
echo "Código actualizado"
EOF

echo -e "${GREEN}✅ Código actualizado en servidor${NC}"

echo ""

# 3. Reiniciar si es necesario
echo -e "${YELLOW}3️⃣  Reiniciando servicio...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
if command -v systemctl &> /dev/null; then
    sudo systemctl restart eafit-api || echo "Manual restart needed"
fi
EOF

echo -e "${GREEN}✅ Servicio reiniciado${NC}"

echo ""

# 4. Verificar
echo -e "${YELLOW}4️⃣  Verificando...${NC}"

sleep 2

if curl -s "http://$REMOTE_HOST/health" | grep -q "OK"; then
    echo -e "${GREEN}✅ Actualización completada${NC}"
else
    echo -e "${YELLOW}⚠️  Verificando manualmente...${NC}"
fi

echo ""
echo -e "${BLUE}✨ La interfaz ha sido actualizada${NC}"
echo "   Accede a: http://$REMOTE_HOST/"
echo ""
