# 🚀 Laravel API Backend

Backend API REST desarrollado con Laravel para comunicarse con aplicaciones frontend (Angular, React, Vue, etc.)

## 📋 Características

- ✅ API REST completa
- ✅ CORS configurado para peticiones cross-origin
- ✅ Dockerizado para fácil despliegue
- ✅ Configuración para producción en Ubuntu Server
- ✅ Health check y endpoints de prueba
- ✅ MySQL + Redis incluidos
- ✅ Scripts de administración automatizados

## 🎯 Configuración del Servidor

- **IP del Servidor:** 192.168.1.24
- **Puerto API:** 8000
- **URL API:** http://192.168.1.24:8000/api

## 🚀 Inicio Rápido

### Desarrollo Local (Windows con XAMPP)

```bash
# Instalar dependencias
composer install

# Configurar .env
cp .env.example .env
php artisan key:generate

# Migrar base de datos
php artisan migrate

# Iniciar servidor
php artisan serve
```

### Producción (Ubuntu Server)

```bash
# 1. Clonar repositorio
git clone <tu-repositorio> /opt/laravel-api
cd /opt/laravel-api

# 2. Verificar sistema
bash check-system.sh

# 3. Configurar variables
cp .env.production.example .env
nano .env  # Cambiar contraseñas

# 4. Desplegar automáticamente
bash deploy.sh
```

## 📚 Documentación Completa

- **[INSTRUCCIONES_DESPLIEGUE.md](INSTRUCCIONES_DESPLIEGUE.md)** - Guía paso a paso para desplegar en Ubuntu
- **[README.DEPLOY.md](README.DEPLOY.md)** - Documentación completa de despliegue
- **[RESUMEN_CONFIGURACION.md](RESUMEN_CONFIGURACION.md)** - Resumen de archivos y configuraciones
- **[angular-example/README.md](angular-example/README.md)** - Integración con Angular

## 🛠️ Scripts Disponibles

### Administración Interactiva
```bash
bash scripts/manage.sh
```

Menú con opciones para:
- Iniciar/detener servicios
- Ver logs
- Ejecutar migraciones
- Limpiar caché
- Backup de base de datos
- Y más...

### Verificación del Sistema
```bash
bash check-system.sh
```

Verifica:
- Sistema operativo
- RAM y espacio en disco
- Docker y Docker Compose
- Puertos disponibles
- Archivos necesarios

### Pruebas de API
```bash
bash scripts/test-api.sh
```

Prueba:
- Health check
- CORS
- Conectividad
- Endpoints

## 🌐 Endpoints Disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/health` | Estado del servidor |
| GET | `/api/test` | Prueba de CORS y conectividad |
| GET | `/api/user` | Usuario autenticado (requiere auth) |

**Agrega tus propios endpoints en:** `routes/api.php`

## 🎨 Integración con Angular

### 1. Configurar Environment

```typescript
// src/environments/environment.ts
export const environment = {
  production: true,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

### 2. Copiar Servicio API

Copia `angular-example/api.service.ts` a tu proyecto Angular.

### 3. Usar el Servicio

```typescript
import { ApiService } from './services/api.service';

constructor(private apiService: ApiService) {}

ngOnInit() {
  // Verificar conexión
  this.apiService.healthCheck().subscribe(
    response => console.log('Backend conectado:', response)
  );
  
  // Obtener datos
  this.apiService.get('items').subscribe(
    data => console.log('Datos:', data)
  );
}
```

Ver [angular-example/README.md](angular-example/README.md) para más ejemplos.

## 🔧 Comandos Útiles

### Docker

```bash
# Ver logs
docker logs -f laravel_api_backend

# Ver estado
docker-compose -f docker-compose.prod.yml ps

# Reiniciar
docker-compose -f docker-compose.prod.yml restart

# Detener
docker-compose -f docker-compose.prod.yml down

# Entrar al contenedor
docker exec -it laravel_api_backend bash
```

### Artisan

```bash
# Ejecutar migraciones
docker exec laravel_api_backend php artisan migrate

# Limpiar caché
docker exec laravel_api_backend php artisan cache:clear

# Ver rutas
docker exec laravel_api_backend php artisan route:list

# Crear controlador
docker exec laravel_api_backend php artisan make:controller NombreController --api
```

### Base de Datos

```bash
# Backup
docker exec laravel_api_db mysqldump -u laravel -pPASSWORD laravel > backup.sql

# Restaurar
docker exec -i laravel_api_db mysql -u laravel -pPASSWORD laravel < backup.sql

# Acceder a MySQL
docker exec -it laravel_api_db mysql -u laravel -pPASSWORD laravel
```

## 🐛 Solución de Problemas

### Angular no puede conectarse

```bash
# 1. Verificar que el backend esté corriendo
docker ps | grep laravel_api_backend

# 2. Probar el health check
curl http://192.168.1.24:8000/api/health

# 3. Verificar firewall
sudo ufw status
sudo ufw allow 8000/tcp

# 4. Ver logs
docker logs laravel_api_backend
```

### Error de base de datos

```bash
# Ver logs de MySQL
docker logs laravel_api_db

# Probar conexión
docker exec laravel_api_backend php artisan tinker
>>> DB::connection()->getPdo();
```

### Error de permisos

```bash
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/storage
docker exec laravel_api_backend chmod -R 775 /var/www/html/storage
```

Ver [README.DEPLOY.md](README.DEPLOY.md) para más soluciones.

## 📊 Arquitectura

```
Cliente (Navegador/Angular)
         ↓
    192.168.1.24:8000 (Laravel API)
         ↓
    Docker Container
         ↓
    MySQL + Redis
```

## 🔒 Seguridad

- ✅ CORS configurado
- ✅ Firewall UFW
- ✅ MySQL y Redis solo localmente
- ✅ Variables de entorno protegidas
- ⚠️ **IMPORTANTE:** Cambiar contraseñas predeterminadas en `.env`

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-caracteristica`
3. Commit cambios: `git commit -m 'Agregar nueva característica'`
4. Push a la rama: `git push origin feature/nueva-caracteristica`
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es privado y propietario.

## 📞 Contacto

Para soporte o consultas, revisa la documentación en:
- [INSTRUCCIONES_DESPLIEGUE.md](INSTRUCCIONES_DESPLIEGUE.md)
- [README.DEPLOY.md](README.DEPLOY.md)

---

**Desarrollado con ❤️ usando Laravel y Docker**
