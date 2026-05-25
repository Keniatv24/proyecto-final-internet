#!/bin/bash

# 🚀 SETUP - Configuración Inicial del Proyecto EAFIT
# Ejecutar una sola vez al clonar el repositorio
# Uso: chmod +x setup.sh && ./setup.sh

set -e  # Salir si hay error

echo "📦 SETUP INICIAL - EAFIT Proyecto Final"
echo "========================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar requisitos previos
echo -e "${YELLOW}1️⃣  Verificando requisitos previos...${NC}"

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 no encontrado${NC}"
    echo "Instala Python 3.11+ desde: https://www.python.org/downloads/"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo -e "${GREEN}✅ Python $PYTHON_VERSION encontrado${NC}"

# Verificar pip
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ pip3 encontrado${NC}"

# Verificar Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Git encontrado${NC}"

# Verificar PostgreSQL (opcional)
if command -v psql &> /dev/null; then
    PSQL_VERSION=$(psql --version | awk '{print $3}')
    echo -e "${GREEN}✅ PostgreSQL $PSQL_VERSION encontrado${NC}"
else
    echo -e "${YELLOW}⚠️  PostgreSQL no encontrado (instálalo para testing local)${NC}"
fi

echo ""

# 2. Crear entorno virtual
echo -e "${YELLOW}2️⃣  Creando entorno virtual...${NC}"

if [ -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Entorno virtual ya existe, omitiendo...${NC}"
else
    python3 -m venv venv
    echo -e "${GREEN}✅ Entorno virtual creado${NC}"
fi

# Activar entorno
source venv/bin/activate
echo -e "${GREEN}✅ Entorno virtual activado${NC}"

echo ""

# 3. Instalar dependencias
echo -e "${YELLOW}3️⃣  Instalando dependencias...${NC}"

pip install --upgrade pip setuptools wheel
pip install -r web-app/requirements.txt

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

echo ""

# 4. Crear archivo .env si no existe
echo -e "${YELLOW}4️⃣  Configurando variables de entorno...${NC}"

if [ -f "web-app/.env" ]; then
    echo -e "${YELLOW}⚠️  .env ya existe, omitiendo...${NC}"
else
    cp .env.example web-app/.env
    echo -e "${GREEN}✅ .env creado desde .env.example${NC}"
    echo -e "${YELLOW}   ⚠️  IMPORTANTE: Edita web-app/.env con tus valores reales${NC}"
fi

echo ""

# 5. Verificar base de datos (opcional)
echo -e "${YELLOW}5️⃣  Verificando base de datos...${NC}"

if [ -z "$DB_HOST" ]; then
    DB_HOST="localhost"
fi

# Crear directorio para logs
mkdir -p logs
echo -e "${GREEN}✅ Carpeta de logs creada${NC}"

echo ""

# 6. Crear carpetas necesarias
echo -e "${YELLOW}6️⃣  Creando estructura de carpetas...${NC}"

mkdir -p web-app/static/css
mkdir -p web-app/static/js
mkdir -p web-app/utils
mkdir -p logs
mkdir -p backups

echo -e "${GREEN}✅ Estructura de carpetas lista${NC}"

echo ""

# 7. Mostrar resumen
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SETUP COMPLETADO CON ÉXITO${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "1️⃣  Editar variables de entorno:"
echo -e "   ${YELLOW}nano web-app/.env${NC}"
echo ""
echo "2️⃣  Configurar base de datos PostgreSQL:"
echo "   - Crear BD 'proyecto_final'"
echo "   - Crear tabla 'registros'"
echo "   - Ver: https://github.com/Keniatv24/proyecto-final-internet#base-de-datos-postgresql"
echo ""
echo "3️⃣  Ejecutar la aplicación:"
echo -e "   ${YELLOW}./run.sh${NC}"
echo ""
echo "4️⃣  Acceder en navegador:"
echo -e "   ${YELLOW}http://localhost:5000/${NC}"
echo ""
echo "📚 Para más info: cat README.md"
echo "⚡ Inicio rápido: cat QUICK_START.md"
echo ""
