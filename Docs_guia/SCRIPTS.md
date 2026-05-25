# 🛠️ SCRIPTS DISPONIBLES

> Aquí tienes todos los scripts `.sh` disponibles y cómo usarlos

---

## 📋 Tabla de Contenidos

1. [setup.sh](#setupsh) - Configuración inicial
2. [run.sh](#runsh) - Ejecutar la aplicación
3. [deploy.sh](#deploysh) - Deploy a servidor remoto
4. [update.sh](#updatesh) - Actualizar interfaz remota

---

## setup.sh

**Propósito:** Configuración inicial del proyecto

**Cuándo usar:**
- Primera vez que clonas el repositorio
- Después de agregar nuevas dependencias

**Uso:**
```bash
chmod +x setup.sh
./setup.sh
```

**Qué hace:**
1. ✅ Verifica requisitos (Python, pip, Git, PostgreSQL)
2. ✅ Crea entorno virtual
3. ✅ Instala dependencias Python
4. ✅ Crea archivo `.env` si no existe
5. ✅ Crea estructura de carpetas

**Ejemplo de output:**
```
📦 SETUP INICIAL - EAFIT Proyecto Final
========================================

1️⃣  Verificando requisitos previos...
✅ Python 3.11.0 encontrado
✅ pip3 encontrado
✅ Git encontrado

2️⃣  Creando entorno virtual...
✅ Entorno virtual creado

3️⃣  Instalando dependencias...
✅ Dependencias instaladas

✅ SETUP COMPLETADO CON ÉXITO
```

**Próximos pasos después de setup:**
```bash
nano web-app/.env  # Editar configuración
psql -U postgres   # Crear base de datos
./run.sh           # Ejecutar aplicación
```

---

## run.sh

**Propósito:** Ejecutar la aplicación

**Cuándo usar:**
- Desarrollo local
- Testing
- Producción

**Uso:**
```bash
./run.sh [modo]
```

**Modos disponibles:**

### run.sh dev (Desarrollo)
```bash
./run.sh dev
# O simplemente
./run.sh  # dev es el default
```

**Características:**
- Debug habilitado
- Auto-reload al cambiar archivos
- Más logs y mensajes
- Error messages detallados

**Ejemplo:**
```
▶️  Iniciando aplicación EAFIT...

═══════════════════════════════════════
🚀 INFORMACIÓN DE LA SESIÓN
═══════════════════════════════════════
Modo: dev
Puerto: 5000
Idioma: es
BD: localhost:5432/proyecto_final
═══════════════════════════════════════

▶️  Iniciando en MODO DESARROLLO...
📌 Accede a: http://localhost:5000/
📌 Presiona Ctrl+C para detener
```

### run.sh prod (Producción)
```bash
./run.sh prod
```

**Características:**
- Usa Gunicorn (WSGI server)
- 4 workers para mejor performance
- Debug deshabilitado
- Optimizado para servidor

**Requisitos:**
- `pip install gunicorn` (se instala automáticamente)

### run.sh test (Testing)
```bash
./run.sh test
```

**Características:**
- Ejecuta suite de tests
- Muestra cobertura de código
- Modo testing activado

**Requisitos:**
- `pip install pytest pytest-cov` (se instala automáticamente)

---

## deploy.sh

**Propósito:** Deploy completo a servidor remoto

**Cuándo usar:**
- Primer deploy
- Cambios grandes (backend + database)
- Actualizar dependencias

**Uso:**
```bash
chmod +x deploy.sh

# Opción 1: Con parámetros
./deploy.sh your-server.com ubuntu

# Opción 2: Con .env.production
./deploy.sh

# Opción 3: Solo especificar host
./deploy.sh your-server.com
```

**Requisitos previos:**
```bash
# 1. SSH key configurada
ssh-keygen -t rsa -b 4096 -f ~/.ssh/eafit-key

# 2. Copiar SSH key al servidor
ssh-copy-id -i ~/.ssh/eafit-key user@your-server.com

# 3. Verificar acceso
ssh user@your-server.com "echo 'OK'"
```

**Qué hace:**
1. ✅ Verifica conexión SSH
2. ✅ Crea backup automático
3. ✅ Hace push del código a GitHub
4. ✅ Descarga código en servidor remoto
5. ✅ Instala dependencias
6. ✅ Ejecuta migraciones de BD
7. ✅ Reinicia servicio
8. ✅ Verifica salud del servidor

**Ejemplo de uso completo:**
```bash
# 1. Hacer cambios locales
nano web-app/templates/index_es.html

# 2. Commit
git add .
git commit -m "ui: mejorar formulario"

# 3. Deploy (espera 5-10 minutos)
./deploy.sh eafit-api.example.com ubuntu

# 4. Verificar
curl http://eafit-api.example.com/
```

**Output esperado:**
```
🚀 DEPLOYMENT - EAFIT Proyecto Final
====================================

1️⃣  Verificando conexión SSH...
✅ Conexión SSH OK

2️⃣  Verificando estado de Git...
✅ Git listo

3️⃣  Creando backup en servidor remoto...
✅ Backup completado

4️⃣  Haciendo push del código...
✅ Código pusheado

5️⃣  Descargando código en servidor remoto...
✅ Código descargado

6️⃣  Instalando dependencias en servidor remoto...
✅ Dependencias instaladas

7️⃣  Ejecutando migraciones (si existen)...
✅ Migraciones OK

8️⃣  Reiniciando servicio...
✅ Servicio reiniciado

9️⃣  Verificando salud del servicio...
✅ Servicio está respondiendo

════════════════════════════════════════
✅ DEPLOYMENT COMPLETADO
════════════════════════════════════════
```

**Troubleshooting:**
```bash
# Error: "Connection refused"
# Solución: Verificar que SSH está funcionando
ssh -vvv user@your-server.com

# Error: "Permission denied"
# Solución: Agregar SSH key
ssh-copy-id -i ~/.ssh/eafit-key user@your-server.com

# Error: "git push failed"
# Solución: Hacer push manual primero
git push origin main
```

---

## update.sh

**Propósito:** Actualización rápida (solo interfaz)

**Cuándo usar:**
- Cambios solo en HTML/CSS/JS
- Cambios rápidos que no afecten BD
- Actualizaciones de emergencia

**Uso:**
```bash
chmod +x update.sh

# Opción 1: Con parámetros
./update.sh your-server.com ubuntu

# Opción 2: Con .env.production
./update.sh
```

**Requisitos:**
- Servidor ya está deployado (ejecutaste deploy.sh antes)
- SSH key configurada

**Qué hace:**
1. ✅ Te pide descripción de cambios
2. ✅ Hace commit automático
3. ✅ Hace push a GitHub
4. ✅ Pull en servidor remoto
5. ✅ Reinicia servicio

**Ejemplo:**
```bash
./update.sh

# Te pide:
# Descripción de los cambios: Mejorar diseño del formulario mobile

# Luego:
# ✅ Cambios pusheados
# ✅ Código actualizado en servidor
# ✅ Servicio reiniciado
# ✅ La interfaz ha sido actualizada
# Accede a: http://your-server.com/
```

**Tiempo de ejecución:** ~2 minutos vs ~10 minutos de deploy.sh

---

## 🚀 Workflow Típico

### Desarrollo Local

```bash
# Setup inicial
chmod +x setup.sh
./setup.sh

# Editar archivos
nano web-app/templates/index_es.html

# Probar localmente
./run.sh dev
# http://localhost:5000

# Cuando está listo, commit
git add .
git commit -m "ui: mejorar formulario"
```

### Deploy a Producción (Primera vez)

```bash
# Setup del servidor (una sola vez)
chmod +x deploy.sh
cp .env.example .env.production
nano .env.production  # Editar con datos reales

# Hacer deployment completo
./deploy.sh

# Verificar
curl http://your-server.com/health
```

### Actualizaciones Posteriores

```bash
# Para cambios ligeros (recomendado)
./update.sh

# Para cambios de backend/database
./deploy.sh

# Para verlo en vivo
http://your-server.com
```

---

## 📝 Archivo .env.production

Para usar los scripts sin parámetros, crear:

```bash
cat > .env.production << EOF
REMOTE_HOST=your-server.com
REMOTE_USER=ubuntu
SSH_KEY=~/.ssh/eafit-key
EOF
```

Entonces:
```bash
./deploy.sh  # Sin parámetros
./update.sh  # Sin parámetros
```

---

## 🔧 Permisos de Ejecución

**Primera vez que usas los scripts:**

```bash
# Hacer ejecutables
chmod +x setup.sh run.sh deploy.sh update.sh

# O todos de una vez
chmod +x *.sh
```

**Verificar permisos:**
```bash
ls -l *.sh
# Debería verse: -rwxr-xr-x
```

---

## 🆘 Comandos de Debugging

**Ver qué hace deploy.sh sin ejecutar:**
```bash
bash -x deploy.sh 2>&1 | head -50
```

**Ver logs del servidor remoto:**
```bash
ssh user@your-server.com 'tail -f ~/proyecto-final-internet/logs/app.log'
```

**Ver estado del servicio:**
```bash
ssh user@your-server.com 'sudo supervisorctl status eafit-api'
```

**Rollback (deshacer último deploy):**
```bash
ssh user@your-server.com 'cd proyecto-final-internet && git checkout -'
ssh user@your-server.com 'sudo supervisorctl restart eafit-api'
```

---

## 💡 Tips y Trucos

**Crear alias para comandos frecuentes:**
```bash
alias deploy='./deploy.sh'
alias update='./update.sh'
alias run='./run.sh dev'

# Luego:
deploy        # En lugar de ./deploy.sh
update        # En lugar de ./update.sh
run           # En lugar de ./run.sh dev
```

**Ejecutar en background:**
```bash
nohup ./run.sh prod > run.log 2>&1 &
tail -f run.log
```

**Usar con cron (actualizar diariamente):**
```bash
# Agregar a crontab
crontab -e

# Línea a agregar:
0 3 * * * cd /path/to/proyecto && ./update.sh >> /var/log/eafit-update.log 2>&1
```

---

**Última actualización:** 21 de mayo de 2026  
**Versión:** 1.0
