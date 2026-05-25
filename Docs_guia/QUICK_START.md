# ⚡ QUICK START - Comienza en 5 Minutos

## 1️⃣ Clonar y Navegar

```bash
git clone https://github.com/Keniatv24/proyecto-final-internet.git
cd proyecto-final-internet
```

## 2️⃣ Entorno Virtual

```bash
# Linux/Mac
python3 -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate
```

## 3️⃣ Instalar Dependencias

```bash
pip install -r web-app/requirements.txt
```

## 4️⃣ Configurar Base de Datos

### Opción A: PostgreSQL Local

```bash
# Iniciar PostgreSQL
# En Linux:
sudo systemctl start postgresql

# En Mac con Homebrew:
brew services start postgresql

# En Windows: iniciar el servicio desde Servicios
```

```bash
# Crear base de datos
psql -U postgres

# En la terminal de PostgreSQL:
CREATE DATABASE proyecto_final;
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

### Opción B: PostgreSQL con Docker

```bash
docker run -d \
  --name postgres-eafit \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=proyecto_final \
  -p 5432:5432 \
  postgres:15

# Luego ejecutar las queries de creación de tabla
```

## 5️⃣ Configurar Variables de Entorno

```bash
cd web-app

# Copiar archivo de ejemplo
cp ../.env.example .env

# Editar .env con tus valores (si usas defaults, está listo)
# Importante: DB_PASSWORD y DB_USER deben coincidir con PostgreSQL
```

## 6️⃣ Ejecutar la Aplicación

```bash
# Desde web-app/
python app.py

# O con más control:
export FLASK_APP=app.py
export FLASK_ENV=development
export LANGUAGE=es
python app.py
```

## 7️⃣ Acceder

Abre tu navegador:

```
Español: http://localhost:5000/
Inglés:  http://localhost:5000/?lang=en
```

## ✅ Listo!

Deberías ver:
- ✅ Formulario con Bootstrap moderno
- ✅ 4 campos (Nombre, Comuna, Fecha, Carrera)
- ✅ Validación en JavaScript
- ✅ Mensajes de error/éxito

---

## 🆘 Troubleshooting Rápido

### Error: "password authentication failed for user 'admin'"

```bash
# Solución en 1 línea:
sudo -u postgres psql -c "ALTER USER admin PASSWORD 'admin123';"

# Luego:
./run.sh dev
```

### Error: "ModuleNotFoundError: No module named 'flask'"
```bash
# Verificar que el entorno virtual está activado
source venv/bin/activate  # Linux/Mac
# O
venv\Scripts\activate  # Windows

# Reinstalar dependencias
pip install -r web-app/requirements.txt
```

### Error: "could not connect to server: Connection refused"
```bash
# Verificar que PostgreSQL está corriendo
# Linux:
sudo systemctl status postgresql

# Verificar puerto (default 5432)
lsof -i :5432

# Iniciar si no está corriendo
sudo systemctl start postgresql
```

### Error: "database 'proyecto_final' does not exist"
```bash
# Crear la base de datos
psql -U postgres -c "CREATE DATABASE proyecto_final;"
```

### Error: "FATAL: password authentication failed for user 'admin'"
```bash
# Verificar que DB_USER y DB_PASSWORD en .env coinciden con PostgreSQL
# O cambiar el usuario en PostgreSQL:
psql -U postgres
ALTER USER admin PASSWORD 'admin123';
\q
```

### El formulario no valida
```bash
# Verificar que JavaScript está habilitado en el navegador
# Abrir DevTools (F12) y revisar Console para errores
```

---

## 🗂️ Archivos Clave

| Archivo | Propósito |
|---------|-----------|
| `web-app/app.py` | Aplicación Flask (backend) |
| `web-app/templates/index_es.html` | Formulario español |
| `web-app/templates/index_en.html` | Formulario inglés |
| `web-app/static/js/validacion.js` | Validación JavaScript |
| `.env` | Variables de entorno (crear desde .env.example) |
| `README.md` | Documentación completa |
| `docs/PROGRESO.md` | Roadmap de desarrollo |

---

## 📝 Próximos Pasos

1. **Probar formulario** - Verificar que funciona
2. **Ver datos en BD** - `SELECT * FROM registros;`
3. **Testing** - Seguir guía en `docs/TESTING.md`
4. **FASE 2** - Panel administrativo

---

## 🚀 Comandos Útiles

```bash
# Ver logs en tiempo real
tail -f logs/app.log

# Resetear base de datos (CUIDADO!)
dropdb -U postgres proyecto_final
createdb -U postgres proyecto_final
# Y recrear tabla

# Consultar registros
psql -U admin -d proyecto_final -c "SELECT * FROM registros;"

# Salir del entorno virtual
deactivate

# Congelar dependencias actuales
pip freeze > requirements.txt
```

---

**¿Dudas?** Ver `README.md` para documentación completa.

**¿Errores?** Revisar `docs/TESTING.md` para debugging.

¡A programar! 🎉
