# 📋 EAFIT - Sistema de Registro de Estudiantes

**Proyecto Final - Curso Internet, Protocolos y Arquitectura**  
**Universidad EAFIT - 2026**

> Sistema de registro bilingüe (español/inglés) para potenciales estudiantes con interfaz moderna, validación robusta y panel administrativo.

---

## 🚀 Inicio Rápido (Quick Start)

### Requisitos Previos
- Python 3.11+
- PostgreSQL 12+
- pip (gestor de paquetes Python)
- Git

### Instalación en 3 Pasos (Automatizado)

```bash
# 1. Clonar repositorio
git clone https://github.com/Keniatv24/proyecto-final-internet.git
cd proyecto-final-internet

# 2. Setup automático (crea venv, instala dependencias)
chmod +x setup.sh
./setup.sh

# 3. Ejecutar
./run.sh dev
```

**Acceder:** http://localhost:5000/

> 💡 **Más opciones:** Ver [SCRIPTS.md](SCRIPTS.md) para todos los comandos disponibles

---

## 📝 Descripción del Proyecto

Sistema integral de registro y gestión de estudiantes para EAFIT con:

✅ **Formulario de Registro**
- Interfaz moderna con Bootstrap 5.3.0
- Validación client-side en JavaScript
- Bilingüe (Español/Inglés)
- Responsivo (mobile-first)
- Almacenamiento en PostgreSQL

✅ **Panel Administrativo** (En desarrollo - FASE 2)
- Dashboard con estadísticas
- Tabla de registros filtrable
- Gráficas con Chart.js

✅ **Sistema de Reportes** (En desarrollo - FASE 3)
- Reportes por correo electrónico
- Exportación de datos
- Estadísticas por carrera y zona

✅ **Infraestructura Escalable** (En desarrollo - FASE 4-6)
- 2 servidores web (español/inglés)
- Load balancer con NGINX
- SSL/TLS con certificado

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

# Email (para FASE 3)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=1
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-contraseña-aplicacion
```

### 2. Base de Datos PostgreSQL

```bash
# Conectar a PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE proyecto_final;

# Conectar a la BD
\c proyecto_final

# Crear tabla de registros
CREATE TABLE registros (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comuna INT NOT NULL CHECK (comuna >= 1 AND comuna <= 10),
    fecha_ingreso DATE NOT NULL,
    carrera VARCHAR(50) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

# Crear índices para mejora de rendimiento
CREATE INDEX idx_carrera ON registros(carrera);
CREATE INDEX idx_comuna ON registros(comuna);
CREATE INDEX idx_fecha ON registros(fecha_ingreso);

# Salir
\q
```

### 3. Configurar Flask App

Las variables de entorno se cargan automáticamente en `app.py`:

```python
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "proyecto_final")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "admin123")
LANGUAGE = os.getenv("LANGUAGE", "es")
```

---

## 📂 Estructura del Proyecto

```
proyecto-final-internet/
│
├── README.md (este archivo)
├── .gitignore
├── .git/
│
├── docs/
│   ├── PROGRESO.md          (Roadmap de 6 fases, 29 tareas)
│   ├── IMPLEMENTACION.md    (Detalles técnicos FASE 1)
│   ├── TESTING.md           (Guía de testing)
│   ├── Plan.md              (Requisitos iniciales)
│   └── image.png            (Diagrama/captura)
│
└── web-app/
    ├── app.py               (Aplicación Flask principal)
    ├── requirements.txt     (Dependencias Python)
    ├── Dockerfile           (Configuración Docker)
    ├── .env                 (Variables de entorno - NO SUBIR A GIT)
    │
    ├── templates/
    │   ├── index_es.html    (Formulario en español)
    │   ├── index_en.html    (Formulario en inglés)
    │   ├── admin_dashboard.html    (En desarrollo)
    │   ├── admin_registros.html    (En desarrollo)
    │   └── email_reporte.html      (En desarrollo)
    │
    ├── static/
    │   ├── css/
    │   │   └── style.css    (Estilos CSS - En desarrollo)
    │   └── js/
    │       ├── validacion.js        (Validaciones client-side)
    │       └── charts.js            (Gráficas - En desarrollo)
    │
    └── utils/
        └── reportes.py      (Utilidades de reportes - En desarrollo)
```

---

## 🚀 Deployment a Servidor Remoto

### Primer Deployment (Completo)

```bash
# 1. Configurar servidor (una sola vez)
chmod +x deploy.sh
cp .env.production.example .env.production
nano .env.production  # Editar con tu servidor y credenciales

# 2. Hacer deploy
./deploy.sh your-server.com ubuntu

# 3. Acceder
# http://your-server.com/
```

### Actualizaciones Posteriores (Rápidas)

```bash
# Para cambios en HTML/CSS/JS (2 minutos)
./update.sh your-server.com ubuntu

# O con .env.production configurado
./update.sh
```

### Con Docker (Alternativa)

```bash
# Desarrollo
docker-compose up

# Producción
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Para más detalles:** [DEPLOYMENT.md](DEPLOYMENT.md) | [SCRIPTS.md](SCRIPTS.md)

---

### Modo Desarrollo

