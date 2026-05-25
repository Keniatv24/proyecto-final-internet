#!/bin/bash

# 🔧 TROUBLESHOOTING - Diagnosticar y reparar problemas comunes
#
# Uso: chmod +x troubleshoot.sh && ./troubleshoot.sh

set -e

echo "🔧 TROUBLESHOOTING - EAFIT Proyecto Final"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# 1. VERIFICAR PYTHON Y ENTORNO
# ============================================
echo -e "${BLUE}1️⃣  Verificando Python y Entorno${NC}"
echo ""

python3 --version
pip3 --version

if [ -d "venv" ]; then
    echo -e "${GREEN}✅ Entorno virtual encontrado${NC}"
    source venv/bin/activate
else
    echo -e "${RED}❌ Entorno virtual NO encontrado${NC}"
    echo "Solución: Ejecutar ./setup.sh"
fi

echo ""

# ============================================
# 2. VERIFICAR ARCHIVO .env
# ============================================
echo -e "${BLUE}2️⃣  Verificando archivo .env${NC}"
echo ""

if [ -f "web-app/.env" ]; then
    echo -e "${GREEN}✅ .env encontrado${NC}"
    
    # Mostrar valores sin exponer la contraseña
    echo ""
    echo "Valores en .env:"
    grep "^DB_" web-app/.env | sed 's/=.*/=***/' || echo "Sin variables DB_"
    grep "^LANGUAGE" web-app/.env || echo "LANGUAGE no configurado"
else
    echo -e "${RED}❌ .env NO encontrado${NC}"
    echo "Solución: cp .env.example web-app/.env"
fi

echo ""

# ============================================
# 3. VERIFICAR POSTGRESQL
# ============================================
echo -e "${BLUE}3️⃣  Verificando PostgreSQL${NC}"
echo ""

if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL NO está instalado${NC}"
    echo ""
    echo "Instalar en:"
    echo "  Ubuntu/Debian: sudo apt install postgresql postgresql-contrib"
    echo "  macOS: brew install postgresql"
    echo "  Windows: https://www.postgresql.org/download/windows/"
    exit 1
fi

PSQL_VERSION=$(psql --version | awk '{print $3}')
echo -e "${GREEN}✅ PostgreSQL $PSQL_VERSION instalado${NC}"

# Verificar si PostgreSQL está corriendo
echo ""
echo "Verificando si PostgreSQL está activo..."

if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet postgresql; then
        echo -e "${GREEN}✅ PostgreSQL está corriendo${NC}"
    else
        echo -e "${RED}❌ PostgreSQL NO está activo${NC}"
        echo "Solución: sudo systemctl start postgresql"
        exit 1
    fi
elif command -v brew &> /dev/null; then
    # macOS
    if pg_isready &> /dev/null; then
        echo -e "${GREEN}✅ PostgreSQL está corriendo${NC}"
    else
        echo -e "${RED}❌ PostgreSQL NO está activo${NC}"
        echo "Solución: brew services start postgresql"
        exit 1
    fi
fi

echo ""

# ============================================
# 4. VERIFICAR CONEXIÓN A BASE DE DATOS
# ============================================
echo -e "${BLUE}4️⃣  Verificando conexión a Base de Datos${NC}"
echo ""

# Leer variables del .env
export $(cat web-app/.env | grep -v '^#' | grep -v '^$' | xargs)

echo "Intentando conectar a PostgreSQL..."
echo "  Host: ${DB_HOST:-localhost}"
echo "  Puerto: ${DB_PORT:-5432}"
echo "  BD: ${DB_NAME:-proyecto_final}"
echo "  Usuario: ${DB_USER:-admin}"
echo ""

