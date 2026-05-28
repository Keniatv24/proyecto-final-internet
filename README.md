# 📋 EAFIT - Sistema de Registro de Estudiantes

**Proyecto Final - Curso Internet, Protocolos y Arquitectura**  
**Universidad EAFIT - 2026**

> Sistema integral de registro bilingüe (español/inglés) para potenciales estudiantes con interfaz moderna, validación robusta, panel administrativo y sistema de reportes automáticos por correo.

**Estado:** ✅ **PROYECTO COMPLETO - LISTO PARA PRODUCCIÓN**

---

## ✨ Características Principales

### 🎯 Formulario de Registro
- ✅ Interfaz moderna con Bootstrap 5.3.0
- ✅ Validación robusta en JavaScript (client-side)
- ✅ Soporte bilingüe (Español/Inglés)
- ✅ Diseño responsivo (mobile-first)
- ✅ Almacenamiento seguro en PostgreSQL
- ✅ Confirmación visual de registro exitoso

### 📊 Panel Administrativo
- ✅ Dashboard con estadísticas en tiempo real
- ✅ API REST para obtener datos (/api/statistics)
- ✅ Visualización de registros por comuna y carrera
- ✅ Interfaz intuitiva y profesional

### 📧 Sistema de Reportes
- ✅ Envío automático de reportes por correo
- ✅ Generación de reportes HTML formatados
- ✅ Estadísticas por comuna y programa académico
- ✅ Integración con Gmail/SMTP

### 🐳 Infraestructura & Deployment
- ✅ Dockerización completa
- ✅ Docker Compose para orquestación
- ✅ Scripts de automatización (setup, run, deploy)
- ✅ Configuración de entorno flexible
- ✅ Listo para deployment en producción

---

## 🚀 Inicio Rápido

### Requisitos Previos
- Python 3.11+
- PostgreSQL 12+ (o Docker)
- Git
- pip (gestor de paquetes)

### Instalación Automática (3 comandos)

```bash
# 1. Clonar repositorio
git clone https://github.com/Keniatv24/proyecto-final-internet.git
cd proyecto-final-internet

# 2. Setup automático (crea venv, instala dependencias, configura BD)
chmod +x setup.sh
./setup.sh

# 3. Ejecutar
./run.sh dev
```

**Acceder:** http://localhost:5000/

> 💡 **Más opciones:** Ver [Docs_guia/SCRIPTS.md](Docs_guia/SCRIPTS.md) para todos los comandos disponibles

---

## 🔧 Configuración

### 1. Variables de Entorno

Crear archivo `.env` en la carpeta `web-app/`:

```bash
# Base de Datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=proyecto_final
DB_USER=admin
DB_PASSWORD=admin123

# Idioma (es/en)
LANGUAGE=es

# Flask
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=tu-clave-secreta-aqui

# Email (SMTP para envío de reportes)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=1
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-contraseña-app
MAIL_DEFAULT_SENDER=noreply@eafit.edu.co
```

### 2. Base de Datos PostgreSQL

**Opción A: PostgreSQL Local**

```bash
# Iniciar PostgreSQL (según SO)
sudo systemctl start postgresql  # Linux
brew services start postgresql   # macOS

# Conectar y crear
psql -U postgres

# Comandos SQL:
CREATE USER admin WITH PASSWORD 'admin123';
CREATE DATABASE proyecto_final OWNER admin;
\c proyecto_final

CREATE TABLE registros (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna INT NOT NULL CHECK (comuna >= 1 AND comuna <= 10),
    carrera VARCHAR(100) NOT NULL,
    idioma VARCHAR(2) DEFAULT 'es',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_carrera ON registros(carrera);
CREATE INDEX idx_comuna ON registros(comuna);
```

**Opción B: PostgreSQL con Docker**

```bash
docker run -d \
  --name postgres-eafit \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=proyecto_final \
  -p 5432:5432 \
  postgres:15
```

### 3. Configuración Flask

Las variables se cargan automáticamente en `app.py`. Basta con tener `.env` configurado.

---

## ⚙️ Ejecución

### 📌 Modo 1: Quick Setup (Recomendado para primeros pasos)

```bash
chmod +x setup.sh
./setup.sh
./run.sh dev
```

Acceder: http://localhost:5000/

### 📌 Modo 2: Ejecución Manual

```bash
cd web-app
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configurar .env
export LANGUAGE=es
python app.py
```

### 📌 Modo 3: Docker

```bash
docker-compose up -d
```

Acceder: http://localhost:5000/

### 📌 Modo 4: Producción con Gunicorn

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

---

## 📂 Estructura del Proyecto

