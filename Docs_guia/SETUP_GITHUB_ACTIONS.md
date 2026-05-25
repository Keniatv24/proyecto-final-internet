# ⚙️ GUÍA: Configurar GitHub Actions (15 minutos)

**Objetivo:** Cada vez que hagas `git push`, automáticamente se deploya en AWS

---

## 📋 REQUISITOS PREVIOS

- ✅ Repositorio en GitHub (ya lo tienen)
- ✅ Instancias AWS configuradas (ya existen)
- ✅ SSH key para acceder a AWS (la compañera debe tenerla)

---

## 🚀 PASO 1: PREPARAR LA CLAVE SSH (Compañera - 5 minutos)

La compañera debe hacer esto EN EL SERVIDOR AWS:

### 1.1 Conectarse al servidor
```bash
ssh -i clave.pem ubuntu@54.123.45.67
```

### 1.2 Verificar que existe clave SSH
```bash
cat ~/.ssh/id_rsa.pub
```

Si NO existe, crearla:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa -N ""
```

### 1.3 Mostrar la clave PRIVADA (necesaria para GitHub)
```bash
cat ~/.ssh/id_rsa
```

**⚠️ IMPORTANTE:** Copiar TODO incluyendo:
- `-----BEGIN OPENSSH PRIVATE KEY-----`
- (todas las líneas del medio)
- `-----END OPENSSH PRIVATE KEY-----`

---

## 🔐 PASO 2: AGREGAR SECRETOS A GITHUB (Tú - 10 minutos)

### 2.1 Ir a la página de GitHub del repositorio

```
https://github.com/Keniatv24/proyecto-final-internet
```

### 2.2 Settings → Secrets and variables → Actions

Navegación:
1. Click en **Settings** (pestaña superior)
2. Click en **Secrets and variables** (izquierda)
3. Click en **Actions**

### 2.3 Crear Secreto 1: `AWS_HOST`

```
Name: AWS_HOST
Value: 54.123.45.67  (IP pública del servidor)
```

Luego **Add secret**

### 2.4 Crear Secreto 2: `AWS_USER`

```
Name: AWS_USER
Value: ubuntu  (o el usuario SSH que uses)
```

Luego **Add secret**

### 2.5 Crear Secreto 3: `AWS_SSH_KEY`

```
Name: AWS_SSH_KEY
Value: (PEGA AQUÍ la clave privada completa de la compañera)
```

⚠️ Pegar la salida COMPLETA de `cat ~/.ssh/id_rsa`

Luego **Add secret**

---

## 📁 PASO 3: CREAR EL ARCHIVO DE WORKFLOW (Tú - En local)

### 3.1 Crear carpeta
```bash
mkdir -p .github/workflows
```

### 3.2 Crear archivo `deploy.yml`

El archivo YA está creado en el repositorio: `.github/workflows/deploy.yml`

Solo verifica que existe:
```bash
ls -la .github/workflows/deploy.yml
```

Debe mostrar algo como:
```
-rw-r--r-- 1 usuario grupo 2000 May 25 10:30 .github/workflows/deploy.yml
```

### 3.3 Si no existe, crear manualmente

```bash
nano .github/workflows/deploy.yml
```

Pega el contenido del archivo que ya creé (está arriba en SYNC_OPTIONS.md)

---

## ✅ PASO 4: HACER UN TEST PUSH

### 4.1 Commit del workflow
```bash
git add .github/workflows/deploy.yml
git commit -m "Agregar GitHub Actions para deploy automático"
git push
```

### 4.2 Verificar que funcionó

Ve a GitHub y verifica:
```
https://github.com/Keniatv24/proyecto-final-internet/actions
```

Debería haber un workflow ejecutándose. Espera a que termine (2-3 minutos).

**Resultado esperado:**
- ✅ Commit aparece en "Actions"
- ✅ Workflow dice "Deploy Automático a AWS"
- ✅ Status: ✅ Completed successfully

---

## 🎯 PASO 5: VERIFICAR QUE SE DEPLOYÓ

### 5.1 Verificar en AWS
```bash
ssh -i clave.pem ubuntu@54.123.45.67

cd ~/proyecto-final-internet
git log --oneline -1
```

Debe mostrar el commit que acabas de hacer.

### 5.2 Verificar en navegador
```
https://proyectotelematica-kenia.duckdns.org
```

Debe estar actualizado con tus cambios.

---

## 🚀 PASO 6: AHORA A USAR NORMALMENTE

Después de configurar, el workflow es AUTOMÁTICO:

```bash
# Hacer cambios localmente
nano web-app/templates/index_es.html

# Commit y push (como siempre)
git add .
git commit -m "Mejorar interfaz española"
git push

# ¡AUTOMÁTICAMENTE se deploya en AWS!
# La compañera solo verifica en navegador

# Ver progreso:
# https://github.com/Keniatv24/proyecto-final-internet/actions
```

---

## 🐛 TROUBLESHOOTING

### Error 1: "Permission denied (publickey)"

**Causa:** La clave SSH no es correcta

**Solución:**
1. Verificar que la clave privada está completa en el secreto
2. Verificar que la clave pública está en `~/.ssh/authorized_keys` del servidor

### Error 2: "Connection timed out"

**Causa:** IP del servidor es incorrecta o no es accesible

**Solución:**
1. Verificar que `AWS_HOST` tiene la IP pública correcta
2. Verificar que el puerto 22 (SSH) está abierto en Security Group

### Error 3: "git fetch origin main: not found"

**Causa:** Branch se llama diferente

**Solución:**
1. Ver qué rama está usando: `git branch`
2. Si es "develop" o "master", actualizar el workflow

### Ver logs detallados

En GitHub Actions, click en el workflow → Click en el job → Ver los logs completos

---

## 📊 COMPARATIVA: ANTES vs DESPUÉS

### ANTES (Sin GitHub Actions):
```
Tú hace cambio → Compañera ejecuta script → Esperar → Deploy
(Coordinación manual, demora 30+ min)
```

### DESPUÉS (Con GitHub Actions):
```
Tú hace cambio → git push → AUTOMÁTICO → Deploy en 2-3 min
(Sin coordinación, todo automático)
```

---

## ✨ RESUMEN RÁPIDO

### Configuración inicial (1 vez):
1. ✅ Compañera prepara SSH key
2. ✅ Tú agregas 3 secretos en GitHub
3. ✅ Archivo `.github/workflows/deploy.yml` ya existe
4. ✅ Hacer test push

### Uso diario:
```bash
git add .
git commit -m "Tu cambio"
git push
# ¡Listo! Se deploya automáticamente
```

---

## 🎯 PRÓXIMAS ACCIONES

- [ ] Compañera prepara SSH key (`cat ~/.ssh/id_rsa`)
- [ ] Tú agregas 3 secretos en GitHub Settings
- [ ] Hacer test push (cambio simple)
- [ ] Verificar que llegó a AWS
- [ ] ¡A desarrollar el resto del proyecto!

---

**¿Preguntas? Revisa "SYNC_OPTIONS.md" para más contexto**
