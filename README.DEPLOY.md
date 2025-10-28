# 🚀 Guía de Despliegue - Laravel API Backend

## 📋 Requisitos del Servidor Ubuntu

- Ubuntu 20.04 LTS o superior
- IP del servidor: `192.168.1.24`
- Puertos disponibles: 8000 (API), 3306 (MySQL - solo local), 6379 (Redis - solo local)
- Acceso SSH al servidor
- Al menos 2GB de RAM
- 10GB de espacio en disco

## 🔧 Instalación Rápida

### 1. Clonar el Repositorio en el Servidor

```bash
# Conectarse al servidor
ssh usuario@192.168.1.24

# Clonar el repositorio
git clone <tu-repositorio> /opt/laravel-api
cd /opt/laravel-api
```

### 2. Configurar Variables de Entorno

```bash
# Copiar archivo de configuración
cp .env.production .env

# Editar configuración (especialmente las contraseñas)
nano .env
```

**⚠️ IMPORTANTE: Cambiar estas contraseñas en producción:**
```env
DB_PASSWORD=tu_password_seguro_aqui
REDIS_PASSWORD=tu_redis_password_aqui
APP_KEY=                          # Se generará automáticamente
```

### 3. Ejecutar Script de Despliegue

```bash
# Dar permisos de ejecución
chmod +x deploy.sh

# Ejecutar despliegue
./deploy.sh
```

El script automáticamente:
- ✓ Instala Docker y Docker Compose si no están presentes
- ✓ Crea directorios necesarios
- ✓ Construye la imagen Docker
- ✓ Levanta los contenedores
- ✓ Ejecuta migraciones
- ✓ Configura permisos
- ✓ Genera cachés de optimización

## 🌐 Verificar Instalación

### Probar desde el servidor:
```bash
curl http://localhost:8000/api/health
curl http://192.168.1.24:8000/api/health
```

### Probar desde otra máquina en la red:
```bash
curl http://192.168.1.24:8000/api/health
```

**Respuesta esperada:**
```json
{
    "status": "ok",
    "message": "API is running",
    "timestamp": "2025-10-28T12:00:00.000000Z",
    "environment": "production"
}
```

## 🔗 Configuración de Angular

En tu proyecto Angular, configura el archivo `environment.ts` y `environment.prod.ts`:

```typescript
export const environment = {
  production: true,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

### Ejemplo de petición desde Angular:

```typescript
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/environment';

export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getData() {
    return this.http.get(`${this.apiUrl}/test`);
  }
}
```

## 📊 Comandos Útiles

### Ver logs en tiempo real:
```bash
docker logs -f laravel_api_backend
```

### Entrar al contenedor:
```bash
docker exec -it laravel_api_backend bash
```

### Ejecutar comandos Artisan:
```bash
docker exec laravel_api_backend php artisan migrate
docker exec laravel_api_backend php artisan cache:clear
docker exec laravel_api_backend php artisan config:cache
```

### Ver estado de contenedores:
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Reiniciar servicios:
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Detener servicios:
```bash
docker-compose -f docker-compose.prod.yml down
```

### Actualizar aplicación:
```bash
# Obtener últimos cambios
git pull

# Reconstruir y reiniciar
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Ejecutar migraciones y limpiar caché
docker exec laravel_api_backend php artisan migrate --force
docker exec laravel_api_backend php artisan config:cache
docker exec laravel_api_backend php artisan route:cache
```

## 🔒 Seguridad

### Configurar Firewall (UFW):
```bash
sudo ufw enable
sudo ufw allow 22/tcp           # SSH
sudo ufw allow 8000/tcp         # API Backend
sudo ufw status
```

### Cambiar contraseñas por defecto:

Edita el archivo `.env` y cambia:
- `DB_PASSWORD`
- `REDIS_PASSWORD`
- `DB_ROOT_PASSWORD` en `docker-compose.prod.yml`

### Generar nuevo APP_KEY:
```bash
docker exec laravel_api_backend php artisan key:generate --force
```

## 🐛 Solución de Problemas

### Error de conexión desde Angular:

1. **Verificar CORS:**
```bash
curl -X OPTIONS http://192.168.1.24:8000/api/test \
  -H "Origin: http://192.168.1.24:4200" \
  -H "Access-Control-Request-Method: GET" \
  -v
```

2. **Verificar firewall:**
```bash
sudo ufw status
sudo ufw allow 8000/tcp
```

3. **Verificar que el contenedor esté corriendo:**
```bash
docker ps | grep laravel_api_backend
```

### Error de permisos:
```bash
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/storage
docker exec laravel_api_backend chmod -R 775 /var/www/html/storage
```

### Ver logs de errores:
```bash
docker exec laravel_api_backend tail -f storage/logs/laravel.log
```

### Base de datos no conecta:
```bash
# Verificar que MySQL esté corriendo
docker ps | grep laravel_api_db

# Ver logs de MySQL
docker logs laravel_api_db

# Probar conexión
docker exec laravel_api_backend php artisan tinker
>>> DB::connection()->getPdo();
```

## 📝 Notas Adicionales

- El API está configurado para aceptar peticiones desde cualquier origen (CORS: `*`)
- Los logs de Apache están en `/var/log/apache2/` dentro del contenedor
- Los datos de MySQL se persisten en un volumen Docker (`db_data`)
- Redis se usa para caché y sesiones
- El puerto 8000 está mapeado al puerto 80 del contenedor

## 🔄 Backup

### Hacer backup de la base de datos:
```bash
docker exec laravel_api_db mysqldump -u laravel -plaravel_secure_password_change_this laravel > backup_$(date +%Y%m%d).sql
```

### Restaurar backup:
```bash
docker exec -i laravel_api_db mysql -u laravel -plaravel_secure_password_change_this laravel < backup_20251028.sql
```

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker logs -f laravel_api_backend`
2. Verifica el estado: `docker-compose -f docker-compose.prod.yml ps`
3. Prueba el health check: `curl http://192.168.1.24:8000/api/health`

---

**Última actualización:** Octubre 2025