```
proyecto-final-internet/
│
├── README.md                    # Este archivo
├── .env.example                 # Template de variables (copiar a .env)
├── .env.production.example      # Variables para producción
├── .gitignore                   # Archivos a ignorar en Git
│
├── setup.sh                     # Script de instalación inicial
├── run.sh                       # Script para ejecutar (dev/prod)
├── deploy.sh                    # Script de deployment a servidor
├── update.sh                    # Script de actualización rápida
├── troubleshoot.sh              # Script de diagnóstico
├── quick-deploy.sh              # Deployment rápido
│
├── docker-compose.yml           # Orquestación Docker
├── gunicorn_config.py           # Configuración Gunicorn
│
├── docs/
│   ├── PROGRESO.md              # Roadmap de fases
│   ├── IMPLEMENTACION.md        # Detalles técnicos
│   ├── TESTING.md               # Guía de testing
│   ├── Plan.md                  # Requisitos iniciales
│   └── POSTGRESQL_ERROR.md      # Troubleshooting BD
│
├── Docs_guia/
│   ├── QUICK_START.md           # Inicio rápido
│   ├── SCRIPTS.md               # Referencia de scripts
│   ├── DEPLOYMENT.md            # Deployment a producción
│   ├── SETUP_QUICK.md           # Setup simplificado
│   ├── SETUP_GITHUB_ACTIONS.md  # CI/CD con GitHub
│   ├── SYNC_OPTIONS.md          # Opciones de sincronización
│   ├── AFTER_FIRST_REGISTER.md  # Pasos post-registro
│   └── ANALISIS_VS_REQUISITOS.md # Análisis de requisitos
│
├── web-app/
│   ├── app.py                   # Aplicación Flask principal
│   ├── requirements.txt         # Dependencias Python
│   ├── Dockerfile               # Configuración Docker
│   ├── .env                     # Variables de entorno (LOCAL - NO SUBIR)
│   │
│   ├── templates/
│   │   ├── index_es.html        # Formulario en español
│   │   ├── index_en.html        # Formulario en inglés
│   │   ├── admin_panel.html     # Dashboard de administrador
│   │   └── email_reporte.html   # Template de email
│   │
│   ├── static/
│   │   ├── css/
│   │   │   └── style.css        # Estilos CSS
│   │   └── js/
│   │       ├── validacion.js    # Validación client-side
│   │       └── charts.js        # Gráficas interactivas
│   │
│   └── utils/
│       └── reportes.py          # Utilidades de reportes
│
└── logs/                        # Archivos de log
```

---

## 📚 Endpoints API Disponibles

### 1. **Formulario de Registro**

```
POST /
Parámetros:
  - nombre (string, requerido)
  - comuna (int 1-10, requerido)
  - carrera (string, requerido)

Respuesta:
  - 200: Registro exitoso + mensaje confirmación
  - 400: Error en validación + mensaje error
```

### 2. **Health Check**

```
GET /health
Respuesta: 200 OK
```

### 3. **Estadísticas**

```
GET /api/statistics
Respuesta JSON:
{
  "communes": {
    "1": 5,
    "2": 3,
    ...
  },
  "careers": {
    "Medicina": 8,
    "Ingeniería": 5,
    ...
  },
  "total": 13
}
```

### 4. **Panel Administrativo**

```
GET /admin/panel
Retorna: Dashboard con gráficas e interfaz de administración
```

### 5. **Envío de Reportes**

```
POST /admin/send-report
Body JSON:
{
  "email": "destinatario@example.com"
}

Respuesta:
{
  "success": true,
  "message": "Reporte enviado correctamente a destinatario@example.com"
}
```

---

## 📦 Stack Tecnológico

### Backend
- **Python 3.11+** - Lenguaje de programación
- **Flask 2.3+** - Framework web ligero
- **PostgreSQL 12+** - Base de datos relacional
- **psycopg2** - Adaptador PostgreSQL
- **Flask-Mail** - Sistema de correos SMTP
- **Gunicorn** - WSGI server producción

### Frontend
- **HTML5** - Markup semántico
- **CSS3 Bootstrap 5.3** - Framework CSS responsivo
- **JavaScript** - Validación client-side
- **Font Awesome 6.4** - Iconografía

### DevOps & Infraestructura
- **Docker** - Containerización
- **Docker Compose** - Orquestación
- **Git/GitHub** - Control de versiones

---

## 🔐 Seguridad Implementada

### Medidas de Protección
- ✅ **Validación client-side** - JavaScript
- ✅ **Validación server-side** - Python/Flask
- ✅ **Escape de HTML** - Jinja2 templates
- ✅ **Protección XSS** - Plantillas seguras
- ✅ **Variables de entorno** - Secretos fuera del código
- ✅ **CORS y headers seguros**

### Mejores Prácticas
- Nunca guardar `.env` en repositorio
- Usar `.env.example` como template
- Contraseñas fuertes en producción
- HTTPS en deployments (recomendado)

