# 🔄 OPCIONES DE SINCRONIZACIÓN: LOCAL → AWS

**Problema:** 
- Tú desarrollas localmente
- Compañera maneja AWS
- Necesitas que sea fácil y automático

---

## 🎯 COMPARATIVA DE OPCIONES

| Opción | Complejidad | Costo | Velocidad | Control | Recomendación |
|--------|-------------|-------|-----------|---------|---------------|
| **Git Pull Manual** | ⭐ Muy fácil | Gratis | Manual | Total | ❌ Lento |
| **Deploy Script** | ⭐ Fácil | Gratis | Manual | Total | ✅ Bueno |
| **Webhook + Script** | ⭐⭐ Media | Gratis | Semi-auto | Bueno | ⚠️ Intermedio |
| **GitHub Actions** | ⭐⭐⭐ Intermedia | Gratis | Automático | Total | ✅✅ MEJOR |

---

## ✅ OPCIÓN 1: Deploy Script Mejorado (RÁPIDA - Hoy)

### Flujo:
```
Tú (local)                          Compañera (AWS)
  ↓                                   ↑
git commit + git push          ← GitHub ←
  ↓                              ↑
  └──── ./quick-deploy.sh ────→ aws-server
         (ejecuta SSH)
```

### Cómo funciona:

**En tu máquina:**
```bash
# 1. Hacer cambios
nano web-app/templates/index_es.html

# 2. Commit y push
git add .
git commit -m "Mejorar interfaz"
git push

# 3. Ejecutar deploy
./quick-deploy.sh
```

**En el servidor AWS (lo hace automáticamente):**
```
git pull origin main
docker-compose restart
```

**Ventaja:** 
- ✅ Funciona YA
- ✅ Fácil para compañera (solo 1 comando)

**Desventaja:**
- ❌ Tienes que ejecutarlo manualmente cada vez

---

## ✅ OPCIÓN 2: GitHub Actions (MEJOR - Recomendado)

### Flujo (Completamente Automático):
```
Tú (local)                GitHub              AWS
  ↓                        ↓                   ↓
git commit
  ↓
git push
  ↓
GitHub detecta cambios
  ↓
Ejecuta workflow automáticamente
  ↓
SSH al servidor AWS
  ↓
git pull + docker-compose restart
  ↓
¡Actualizado! ✅
```

**Ventaja:**
- ✅ Totalmente automático
- ✅ Push = Deploy automático
- ✅ Tu compañera no hace nada
- ✅ Ideal para 48h de deadline

**Desventaja:**
- ⚠️ Necesita configurar 1 vez (15 min)

---

## 🚀 IMPLEMENTACIÓN: GitHub Actions (OPCIÓN 2)

### Paso 1: Crear archivo de workflow

**Crear archivo:** `.github/workflows/deploy.yml`

```yaml
name: Deploy a AWS

on:
  push:
    branches:
      - main
    paths:
      - 'web-app/**'
      - 'docker-compose.yml'
      - '.github/workflows/deploy.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: SSH a servidor AWS y actualizar
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.AWS_HOST }}
          username: ${{ secrets.AWS_USER }}
          key: ${{ secrets.AWS_SSH_KEY }}
          script: |
            cd ~/proyecto-final-internet
            git pull origin main
            docker-compose restart web-app-es web-app-en
            echo "✅ Deploy completado"
```

### Paso 2: Agregar secretos a GitHub

**En GitHub (web):**
```
1. Ir a: Repository → Settings → Secrets and variables → Actions
2. Crear 3 secretos:
   - AWS_HOST = IP pública del servidor (ej: 54.123.45.67)
   - AWS_USER = ubuntu (o usuario SSH)
   - AWS_SSH_KEY = (contenido de la clave privada SSH)
```

### Paso 3: Obtener la clave SSH