# Intentar conexión con usuario postgres (sin contraseña)
if PGPASSWORD='' psql -h "${DB_HOST:-localhost}" -U postgres -d postgres -c "SELECT 1;" &> /dev/null; then
    echo -e "${GREEN}✅ Conectado como 'postgres'${NC}"
    
    # Verificar si existe el usuario admin
    echo ""
    echo "Verificando usuario 'admin'..."
    
    if PGPASSWORD='' psql -h "${DB_HOST:-localhost}" -U postgres -d postgres -c "SELECT usename FROM pg_user WHERE usename='admin';" | grep -q admin; then
        echo -e "${GREEN}✅ Usuario 'admin' existe${NC}"
        
        # Verificar contraseña
        echo ""
        echo -e "${YELLOW}🔑 Para verificar/cambiar contraseña del usuario 'admin':${NC}"
        echo ""
        echo "Opción A: Cambiar contraseña a 'admin123' (lo que espera .env)"
        echo "  ${YELLOW}sudo -u postgres psql${NC}"
        echo "  ${YELLOW}ALTER USER admin PASSWORD 'admin123';${NC}"
        echo "  ${YELLOW}\\q${NC}"
        echo ""
        echo "Opción B: Verificar la contraseña actual"
        echo "  ${YELLOW}psql -h localhost -U admin -d proyecto_final${NC}"
        echo "  (Escribir la contraseña que creas que es)"
        
    else
        echo -e "${RED}❌ Usuario 'admin' NO existe${NC}"
        echo ""
        echo "Solución: Crear usuario"
        echo "  ${YELLOW}sudo -u postgres psql${NC}"
        echo "  ${YELLOW}CREATE USER admin WITH PASSWORD 'admin123';${NC}"
        echo "  ${YELLOW}\\q${NC}"
    fi
    
    # Verificar si existe la BD
    echo ""
    echo "Verificando base de datos '${DB_NAME:-proyecto_final}'..."
    
    if PGPASSWORD='' psql -h "${DB_HOST:-localhost}" -U postgres -d postgres -c "SELECT datname FROM pg_database WHERE datname='${DB_NAME:-proyecto_final}';" | grep -q "${DB_NAME:-proyecto_final}"; then
        echo -e "${GREEN}✅ Base de datos '${DB_NAME:-proyecto_final}' existe${NC}"
        
        # Verificar tabla registros
        echo ""
        echo "Verificando tabla 'registros'..."
        
        if PGPASSWORD="" psql -h "${DB_HOST:-localhost}" -U postgres -d "${DB_NAME:-proyecto_final}" -c "SELECT 1 FROM information_schema.tables WHERE table_name='registros';" | grep -q 1; then
            echo -e "${GREEN}✅ Tabla 'registros' existe${NC}"
        else
            echo -e "${YELLOW}⚠️  Tabla 'registros' NO existe${NC}"
            echo ""
            echo "Solución: Crear tabla"
            echo "  ${YELLOW}sudo -u postgres psql -d ${DB_NAME:-proyecto_final}${NC}"
            echo "  ${YELLOW}CREATE TABLE registros (${NC}"
            echo "  ${YELLOW}  id SERIAL PRIMARY KEY,${NC}"
            echo "  ${YELLOW}  nombre VARCHAR(100) NOT NULL,${NC}"
            echo "  ${YELLOW}  comuna INT NOT NULL CHECK (comuna >= 1 AND comuna <= 10),${NC}"
            echo "  ${YELLOW}  fecha_ingreso DATE NOT NULL,${NC}"
            echo "  ${YELLOW}  carrera VARCHAR(50) NOT NULL,${NC}"
            echo "  ${YELLOW}  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP${NC}"
            echo "  ${YELLOW});${NC}"
            echo "  ${YELLOW}\\q${NC}"
        fi
    else
        echo -e "${RED}❌ Base de datos '${DB_NAME:-proyecto_final}' NO existe${NC}"
        echo ""
        echo "Solución: Crear base de datos"
        echo "  ${YELLOW}sudo -u postgres psql${NC}"
        echo "  ${YELLOW}CREATE DATABASE ${DB_NAME:-proyecto_final} OWNER admin;${NC}"
        echo "  ${YELLOW}\\q${NC}"
    fi
    
else
    echo -e "${RED}❌ No se puede conectar a PostgreSQL${NC}"
    echo ""
    echo "Soluciones:"
    echo "  1. Verificar que PostgreSQL está corriendo"
    echo "  2. Verificar host y puerto en .env"
    echo "  3. Reiniciar PostgreSQL"
fi

echo ""
echo "════════════════════════════════════════"
echo ""

# ============================================
# 5. RESUMEN Y PRÓXIMOS PASOS
# ============================================
echo -e "${BLUE}📋 RESUMEN${NC}"
echo ""
echo "Si todas las verificaciones pasaron:"
echo "  1. Edita ${YELLOW}web-app/.env${NC} con las credenciales correctas"
echo "  2. Ejecuta ${YELLOW}./run.sh dev${NC}"
echo "  3. Accede a http://localhost:5000/"
echo ""
echo "Si algo falló, sigue las soluciones arriba"
echo ""