---

## 🛠️ Troubleshooting

### Error: "password authentication failed for user 'admin'"

```bash
# Cambiar contraseña PostgreSQL
sudo -u postgres psql -c "ALTER USER admin PASSWORD 'admin123';"

# Reintentar
./run.sh dev
```

### Script de Diagnóstico

```bash
chmod +x troubleshoot.sh
./troubleshoot.sh
```

Verifica automáticamente Python, PostgreSQL, Docker y variables de entorno.

---

## 📖 Documentación Completa

| Documento | Descripción |
|-----------|-------------|
| [Docs_guia/QUICK_START.md](Docs_guia/QUICK_START.md) | Guía rápida de inicio |
| [Docs_guia/SCRIPTS.md](Docs_guia/SCRIPTS.md) | Referencia de scripts disponibles |
| [Docs_guia/DEPLOYMENT.md](Docs_guia/DEPLOYMENT.md) | Deployment a servidor remoto |
| [docs/IMPLEMENTACION.md](docs/IMPLEMENTACION.md) | Detalles técnicos de implementación |
| [docs/TESTING.md](docs/TESTING.md) | Guía de testing |
| [docs/POSTGRESQL_ERROR.md](docs/POSTGRESQL_ERROR.md) | Soluciones PostgreSQL |

---

## 📊 Resumen de Features Implementadas

| Feature | Estado | Descripción |
|---------|--------|-------------|
| Formulario Registro | ✅ Completo | Bilingüe, validado, responsivo |
| Almacenamiento BD | ✅ Completo | PostgreSQL con estructura completa |
| Panel Admin | ✅ Completo | Dashboard con estadísticas en tiempo real |
| API Estadísticas | ✅ Completo | Datos por comuna y carrera |
| Sistema Email | ✅ Completo | Envío de reportes HTML formateados |
| Docker | ✅ Completo | Containerizado y listo para producción |
| Validación | ✅ Completo | Client-side y server-side |
| Internacionalización | ✅ Completo | Soporte español/inglés |
| Scripts Automáticos | ✅ Completo | Setup, run, deploy, update |

---

## 👥 Autor

**Universidad EAFIT - Proyecto Final**  
Curso: Internet, Protocolos y Arquitectura  
Año: 2026

---

## 📄 Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles

---

## 🚀 Próximos Pasos

El proyecto está completamente funcional. Para llevar a producción:

1. **Configurar dominio** - Registrar dominio (Godaddy, Namecheap, etc.)
2. **Certificado SSL** - Let's Encrypt (gratis) o certificado comercial
3. **Hosting** - Desplegar en servidor remoto o cloud (AWS, Azure, DigitalOcean)
4. **Monitoreo** - Configurar logs y alertas
5. **Backups** - Establecer política de backups automáticos de BD

Ver plan completo: `/docs/PROGRESO.md`

---

## 🤝 Contribuir

### Para agregar cambios:

```bash
# 1. Crear rama
git checkout -b feature/mi-caracteristica

# 2. Hacer cambios
# ... editar archivos ...

# 3. Commit
git add .
git commit -m "Descripción clara del cambio"

# 4. Push
git push origin feature/mi-caracteristica

# 5. Pull Request
# Crear PR en GitHub
```

### Estándares de Código
- PEP 8 para Python
- ESLint para JavaScript
- HTML5 semántico

---

## 📞 Soporte y Contacto

**Institución:** Universidad EAFIT  
**Curso:** Internet, Protocolos y Arquitectura  
**Profesor:** [Nombre]  
**Equipo:** [Integrantes]

---

## 📄 Licencia

Proyecto educativo - Universidad EAFIT 2026

---

## 📋 Checklist de Arranque

Antes de comenzar a trabajar:

- [ ] Clonar repositorio
- [ ] Crear entorno virtual (`python3 -m venv venv`)
- [ ] Activar entorno (`source venv/bin/activate`)
- [ ] Instalar dependencias (`pip install -r requirements.txt`)
- [ ] Crear base de datos PostgreSQL
- [ ] Crear archivo `.env` con variables
- [ ] Ejecutar `python app.py`
- [ ] Acceder a http://localhost:5000/
- [ ] Verificar registro funciona
- [ ] Consultar datos en BD

---

## 🚀 Próximos Pasos

1. **Completar FASE 1:** Testing en navegadores
2. **FASE 2:** Implementar panel administrativo
3. **FASE 3:** Sistema de email y reportes
4. **FASE 4:** Segundo servidor web
5. **FASE 5:** NGINX load balancer
6. **FASE 6:** SSL/certificado y deploy

---

**Última actualización:** 21 de mayo de 2026  
**Versión:** 1.0.0-FASE1  
**Estado:** 🟡 En Desarrollo - 17% Completado