**En el servidor AWS (lo hace la compañera):**
```bash
# Mostrar la clave pública
cat ~/.ssh/id_rsa.pub

# La clave privada (para GitHub):
cat ~/.ssh/id_rsa

# Copiar TODO (incluyendo -----BEGIN RSA PRIVATE KEY-----)
```

### Paso 4: Listo. Ahora simplemente:

```bash
# En tu máquina:
git add .
git commit -m "Nueva interfaz"
git push

# ¡AUTOMÁTICAMENTE se deploya en AWS!
# Tu compañera no necesita hacer nada
```

---

## 🔧 IMPLEMENTACIÓN: Deploy Script (OPCIÓN 1)

Si quieres algo más simple para hoy, sin GitHub Actions:

**Crear archivo:** `quick-deploy.sh`

```bash
#!/bin/bash

echo "🚀 Iniciando deploy rápido..."

# Variables
AWS_HOST=${1:-"54.123.45.67"}  # Cambiar por IP real
AWS_USER=${2:-"ubuntu"}
SSH_KEY="~/.ssh/proyecto-aws.pem"

echo "📍 Conectando a: $AWS_USER@$AWS_HOST"

# Ejecutar comandos en AWS
ssh -i "$SSH_KEY" "$AWS_USER@$AWS_HOST" << 'EOF'
    echo "📂 Entrando al proyecto..."
    cd ~/proyecto-final-internet
    
    echo "📥 Descargando cambios..."
    git pull origin main
    
    echo "🐳 Reiniciando contenedores..."
    docker-compose restart web-app-es web-app-en
    
    echo "✅ Deploy completado!"
    echo "📊 Verificando estado..."
    docker-compose ps
EOF

echo "🎉 ¡Listo! Cambios en producción"
```

**Uso:**
```bash
chmod +x quick-deploy.sh

# Primera vez (especificando IP)
./quick-deploy.sh 54.123.45.67 ubuntu

# Próximas veces (si guardas la IP en script)
./quick-deploy.sh
```

---

## 💾 OPCIÓN RECOMENDADA PARA USTEDES

Dado que:
- ⏰ Tienen 2 DÍAS
- 👥 Dos personas trabajando
- 🔄 Necesitan sincronización constante

### ✅ RECOMENDACIÓN: GitHub Actions

**Por qué:**
1. Funciona automáticamente
2. Sin intervención de tu compañera
3. Cada push = actualización en AWS
4. Tú puedes iterar rápido sin coordinar

**Setup:** 15 minutos (hoy mismo)

---

## 📋 WORKFLOW RECOMENDADO

```
Lunes 25 (HOY):
  1. Configurar GitHub Actions (15 min)
  2. Tu compañera agrega SSH key a GitHub
  3. Hacer un test push para verificar

Martes 26:
  Tú desarrollas localmente
  git push cuando esté listo
  → Automáticamente se deploya
  Compañera verifica en navegador
  
Miércoles 27:
  Últimos ajustes
  Cada push = automático
  Sin coordinación manual

Jueves 28:
  Sustentación con versión final en AWS
```

---

## 🔐 SEGURIDAD

### Preocupaciones:
- ❌ ¿Mi SSH key en GitHub?
- ✅ SÍ, pero está SEGURA (GitHub la encripta)
- ✅ GitHub la usa solo en sus servidores
- ✅ Nunca la mostrará públicamente

### Best practices:
```bash
# 1. Usar una clave SSH específica para esto (no la de personal)
ssh-keygen -t ed25519 -f ~/.ssh/github-deploy -N ""

# 2. Agregar al servidor solo esta clave
# En AWS ~/.ssh/authorized_keys

# 3. Limitar permisos de la clave
# (solo acceso al directorio del proyecto)
```

---

## 🎯 PRÓXIMOS PASOS (ELIGE UNO)

### OPCIÓN A: GitHub Actions (Recomendado)
- [ ] Crear `.github/workflows/deploy.yml`
- [ ] Agregar secretos en GitHub
- [ ] Tu compañera da SSH key
- [ ] Test: hacer push y verificar

