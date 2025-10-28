# 📦 Resumen de Configuración - Laravel API Backend

## ✅ Archivos Creados y Modificados

### 🐳 Docker
- ✓ `Dockerfile` - Optimizado para backend API (sin Node.js)
- ✓ `docker-compose.prod.yml` - Configuración para producción
- ✓ `.dockerignore` - Exclusiones para la imagen Docker

### 🔧 Scripts de Despliegue
- ✓ `deploy.sh` - Script automático de despliegue
- ✓ `check-system.sh` - Verificación de requisitos del sistema
- ✓ `scripts/manage.sh` - Menú interactivo de administración
- ✓ `scripts/test-api.sh` - Pruebas de conectividad y CORS

### 📝 Configuración Laravel
- ✓ `config/cors.php` - Configuración CORS actualizada
- ✓ `app/Http/Middleware/Cors.php` - Middleware CORS personalizado
- ✓ `routes/api.php` - Rutas de ejemplo y health check
- ✓ `.env.production.example` - Variables de entorno para producción

### 📚 Documentación
- ✓ `README.DEPLOY.md` - Guía completa de despliegue
- ✓ `INSTRUCCIONES_DESPLIEGUE.md` - Instrucciones paso a paso
- ✓ `RESUMEN_CONFIGURACION.md` - Este archivo

### 🎨 Ejemplos Angular
- ✓ `angular-example/api.service.ts` - Servicio completo para Angular
- ✓ `angular-example/environment.example.ts` - Configuración de environments
- ✓ `angular-example/app.component.example.ts` - Ejemplos de uso
- ✓ `angular-example/README.md` - Guía de integración Angular

---

## 🚀 Pasos para Despliegue en Ubuntu Server

### 1️⃣ En tu PC local (Windows)

```bash
# Subir cambios a Git
git add .
git commit -m "Configuración para despliegue en producción"
git push origin main
```

### 2️⃣ En el servidor Ubuntu (192.168.1.24)

```bash
# Conectarse al servidor
ssh usuario@192.168.1.24

# Clonar o actualizar el repositorio
git clone <tu-repositorio> /opt/laravel-api
cd /opt/laravel-api

# Verificar requisitos del sistema
bash check-system.sh

# Configurar variables de entorno
cp .env.production.example .env
nano .env  # Cambiar contraseñas

# Ejecutar despliegue automático
bash deploy.sh
```

### 3️⃣ Verificar instalación

```bash
# Desde el servidor
curl http://localhost:8000/api/health
curl http://192.168.1.24:8000/api/health

# Desde otra máquina en la red
curl http://192.168.1.24:8000/api/health
```

### 4️⃣ Configurar Angular

En tu proyecto Angular, actualiza `environment.ts`:

```typescript
export const environment = {
  production: true,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

---

## 🔑 Cambios Importantes Realizados

### ✨ Dockerfile Optimizado
- ❌ Eliminado Node.js (no necesario para API backend)
- ✅ Agregado módulo headers de Apache para CORS
- ✅ Configuración CORS directamente en Apache
- ✅ Health check para monitoreo
- ✅ Optimizado para producción

### 🌐 CORS Configurado
- ✅ Permite peticiones desde cualquier origen
- ✅ Soporta todos los métodos HTTP (GET, POST, PUT, DELETE, PATCH, OPTIONS)
- ✅ Headers personalizados permitidos
- ✅ Manejo de preflight requests (OPTIONS)
- ✅ Configurado en 3 niveles:
  1. Apache (Dockerfile)
  2. Laravel CORS config (config/cors.php)
  3. Middleware personalizado (app/Http/Middleware/Cors.php)

### 🔒 Seguridad
- ✅ Firewall UFW configurado automáticamente
- ✅ MySQL y Redis solo accesibles localmente
- ✅ API expuesta en puerto 8000
- ✅ Logs configurados correctamente
- ⚠️ Contraseñas predeterminadas (CAMBIARLAS en .env)

### 📊 Monitoreo
- ✅ Health check endpoint: `/api/health`
- ✅ Test endpoint: `/api/test`
- ✅ Logs accesibles vía Docker
- ✅ Health check automático de Docker

---

## 🎯 URLs del Sistema

### Backend API
- **URL Base:** `http://192.168.1.24:8000`
- **API Base:** `http://192.168.1.24:8000/api`
- **Health Check:** `http://192.168.1.24:8000/api/health`
- **Test CORS:** `http://192.168.1.24:8000/api/test`

### Frontend Angular (cuando lo despliegues)
- **URL:** `http://192.168.1.24:4200`

---

## 📋 Comandos Útiles

### Administración Interactiva
```bash
cd /opt/laravel-api
bash scripts/manage.sh
```

### Comandos Directos
```bash
# Ver logs
docker logs -f laravel_api_backend

# Ver estado
docker-compose -f docker-compose.prod.yml ps

# Reiniciar
docker-compose -f docker-compose.prod.yml restart

# Entrar al contenedor
docker exec -it laravel_api_backend bash

# Ejecutar Artisan
docker exec laravel_api_backend php artisan migrate
docker exec laravel_api_backend php artisan cache:clear

# Ver logs de Laravel
docker exec laravel_api_backend tail -f storage/logs/laravel.log

# Backup de base de datos
docker exec laravel_api_db mysqldump -u laravel -p laravel > backup.sql
```

