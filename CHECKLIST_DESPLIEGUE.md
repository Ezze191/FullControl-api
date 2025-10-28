# ✅ Checklist de Despliegue - Laravel API Backend

## 📦 Fase 1: Preparación (En tu PC Windows)

- [ ] **1.1** - Revisar que todos los archivos de configuración estén creados
  - [ ] `Dockerfile`
  - [ ] `docker-compose.prod.yml`
  - [ ] `.env.production.example`
  - [ ] `deploy.sh`
  - [ ] Scripts en `/scripts`

- [ ] **1.2** - Verificar configuración de IP
  - [ ] IP correcta en `docker-compose.prod.yml` (192.168.1.24)
  - [ ] IP correcta en `.env.production.example`
  - [ ] IP correcta en archivos de ejemplo de Angular

- [ ] **1.3** - Revisar y actualizar rutas API
  - [ ] Endpoints definidos en `routes/api.php`
  - [ ] Controladores creados si es necesario
  - [ ] Migraciones listas

- [ ] **1.4** - Subir código a Git
  ```bash
  git add .
  git commit -m "Configuración para producción con Docker"
  git push origin main
  ```

---

## 🖥️ Fase 2: Preparación del Servidor Ubuntu

- [ ] **2.1** - Conectarse al servidor
  ```bash
  ssh usuario@192.168.1.24
  ```

- [ ] **2.2** - Actualizar el sistema
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

- [ ] **2.3** - Instalar Git (si no está instalado)
  ```bash
  sudo apt install git -y
  ```

- [ ] **2.4** - Verificar espacio en disco (mínimo 10GB)
  ```bash
  df -h
  ```

- [ ] **2.5** - Verificar RAM (mínimo 2GB)
  ```bash
  free -h
  ```

---

## 📥 Fase 3: Clonar y Configurar

- [ ] **3.1** - Crear directorio y clonar
  ```bash
  sudo mkdir -p /opt/laravel-api
  sudo chown $USER:$USER /opt/laravel-api
  git clone <URL_TU_REPOSITORIO> /opt/laravel-api
  cd /opt/laravel-api
  ```

- [ ] **3.2** - Ejecutar verificación del sistema
  ```bash
  bash check-system.sh
  ```
  - [ ] Todos los checks en verde o amarillo (no rojo crítico)

- [ ] **3.3** - Configurar variables de entorno
  ```bash
  cp .env.production.example .env
  nano .env
  ```

- [ ] **3.4** - Cambiar contraseñas en `.env`
  - [ ] `DB_PASSWORD` cambiada
  - [ ] `REDIS_PASSWORD` cambiada
  - [ ] `APP_URL` con IP correcta

- [ ] **3.5** - Dar permisos de ejecución a scripts
  ```bash
  chmod +x deploy.sh check-system.sh
  chmod +x scripts/*.sh
  ```

---

## 🚀 Fase 4: Despliegue

- [ ] **4.1** - Ejecutar script de despliegue
  ```bash
  bash deploy.sh
  ```
  
- [ ] **4.2** - Esperar a que termine (5-10 minutos)
  - [ ] Docker instalado
  - [ ] Docker Compose instalado
  - [ ] Contenedores construidos
  - [ ] Contenedores iniciados
  - [ ] Migraciones ejecutadas

- [ ] **4.3** - Verificar contenedores corriendo
  ```bash
  docker ps
  ```
  Deberías ver:
  - [ ] `laravel_api_backend` (corriendo)
  - [ ] `laravel_api_db` (corriendo)
  - [ ] `laravel_api_redis` (corriendo)

- [ ] **4.4** - Verificar logs sin errores críticos
  ```bash
  docker logs laravel_api_backend | tail -20
  ```

---

## 🧪 Fase 5: Verificación

- [ ] **5.1** - Probar health check desde el servidor
  ```bash
  curl http://localhost:8000/api/health
  ```
  **Respuesta esperada:**
  ```json
  {
    "status": "ok",
    "message": "API is running",
    "timestamp": "...",
    "environment": "production"
  }
  ```

- [ ] **5.2** - Probar desde la IP del servidor
  ```bash
  curl http://192.168.1.24:8000/api/health
  ```

- [ ] **5.3** - Probar endpoint de test
  ```bash
  curl http://192.168.1.24:8000/api/test
  ```

- [ ] **5.4** - Ejecutar pruebas completas
  ```bash
  bash scripts/test-api.sh
  ```
  - [ ] Health check ✅
  - [ ] CORS Preflight ✅
  - [ ] Test endpoint ✅

- [ ] **5.5** - Verificar firewall
  ```bash
  sudo ufw status
  ```
  - [ ] Puerto 8000 abierto
  - [ ] Puerto 22 (SSH) abierto

---

## 🔥 Fase 6: Configuración de Firewall

- [ ] **6.1** - Habilitar UFW si no está activo
  ```bash
  sudo ufw enable
  ```

- [ ] **6.2** - Permitir SSH (¡IMPORTANTE!)
  ```bash
  sudo ufw allow 22/tcp
  ```

