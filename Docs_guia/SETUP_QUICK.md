# ⚡ SETUP RÁPIDO (5 MINUTOS VISUALES)

**Tú y tu compañera necesitan 5 minutos de coordinación**

---

## 🎯 PASO 1: COMPAÑERA PREPARA CLAVE (2 minutos)

En la terminal del SERVIDOR AWS:

```bash
ssh -i clave.pem ubuntu@54.123.45.67
```

Luego ejecutar:
```bash
cat ~/.ssh/id_rsa
```

**Copiar TODO** (incluyendo `-----BEGIN...-----` y `-----END...-----`)

✅ **La compañera te pasa este texto por Slack/WhatsApp/Email**

---

## 🔐 PASO 2: TÚ AGREGAS SECRETOS A GITHUB (3 minutos)

### Link del repositorio:
```
https://github.com/Keniatv24/proyecto-final-internet
```

### Ruta: Settings → Secrets and variables → Actions

Crear 3 secretos:

| Nombre | Valor |
|--------|-------|
| `AWS_HOST` | `54.123.45.67` (IP del servidor) |
| `AWS_USER` | `ubuntu` |
| `AWS_SSH_KEY` | (La clave que te pasó la compañera) |

**Para cada uno:** Click "New repository secret" → Copiar dato → "Add secret"

---

## ✅ PASO 3: VERIFICAR QUE FUNCIONA

Hacer cambio pequeño y push:

```bash
git add .
git commit -m "Test GitHub Actions"
git push
```

Ir a: https://github.com/Keniatv24/proyecto-final-internet/actions

Debe haber ✅ o ❌ de tu push.

Si es ✅ → **¡ÉXITO!** Está todo configurado

Si es ❌ → Click para ver qué falló

---

## 🚀 AHORA ES AUTOMÁTICO

```bash
# Cada vez que hagas:
git push

# Automáticamente se deploya en AWS
# Sin que la compañera haga nada
```

---

## 📋 VALORES EXACTOS (REEMPLAZA)

```
IP del servidor:   54.123.45.67       ← CAMBIAR
Usuario SSH:       ubuntu             ← CAMBIAR SI ES DIFERENTE
Clave SSH privada: [COPIAR COMPLETA]  ← CAMBIAR (DE LA COMPAÑERA)
```

---

## 🆘 Si No Funciona

### Opción A: Usar Deploy Script
```bash
chmod +x quick-deploy.sh
./quick-deploy.sh 54.123.45.67 ubuntu ~/.ssh/proyecto-aws.pem
```

### Opción B: Ver logs de GitHub Actions
https://github.com/Keniatv24/proyecto-final-internet/actions
→ Click en el workflow que falló
→ Ver qué dice el error

### Opción C: Contactar compañera
"¿Puedes verificar que la clave pública está en authorized_keys?"

```bash
# En el servidor
cat ~/.ssh/authorized_keys
```

---

**¿Listo? Entonces a configurar y empezar el desarrollo de interfaz! 🚀**