### OPCIÓN B: Deploy Script
- [ ] Crear `quick-deploy.sh`
- [ ] Configurar IP del servidor
- [ ] Ejecutar script después de cada cambio

### OPCIÓN C: Híbrida (Mejor de ambas)
- [ ] GitHub Actions para cambios pequeños
- [ ] Deploy script para rollback rápido si falla

---

## 📊 COMPARATIVA FINAL

### Sin implementar (ACTUAL):
```
Tú hace cambio → ?? → Compañera lo hace manual → Demora 30 min
```

### Con GitHub Actions:
```
Tú hace cambio → git push → Automático en 2 min → ✅ EN PRODUCCIÓN
```

### Con Deploy Script:
```
Tú hace cambio → git push → ./quick-deploy.sh → En producción en 5 min
```

---

## 🔧 CONFIGURACIÓN RÁPIDA DE GITHUB ACTIONS (YA)

Si quieres hacerlo HOY en 15 minutos:

```bash
cd ~/Escritorio/Internet_Protocolos_P.Final/proyecto-final-internet

# Crear carpeta de workflow
mkdir -p .github/workflows

# Crear archivo (yo te lo paso completo abajo)
nano .github/workflows/deploy.yml
```

---

## ⚙️ ARCHIVO COMPLETO: `.github/workflows/deploy.yml`

```yaml
name: 🚀 Deploy a AWS

on:
  push:
    branches:
      - main
    paths:
      - 'web-app/**'
      - 'docker-compose.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: 📥 Clonar repositorio
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: 🔐 Configurar SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.AWS_SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H ${{ secrets.AWS_HOST }} >> ~/.ssh/known_hosts

      - name: 📤 Descargar cambios en AWS
        run: |
          ssh -i ~/.ssh/id_rsa ${{ secrets.AWS_USER }}@${{ secrets.AWS_HOST }} << 'EOF'
            cd ~/proyecto-final-internet
            git fetch origin
            git reset --hard origin/main
            echo "✅ Cambios descargados"
          EOF

      - name: 🐳 Reiniciar contenedores
        run: |
          ssh -i ~/.ssh/id_rsa ${{ secrets.AWS_USER }}@${{ secrets.AWS_HOST }} << 'EOF'
            cd ~/proyecto-final-internet
            docker-compose pull
            docker-compose restart web-app-es web-app-en
            echo "✅ Contenedores reiniciados"
          EOF

      - name: ✅ Verificar deploy
        run: |
          ssh -i ~/.ssh/id_rsa ${{ secrets.AWS_USER }}@${{ secrets.AWS_HOST }} << 'EOF'
            docker-compose ps
            echo "🎉 Deploy completado exitosamente"
          EOF

      - name: 📧 Notificación (opcional)
        if: always()
        run: echo "Deploy completado - Ver en: https://proyectotelematica-kenia.duckdns.org"
```

---

## 📋 CHECKLIST DE CONFIGURACIÓN

- [ ] Crear carpeta `.github/workflows/`
- [ ] Crear archivo `deploy.yml` con contenido de arriba
- [ ] Ir a GitHub Settings → Secrets
- [ ] Agregar `AWS_HOST` (IP del servidor)
- [ ] Agregar `AWS_USER` (usuario SSH)
- [ ] Agregar `AWS_SSH_KEY` (clave privada SSH)
- [ ] Hacer un test: `git push`
- [ ] Verificar que se deployó automáticamente

---

## 🎯 MI RECOMENDACIÓN

**Para ustedes con 48h de deadline:**

### Hoy:
1. Implementar GitHub Actions (15 min)
2. Tu compañera configura SSH key (5 min)
3. Hacer test push (5 min)

### Resultado:
- ✅ Cada cambio que hagas se deploya automáticamente
- ✅ Tu compañera solo verifica en navegador
- ✅ Cero coordinación manual
- ✅ Perfecto para iteración rápida

**¿Comenzamos a configurarlo?**