```bash
cd web-app

# Activar entorno virtual
source venv/bin/activate

# Configurar variables
export FLASK_APP=app.py
export FLASK_ENV=development
export LANGUAGE=es

# Ejecutar
python app.py

# Acceder a:
# - Español: http://localhost:5000/
# - Inglés: http://localhost:5000/?lang=en
```

### Con Docker

```bash
# Construir imagen
docker build -t eafit-register:latest .

# Ejecutar contenedor
docker run -e LANGUAGE=es \
           -e DB_HOST=postgres \
           -p 5000:5000 \
           eafit-register:latest

# O con docker-compose (en FASE 4)
docker-compose up
```

### Modo Producción

```bash
# Usar Gunicorn en lugar de Flask development server
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

---

## 🧪 Testing

### Ejecutar Tests (Cuando estén listos)

```bash
# Instalar pytest
pip install pytest pytest-cov

# Ejecutar tests
pytest

# Con cobertura
pytest --cov=.
```

### Testing Manual

Ver guía completa en `/docs/TESTING.md`

**Checklist rápido:**
- [ ] Formulario valida campos correctamente
- [ ] Datos se guardan en BD
- [ ] Funciona en mobile (responsivo)
- [ ] Ambos idiomas funcionan
- [ ] Mensajes de error/éxito aparecen

---

## 🆘 Troubleshooting

### Error: "password authentication failed for user 'admin'"

Este es el error más común después de `setup.sh`. Significa que PostgreSQL está corriendo pero la contraseña no coincide.

**Solución rápida (2 minutos):**

```bash
# 1. Cambiar contraseña en PostgreSQL
sudo -u postgres psql -c "ALTER USER admin PASSWORD 'admin123';"

# 2. Ejecutar nuevamente
./run.sh dev
```

**Solución detallada:** Ver [POSTGRESQL_ERROR.md](POSTGRESQL_ERROR.md)

### Script de Diagnóstico Automático

Si tienes otros problemas, ejecuta:

```bash
chmod +x troubleshoot.sh
./troubleshoot.sh
```

Te mostrará exactamente qué está mal en tu configuración.

---

## 📚 Endpoints API

### Formulario de Registro

```
POST /
Parámetros:
  - nombre (text, requerido)
  - comuna (int 1-10, requerido)
  - fecha (date, requerido)
  - carrera (string: Medicina|Ingeniería|Abogacía|Licenciatura, requerido)

Respuesta:
  - 200: Registro exitoso + mensaje de éxito
  - 400: Error en validación + mensaje de error
```

### Health Check

```
GET /health
Respuesta: 200 OK
```

### Admin Dashboard (FASE 2)

```
GET /admin/dashboard
GET /api/statistics
GET /api/registros
POST /api/registros (crear)
PUT /api/registros/{id} (actualizar)
DELETE /api/registros/{id} (eliminar)
```

---

## 📦 Dependencias

```
Flask==2.3.0          # Framework web
psycopg2-binary==2.9  # Adaptador PostgreSQL
python-dotenv==1.0    # Variables de entorno
Flask-Mail==0.9.1     # Sistema de email (FASE 3)
PyPDF2==3.0.1         # Generación de PDF (FASE 3)
```

Ver archivo completo: `/web-app/requirements.txt`

---

## 🔐 Seguridad

### Medidas Implementadas
- ✅ Validación client-side (JavaScript)
- ✅ Validación server-side (recomendado agregar)
- ✅ Escape de caracteres especiales
- ✅ Protección contra XSS en templates Jinja2
- ⏳ CSRF protection (FASE 2)
- ⏳ SQL injection prevention (FASE 2)
- ⏳ Rate limiting (FASE 2)

### Variables Sensibles
**NUNCA** agregar al repositorio:
- `.env` (secretos de DB, email, etc.)
- `venv/` (entorno virtual)
- Credenciales AWS

Usar `.gitignore`:
```
venv/
.env
*.pyc
__pycache__/
.DS_Store
```

---

## 🎨 Tecnologías Utilizadas

### Frontend
- **HTML5** - Markup semántico
- **CSS3** - Estilos y animaciones
- **JavaScript** - Validación client-side
- **Bootstrap 5.3.0** - Framework CSS
- **Font Awesome 6.4.0** - Iconos
- **Chart.js** - Gráficas (FASE 2)

### Backend
- **Python 3.11** - Lenguaje
- **Flask** - Framework web
- **PostgreSQL** - Base de datos
- **Gunicorn** - WSGI server
- **Jinja2** - Motor de plantillas

### DevOps/Infraestructura
- **Docker** - Containerización
- **NGINX** - Load balancer (FASE 5)
- **Let's Encrypt** - SSL/TLS (FASE 6)
- **AWS Educate** - Hosting (FASE 6)

---

## 📊 Fases de Desarrollo

| Fase | Nombre | Estado | Tareas |
|------|--------|--------|--------|
| 1 | Mejorar Formulario | 🟡 En Progreso | 5/6 |
| 2 | Panel Administrativo | ⚪ No iniciada | 0/6 |
| 3 | Sistema Email | ⚪ No iniciada | 0/5 |
| 4 | Multi-servidor | ⚪ No iniciada | 0/4 |
| 5 | NGINX Load Balancer | ⚪ No iniciada | 0/4 |
| 6 | SSL/Certificado | ⚪ No iniciada | 0/4 |

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