- [ ] **6.3** - Permitir puerto de API
  ```bash
  sudo ufw allow 8000/tcp
  ```

- [ ] **6.4** - Permitir puerto de Angular (si aplica)
  ```bash
  sudo ufw allow 4200/tcp
  ```

- [ ] **6.5** - Verificar estado
  ```bash
  sudo ufw status numbered
  ```

---

## 🎨 Fase 7: Configurar Angular (En tu PC)

- [ ] **7.1** - Copiar servicio API
  ```bash
  cp angular-example/api.service.ts src/app/services/
  ```

- [ ] **7.2** - Configurar environment.ts
  ```typescript
  export const environment = {
    production: false,
    apiUrl: 'http://192.168.1.24:8000/api'
  };
  ```

- [ ] **7.3** - Configurar environment.prod.ts
  ```typescript
  export const environment = {
    production: true,
    apiUrl: 'http://192.168.1.24:8000/api'
  };
  ```

- [ ] **7.4** - Importar HttpClientModule
  ```typescript
  // app.module.ts
  import { HttpClientModule } from '@angular/common/http';
  
  imports: [
    HttpClientModule
  ]
  ```

- [ ] **7.5** - Probar conexión desde Angular
  ```typescript
  this.apiService.healthCheck().subscribe(
    response => console.log('✅ Backend conectado:', response),
    error => console.error('❌ Error:', error)
  );
  ```

---

## 🌐 Fase 8: Pruebas desde Otra Máquina

- [ ] **8.1** - Desde otra PC en la red (ej: 192.168.1.100)
  ```bash
  curl http://192.168.1.24:8000/api/health
  ```

- [ ] **8.2** - Desde el navegador
  - Abrir: `http://192.168.1.24:8000/api/health`
  - [ ] Respuesta JSON visible

- [ ] **8.3** - Probar CORS desde consola del navegador
  ```javascript
  fetch('http://192.168.1.24:8000/api/test')
    .then(res => res.json())
    .then(data => console.log('✅ CORS OK:', data))
    .catch(err => console.error('❌ CORS Error:', err));
  ```

---

## 🔄 Fase 9: Mantenimiento Post-Despliegue

- [ ] **9.1** - Cambiar contraseñas predeterminadas
  - [ ] Password de MySQL
  - [ ] Password de Redis
  - [ ] Regenerar APP_KEY si es necesario

- [ ] **9.2** - Configurar backup automático (opcional)
  ```bash
  # Agregar a crontab
  crontab -e
  # Agregar línea para backup diario a las 2 AM:
  # 0 2 * * * cd /opt/laravel-api && bash scripts/backup.sh
  ```

- [ ] **9.3** - Crear usuario no-root para administración (recomendado)

- [ ] **9.4** - Documentar credenciales de forma segura

- [ ] **9.5** - Probar que Angular puede hacer todas las operaciones
  - [ ] GET
  - [ ] POST
  - [ ] PUT
  - [ ] DELETE

---

## 📝 Fase 10: Documentación del Equipo

- [ ] **10.1** - Compartir URLs con el equipo
  - API Base: `http://192.168.1.24:8000/api`
  - Health Check: `http://192.168.1.24:8000/api/health`

- [ ] **10.2** - Compartir credenciales de forma segura

- [ ] **10.3** - Documentar endpoints disponibles

- [ ] **10.4** - Crear documentación de API (opcional)
  - Usar Postman
  - Usar Swagger/OpenAPI

---

## 🎉 ¡Completado!

Si has marcado todos los items anteriores, ¡tu backend está listo para producción!

### Comandos útiles para recordar:

```bash
# Ver logs
docker logs -f laravel_api_backend

# Reiniciar servicios
cd /opt/laravel-api
docker-compose -f docker-compose.prod.yml restart

# Menú de administración
bash scripts/manage.sh

# Backup de base de datos
docker exec laravel_api_db mysqldump -u laravel -p laravel > backup.sql

# Ver estado
docker ps
```

---

## 🆘 Si algo salió mal...

### Reiniciar desde cero:

```bash
# Detener y eliminar todo
cd /opt/laravel-api
docker-compose -f docker-compose.prod.yml down -v

# Limpiar Docker
docker system prune -af

# Volver a ejecutar
bash deploy.sh
```

### Ver logs de errores:

```bash
# Logs de Laravel
docker exec laravel_api_backend tail -f storage/logs/laravel.log

# Logs de Apache
docker exec laravel_api_backend tail -f /var/log/apache2/error.log

# Logs de MySQL
docker logs laravel_api_db
```

### Pedir ayuda:

1. Ejecuta: `bash scripts/test-api.sh`
2. Copia el output completo
3. Revisa `README.DEPLOY.md` sección "Solución de Problemas"

---

**Fecha de despliegue:** _______________
**Desplegado por:** _______________
**IP del Servidor:** 192.168.1.24
**Puerto API:** 8000

✅ = Completado | ⏸️ = En proceso | ❌ = Pendiente

