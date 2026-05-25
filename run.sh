#!/bin/bash

# ▶️ RUN - Ejecutar la Aplicación EAFIT
# Uso: ./run.sh [dev|prod|test]
# 
# Ejemplos:
#   ./run.sh              # Modo desarrollo (por defecto)
#   ./run.sh dev          # Modo desarrollo explícito
#   ./run.sh prod         # Modo producción
#   ./run.sh test         # Modo testing

set -e

echo "▶️  Iniciando aplicación EAFIT..."
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Obtener modo (default: dev)
MODE=${1:-dev}

# Cambiar a directorio web-app
cd web-app

# Activar entorno virtual
if [ ! -d "../venv" ]; then
    echo -e "${YELLOW}⚠️  Entorno virtual no encontrado, ejecuta: ../setup.sh${NC}"
    exit 1
fi

source ../venv/bin/activate

# Verificar .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env no encontrado, copiando desde .env.example...${NC}"
    cp ../.env.example .env
    echo -e "${YELLOW}   IMPORTANTE: Edita .env con tus valores reales${NC}"
fi

# Cargar variables de entorno
export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}🚀 INFORMACIÓN DE LA SESIÓN${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo "Modo: $MODE"
echo "Puerto: 5000"
echo "Idioma: ${LANGUAGE:-es}"
echo "BD: ${DB_HOST:-localhost}:${DB_PORT:-5432}/${DB_NAME:-proyecto_final}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Ejecutar según el modo
case $MODE in
    dev)
        echo -e "${GREEN}▶️  Iniciando en MODO DESARROLLO...${NC}"
        export FLASK_ENV=development
        export FLASK_DEBUG=1
        echo "📌 Accede a: http://localhost:5000/"
        echo "📌 Presiona Ctrl+C para detener"
        echo ""
        python app.py
        ;;
    
    prod)
        echo -e "${GREEN}▶️  Iniciando en MODO PRODUCCIÓN...${NC}"
        export FLASK_ENV=production
        export FLASK_DEBUG=0
        
        # Verificar si gunicorn está instalado
        if ! command -v gunicorn &> /dev/null; then
            echo -e "${YELLOW}Instalando gunicorn...${NC}"
            pip install gunicorn
        fi
        
        echo "📌 Accede a: http://localhost:5000/"
        echo "📌 Presiona Ctrl+C para detener"
        echo ""
        gunicorn -w 4 -b 0.0.0.0:5000 app:app
        ;;
    
    test)
        echo -e "${GREEN}▶️  Iniciando en MODO TESTING...${NC}"
        export FLASK_ENV=testing
        export FLASK_DEBUG=1
        
        # Verificar si pytest está instalado
        if ! command -v pytest &> /dev/null; then
            echo -e "${YELLOW}Instalando pytest...${NC}"
            pip install pytest pytest-cov
        fi
        
        echo ""
        pytest -v --cov=. ../docs/tests/
        ;;
    
    *)
        echo -e "${RED}❌ Modo desconocido: $MODE${NC}"
        echo ""
        echo "Modos disponibles:"
        echo "  dev  - Desarrollo (con debug)"
        echo "  prod - Producción (gunicorn)"
        echo "  test - Testing (pytest)"
        exit 1
        ;;
esac
