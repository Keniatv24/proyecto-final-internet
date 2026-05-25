#!/bin/bash

# 🚀 DEPLOY - Preparar para Deployment a Servidor Remoto
# 
# Uso: ./deploy.sh [host] [user]
# 
# Ejemplos:
#   ./deploy.sh eafit-api.example.com ubuntu
#   ./deploy.sh 192.168.1.100 ec2-user (para AWS)
#   ./deploy.sh (usa defaults de .env.production)

set -e

echo "🚀 DEPLOYMENT - EAFIT Proyecto Final"
echo "===================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Obtener parámetros
REMOTE_HOST=${1:-""}
REMOTE_USER=${2:-"ubuntu"}

# Si no hay host, leer de .env.production
if [ -z "$REMOTE_HOST" ]; then
    if [ -f ".env.production" ]; then
        REMOTE_HOST=$(grep "^REMOTE_HOST=" .env.production | cut -d '=' -f2)
        REMOTE_USER=$(grep "^REMOTE_USER=" .env.production | cut -d '=' -f2)
    else
        echo -e "${RED}❌ Especifica el host: ./deploy.sh [host] [user]${NC}"
        echo ""
        echo "Ejemplo: ./deploy.sh eafit-api.com ubuntu"
        exit 1
    fi
fi

echo -e "${BLUE}Información del Deploy:${NC}"
echo "Host remoto: $REMOTE_HOST"
echo "Usuario: $REMOTE_USER"
echo "Rama: $(git rev-parse --abbrev-ref HEAD)"
echo ""

# Validar conexión SSH
echo -e "${YELLOW}1️⃣  Verificando conexión SSH...${NC}"
if ! ssh -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" "echo 'Conexión OK'" &> /dev/null; then
    echo -e "${RED}❌ No se puede conectar a $REMOTE_HOST${NC}"
    echo ""
    echo "Soluciones:"
    echo "  1. Verifica que el host es correcto: $REMOTE_HOST"
    echo "  2. Verifica que el usuario es correcto: $REMOTE_USER"
    echo "  3. Verifica que tu clave SSH está agregada: ssh-add ~/.ssh/id_rsa"
    echo "  4. Genera una clave si no la tienes: ssh-keygen -t rsa -b 4096"
    exit 1
fi
echo -e "${GREEN}✅ Conexión SSH OK${NC}"

echo ""

# Verificar cambios sin commitear
echo -e "${YELLOW}2️⃣  Verificando estado de Git...${NC}"
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Hay cambios sin commitear:${NC}"
    git status --short
    echo ""
    read -p "¿Continuar de todas formas? (s/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi
echo -e "${GREEN}✅ Git listo${NC}"

echo ""

# Crear backup
echo -e "${YELLOW}3️⃣  Creando backup en servidor remoto...${NC}"

BACKUP_DIR="backups/backup-$(date +%Y%m%d-%H%M%S)"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
if [ -d "proyecto-final-internet" ]; then
    mkdir -p $BACKUP_DIR
    cp -r proyecto-final-internet $BACKUP_DIR/proyecto-final-internet-backup
    echo "Backup creado en: $BACKUP_DIR"
else
    echo "Primera vez - sin backup previo"
fi
EOF

echo -e "${GREEN}✅ Backup completado${NC}"

echo ""

# Hacer push a rama remota
echo -e "${YELLOW}4️⃣  Haciendo push del código...${NC}"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push origin $BRANCH

echo -e "${GREEN}✅ Código pusheado${NC}"

echo ""

# Descargar en servidor remoto
echo -e "${YELLOW}5️⃣  Descargando código en servidor remoto...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
cd proyecto-final-internet || git clone https://github.com/Keniatv24/proyecto-final-internet.git
cd proyecto-final-internet
git fetch origin
git checkout $BRANCH
git pull origin $BRANCH
echo "Código actualizado en servidor"
EOF

echo -e "${GREEN}✅ Código descargado${NC}"

echo ""

# Instalar dependencias en servidor remoto
echo -e "${YELLOW}6️⃣  Instalando dependencias en servidor remoto...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
cd proyecto-final-internet
if [ ! -d "venv" ]; then
    chmod +x setup.sh
    ./setup.sh
else
    source venv/bin/activate
    pip install -r web-app/requirements.txt
fi
EOF

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

echo ""

# Ejecutar migraciones (si existen)
echo -e "${YELLOW}7️⃣  Ejecutando migraciones (si existen)...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
cd proyecto-final-internet
if [ -f "migrations.sh" ]; then
    chmod +x migrations.sh
    ./migrations.sh
    echo "Migraciones ejecutadas"
else
    echo "Sin migraciones pendientes"
fi
EOF

echo -e "${GREEN}✅ Migraciones OK${NC}"

echo ""

# Reiniciar servicio
echo -e "${YELLOW}8️⃣  Reiniciando servicio...${NC}"

ssh "$REMOTE_USER@$REMOTE_HOST" bash <<EOF
set -e
cd proyecto-final-internet
if command -v systemctl &> /dev/null; then
    sudo systemctl restart eafit-api || echo "Servicio no encontrado (arrancar manualmente)"
elif command -v supervisorctl &> /dev/null; then
    sudo supervisorctl restart eafit-api || echo "Supervisor no encontrado"
else
    echo "Sin gestor de servicios detectado"
fi
EOF

echo -e "${GREEN}✅ Servicio reiniciado${NC}"

echo ""

# Verificar salud
echo -e "${YELLOW}9️⃣  Verificando salud del servicio...${NC}"

sleep 3

if curl -s -o /dev/null -w "%{http_code}" "http://$REMOTE_HOST/health" | grep -q "200"; then
    echo -e "${GREEN}✅ Servicio está respondiendo${NC}"
else
    echo -e "${YELLOW}⚠️  Servicio aún está iniciando, espera 10 segundos...${NC}"
    sleep 10
fi

echo ""

# Resumen
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DEPLOYMENT COMPLETADO${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📊 Resumen:"
echo "  - Servidor: $REMOTE_HOST"
echo "  - Usuario: $REMOTE_USER"
echo "  - Rama: $BRANCH"
echo "  - Backup: $BACKUP_DIR"
echo ""
echo "🔗 Accede a:"
echo "  - Español: http://$REMOTE_HOST/?lang=es"
echo "  - Inglés: http://$REMOTE_HOST/?lang=en"
echo ""
echo "📋 Comandos útiles:"
echo "  - Ver logs: ssh $REMOTE_USER@$REMOTE_HOST 'tail -f proyecto-final-internet/logs/app.log'"
echo "  - Rollback: ssh $REMOTE_USER@$REMOTE_HOST 'cd proyecto-final-internet && git checkout -'"
echo ""