### Probar API
```bash
# Usando script
bash scripts/test-api.sh

# Manual
curl http://192.168.1.24:8000/api/health
curl http://192.168.1.24:8000/api/test
```

---

## 🔧 Configuraciones por IP

Si tu servidor tiene una IP diferente a 192.168.1.24, actualiza estos archivos:

1. **docker-compose.prod.yml**
   ```yaml
   environment:
     - APP_URL=http://TU_IP:8000
   ```

2. **.env**
   ```env
   APP_URL=http://TU_IP:8000
   FRONTEND_URL=http://TU_IP:4200
   ```

3. **Angular environment.ts**
   ```typescript
   apiUrl: 'http://TU_IP:8000/api'
   ```

---

## 🐛 Solución de Problemas Comunes

### ❌ No puedo conectar desde Angular

**Verificaciones:**
```bash
# 1. Backend está corriendo
docker ps | grep laravel_api_backend

# 2. Puerto abierto en firewall
sudo ufw status
sudo ufw allow 8000/tcp

# 3. Probar desde el servidor
curl http://localhost:8000/api/health

# 4. Probar desde la red
curl http://192.168.1.24:8000/api/health

# 5. Ver logs
docker logs laravel_api_backend
```

### ❌ Error de base de datos

```bash
# Ver logs de MySQL
docker logs laravel_api_db

# Verificar conexión
docker exec laravel_api_backend php artisan tinker
>>> DB::connection()->getPdo();

# Recrear base de datos
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d
docker exec laravel_api_backend php artisan migrate --force
```

### ❌ Permisos denegados

```bash
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/storage
docker exec laravel_api_backend chmod -R 775 /var/www/html/storage
docker exec laravel_api_backend chmod -R 775 /var/www/html/bootstrap/cache
```

### ❌ CORS aún bloqueado

```bash
# Verificar CORS headers
curl -X OPTIONS http://192.168.1.24:8000/api/test \
  -H "Origin: http://192.168.1.24:4200" \
  -H "Access-Control-Request-Method: GET" \
  -v

# Limpiar caché de Laravel
docker exec laravel_api_backend php artisan config:clear
docker exec laravel_api_backend php artisan cache:clear
docker-compose -f docker-compose.prod.yml restart
```

---

## 📊 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│              Servidor Ubuntu (192.168.1.24)                  │
│                                                              │
│  ┌───────────────────┐              ┌──────────────────┐    │
│  │   Angular App     │──── HTTP ───▶│  Laravel API     │    │
│  │   :4200          │   Peticiones  │  :8000          │    │
│  └───────────────────┘              └────────┬─────────┘    │
│                                              │               │
│                                      ┌───────▼──────┐        │
│                                      │   MySQL DB   │        │
│                                      │   :3306      │        │
│                                      └──────────────┘        │
│                                                              │
│                                      ┌──────────────┐        │
│                                      │  Redis       │        │
│                                      │  :6379       │        │
│                                      └──────────────┘        │
└─────────────────────────────────────────────────────────────┘

Desde otra PC en la red (ej: 192.168.1.100):
  Browser → http://192.168.1.24:4200 (Angular)
              ↓
         http://192.168.1.24:8000/api (Laravel)
```

---

## ✅ Checklist de Despliegue

Antes de comenzar:
- [ ] Git instalado en el servidor
- [ ] Acceso SSH al servidor
- [ ] Puerto 8000 disponible
- [ ] Al menos 2GB de RAM
- [ ] 10GB de espacio en disco

Durante el despliegue:
- [ ] Código subido a Git
- [ ] Clonado en `/opt/laravel-api`
- [ ] Variables de entorno configuradas (`.env`)
- [ ] Contraseñas cambiadas
- [ ] Script `deploy.sh` ejecutado
- [ ] Contenedores corriendo (`docker ps`)

Verificación:
- [ ] Health check funciona
- [ ] Firewall configurado
- [ ] Logs sin errores
- [ ] Base de datos conectada
- [ ] CORS funcionando

Angular:
- [ ] Environment configurado con IP correcta
- [ ] HttpClientModule importado
- [ ] ApiService copiado
- [ ] Peticiones funcionando

---

## 🎉 ¡Todo Listo!

Tu backend Laravel está completamente configurado para:
- ✅ Funcionar como API REST
- ✅ Aceptar peticiones desde Angular
- ✅ Correr en Docker en Ubuntu
- ✅ Ser accesible desde la red local (192.168.1.24:8000)
- ✅ Manejo de CORS correcto
- ✅ Fácil administración y monitoreo

### Próximos Pasos:

1. **Subir código a Git** desde tu PC Windows
2. **Conectar al servidor Ubuntu** vía SSH
3. **Ejecutar `deploy.sh`** y esperar 5-10 minutos
4. **Configurar Angular** con la IP del servidor
5. **Probar las peticiones** desde Angular

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs: `docker logs -f laravel_api_backend`
2. Ejecuta: `bash scripts/test-api.sh`
3. Verifica: `bash check-system.sh`
4. Usa el menú: `bash scripts/manage.sh`

---

**Última actualización:** Octubre 2025
**IP del Servidor:** 192.168.1.24
**Puerto API:** 8000

