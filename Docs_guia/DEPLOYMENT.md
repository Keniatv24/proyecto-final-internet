# 🚀 DEPLOYMENT - Guía Completa

> Cómo deployar y actualizar la interfaz en tu servidor remoto sin perder la conexión

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Setup de Servidor Remoto](#setup-de-servidor-remoto)
3. [Primer Deployment](#primer-deployment)
4. [Actualizaciones Posteriores](#actualizaciones-posteriores)
5. [Troubleshooting](#troubleshooting)

---

## 📋 Requisitos Previos

### Local (Tu computadora)

- ✅ Git instalado y configurado
- ✅ SSH key generada: `ssh-keygen -t rsa -b 4096`
- ✅ SSH key agregada al servidor remoto
- ✅ Acceso SSH al servidor (sin necesidad de contraseña)

**Verificar acceso SSH:**
```bash
ssh -T git@github.com  # Debería conectar sin contraseña
ssh user@your-server   # Debería conectar sin contraseña
```

### Servidor Remoto (AWS/DigitalOcean/VPS)

- ✅ Linux (Ubuntu 20.04+ recomendado)
- ✅ Python 3.11+
- ✅ PostgreSQL 12+
- ✅ Git instalado
- ✅ sudo permissions

---

## 🔧 Setup de Servidor Remoto

### Paso 1: Conectar vía SSH

```bash
ssh user@your-server.com
# O para AWS
ssh -i ~/.ssh/aws-key.pem ec2-user@your-ec2-instance.com
```

### Paso 2: Instalar Dependencias

```bash
sudo apt update
sudo apt upgrade -y

# Python y pip
sudo apt install -y python3.11 python3.11-venv python3-pip

# PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Otras herramientas
sudo apt install -y git curl nginx supervisor
```

### Paso 3: Configurar PostgreSQL

```bash
# Conectar a PostgreSQL
sudo -u postgres psql

# Crear usuario
CREATE USER admin WITH PASSWORD 'admin123';

# Crear base de datos
CREATE DATABASE proyecto_final OWNER admin;

# Crear tabla
\c proyecto_final

CREATE TABLE registros (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna INT NOT NULL CHECK (comuna >= 1 AND comuna <= 10),
    fecha_ingreso DATE NOT NULL,
    carrera VARCHAR(50) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\q
```

### Paso 4: Crear Usuario para la App

```bash
# Crear usuario
sudo useradd -m -s /bin/bash eafit

# Agregar a sudoers (opcional)
sudo usermod -aG sudo eafit

# Switch a usuario
sudo su - eafit
```

### Paso 5: Clonar Repositorio

```bash
# Como usuario 'eafit'
cd ~
git clone https://github.com/Keniatv24/proyecto-final-internet.git
cd proyecto-final-internet

# Hacer ejecutables los scripts
chmod +x setup.sh run.sh deploy.sh update.sh
```

### Paso 6: Configurar Variables de Entorno

```bash
# Copiar template
cp .env.example .env

# Editar con valores reales
nano web-app/.env

# Debería verse así:
# DB_HOST=localhost
# DB_NAME=proyecto_final
# DB_USER=admin
# DB_PASSWORD=admin123
# LANGUAGE=es
# FLASK_ENV=production
# SECRET_KEY=tu-clave-segura-random-aqui
```

### Paso 7: Setup Inicial

```bash
# Ejecutar setup (crea venv, instala dependencies)
./setup.sh
```

### Paso 8: Configurar Supervisor (para que corra como servicio)

**En servidor remoto:**

```bash
# Crear archivo de configuración
sudo nano /etc/supervisor/conf.d/eafit-api.conf
```

**Pegar:**
```ini
[program:eafit-api]
directory=/home/eafit/proyecto-final-internet
command=/home/eafit/proyecto-final-internet/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 -c gunicorn_config.py web-app.app:app
user=eafit
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/home/eafit/proyecto-final-internet/logs/app.log
environment=FLASK_ENV=production,LANGUAGE=es
```

**Actualizar Supervisor:**
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start eafit-api
```

### Paso 9: Configurar Nginx (Reverse Proxy)

```bash
sudo nano /etc/nginx/sites-available/eafit-api
```

**Pegar:**
```nginx
server {
    listen 80;
    server_name your-server.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /home/eafit/proyecto-final-internet/web-app/static;
    }
}
```

**Activar:**
```bash
sudo ln -s /etc/nginx/sites-available/eafit-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Paso 10: Configurar SSL (Opcional pero Recomendado)

```bash
sudo apt install -y certbot python3-certbot-nginx

sudo certbot --nginx -d your-server.com
```

---

## 🚀 Primer Deployment

### Desde tu máquina local:

```bash
# 1. Asegurar SSH configurado
ssh-keygen -t rsa -b 4096 -f ~/.ssh/eafit-key
ssh-copy-id -i ~/.ssh/eafit-key user@your-server.com

# 2. Crear .env.production con datos del servidor
cp .env.example .env.production
nano .env.production

# Agregar:
# REMOTE_HOST=your-server.com
# REMOTE_USER=eafit

# 3. Ejecutar deploy
chmod +x deploy.sh
./deploy.sh your-server.com eafit

# O simplemente
./deploy.sh  # Usa valores de .env.production
```

**¿Qué hace deploy.sh?**
1. ✅ Verifica conexión SSH
2. ✅ Crea backup de código anterior
3. ✅ Hace push de tu rama
4. ✅ Descarga código en servidor
5. ✅ Instala dependencias
6. ✅ Ejecuta migraciones
7. ✅ Reinicia servicio
8. ✅ Verifica salud

---

## 🔄 Actualizaciones Posteriores

### Opción A: Actualización Rápida (Solo interfaz)

**Para cambios en HTML/CSS/JS:**

```bash
./update.sh your-server.com eafit

# O simplemente (usa .env.production)
./update.sh
```

**Proceso rápido (2 minutos):**
1. Commit local
2. Push a GitHub
3. Pull en servidor
4. Reinicia servicio

### Opción B: Actualización Completa

```bash
./deploy.sh your-server.com eafit
```

**Completo (5 minutos):**
1. Todo lo de actualización rápida
2. + Instala dependencias nuevas
3. + Ejecuta migraciones
4. + Hace backup completo

---

## 🔐 Configurar SSH sin Contraseña

**Locally:**
```bash
# Generar key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/eafit-key -N ""

# Copiar key al servidor
ssh-copy-id -i ~/.ssh/eafit-key user@your-server.com
```

**Resultado:**
```bash
./deploy.sh your-server.com eafit
# No te pide contraseña!
```

---

## 📝 Archivo .env.production

**Crear localmente en raíz del proyecto:**

```bash
# .env.production
REMOTE_HOST=eafit-api.example.com
REMOTE_USER=eafit
REMOTE_PORT=22
SSH_KEY=~/.ssh/eafit-key
```

**Entonces puedes hacer:**
```bash
./deploy.sh      # Usa .env.production automáticamente
./update.sh      # Usa .env.production automáticamente
```

---

## 🛠️ Workflow Típico

### Desarrollo Local

```bash
# 1. Hacer cambios
nano web-app/templates/index_es.html

# 2. Probar localmente
./run.sh dev

# 3. Si funciona, commit
git add .
git commit -m "ui: mejorar formulario mobile"
```

### Ir a Producción

```bash
# Opción A - Cambios ligeros
./update.sh

# Opción B - Cambios grandes
./deploy.sh

# Verificar
curl http://your-server.com/health
```

---

## 📊 Monitoreo

### Ver logs en tiempo real

```bash
ssh user@your-server.com 'tail -f ~/proyecto-final-internet/logs/app.log'
```

### Ver estado del servicio

```bash
ssh user@your-server.com 'sudo supervisorctl status eafit-api'
```

### Ver estadísticas de BD

```bash
ssh user@your-server.com 'psql -U admin -d proyecto_final -c "SELECT carrera, COUNT(*) FROM registros GROUP BY carrera;"'
```

---

## 🔄 Rollback (Si algo falla)

```bash
# En servidor remoto
cd ~/proyecto-final-internet
git log --oneline    # Ver commits
git checkout <commit-hash>
sudo supervisorctl restart eafit-api
```

O automático:
```bash
ssh user@your-server.com 'cd proyecto-final-internet && git checkout -'
```

---

## ⚠️ Troubleshooting

### Error: "Connection refused"

```bash
# Verificar que servicio está corriendo
ssh user@your-server.com 'sudo supervisorctl status eafit-api'

# Reiniciar
ssh user@your-server.com 'sudo supervisorctl restart eafit-api'
```

### Error: "Port 5000 already in use"

```bash
# Encontrar proceso
ssh user@your-server.com 'lsof -i :5000'

# Matar proceso
ssh user@your-server.com 'kill -9 <PID>'
```

### Error: "Database connection failed"

```bash
# Verificar PostgreSQL
ssh user@your-server.com 'sudo systemctl status postgresql'

# Reiniciar
ssh user@your-server.com 'sudo systemctl restart postgresql'

# Verificar credenciales en .env
ssh user@your-server.com 'cat ~/proyecto-final-internet/web-app/.env | grep DB_'
```

### Error: "Permission denied"

```bash
# Asegurar que carpetas tienen permisos
ssh user@your-server.com 'chmod -R 755 ~/proyecto-final-internet'
ssh user@your-server.com 'chmod -R 755 ~/proyecto-final-internet/logs'
```

---

## 🎓 Próximos Pasos

1. **Configurar dominio:**
   - Apuntar DNS a tu servidor
   - Configurar SSL con Let's Encrypt

2. **Configurar email:**
   - Para enviar reportes (FASE 3)
   - Usar SendGrid o Gmail

3. **Monitoreo:**
   - Configurar alertas si el servicio cae
   - Monitorear uso de recursos

4. **Backups:**
   - Backup automático de BD diariamente
   - Backup de código en otro lugar

---

## 📞 Comandos Rápidos

```bash
# Deploy
./deploy.sh

# Actualizar
./update.sh

# Ver logs
ssh user@your-server.com 'tail -f ~/proyecto-final-internet/logs/app.log'

# Reiniciar
ssh user@your-server.com 'sudo supervisorctl restart eafit-api'

# Status
ssh user@your-server.com 'sudo supervisorctl status eafit-api'

# SSH directo
ssh user@your-server.com

# Copiar archivo
scp file.txt user@your-server.com:~/proyecto-final-internet/
```

---

**Última actualización:** 21 de mayo de 2026  
**Versión:** 1.0
