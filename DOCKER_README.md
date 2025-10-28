# Docker Setup para Laravel FullControl System - Desarrollo Local

Este proyecto incluye una configuración optimizada de Docker para desarrollo local.

## 🚀 Características

- **PHP 8.1** con Apache
- **MySQL 8.0** como base de datos
- **Redis** para caché y sesiones
- **Mailpit** para testing de emails
- **Node.js 18** para assets frontend
- **Composer** para dependencias PHP
- **Vite** para compilación de assets
- **Acceso solo local** (localhost:8000)

## 📋 Prerrequisitos

- Docker Desktop instalado
- Docker Compose instalado

## 🛠️ Configuración Inicial

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd FullControl_System
```

### 2. Configurar variables de entorno
```bash
# Copiar el archivo de ejemplo para desarrollo local
cp env.local.example .env

# Editar las variables según tu configuración (opcional)
nano .env
```

### 3. Construir y ejecutar los contenedores
```bash
# Construir las imágenes
docker-compose build

# Ejecutar en segundo plano
docker-compose up -d

# Ver logs
docker-compose logs -f
```

## 🔧 Comandos Útiles

### Gestión de contenedores
```bash
# Iniciar todos los servicios
docker-compose up -d

# Detener todos los servicios
docker-compose down

# Reiniciar un servicio específico
docker-compose restart app

# Ver estado de los contenedores
docker-compose ps
```

### Comandos de Laravel
```bash
# Ejecutar comandos artisan
docker-compose exec app php artisan migrate
docker-compose exec app php artisan db:seed
docker-compose exec app php artisan key:generate

# Acceder al contenedor de la aplicación
docker-compose exec app bash

# Limpiar caché
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

### Comandos de Composer
```bash
# Instalar dependencias
docker-compose exec app composer install

# Actualizar dependencias
docker-compose exec app composer update

# Instalar paquete específico
docker-compose exec app composer require nombre-paquete
```

### Comandos de Node.js
```bash
# Instalar dependencias de Node
docker-compose exec node npm install

# Compilar assets para desarrollo
docker-compose exec node npm run dev

# Compilar assets para producción
docker-compose exec node npm run build
```

## 🌐 Acceso a los Servicios (Solo Local)

- **Aplicación Laravel**: http://localhost:8000
- **Base de datos MySQL**: localhost:3306
- **Redis**: localhost:6379
- **Mailpit (Web UI)**: http://localhost:8025
- **Vite Dev Server**: http://localhost:5173

> **Nota**: Todos los servicios están configurados para acceso local únicamente. No son accesibles desde IPs externas por seguridad.

## 🗄️ Base de Datos

### Credenciales por defecto:
- **Host**: db (desde contenedores) / localhost:3306 (desde host)
- **Database**: laravel
- **Username**: laravel
- **Password**: laravel
- **Root Password**: root

### Migraciones y Seeders:
```bash
# Ejecutar migraciones
docker-compose exec app php artisan migrate

# Ejecutar seeders
docker-compose exec app php artisan db:seed

# Refrescar base de datos con seeders
docker-compose exec app php artisan migrate:fresh --seed
```

## 📧 Configuración de Email

El proyecto incluye **Mailpit** para testing de emails:
- **SMTP Host**: mailpit
- **SMTP Port**: 1025
- **Web Interface**: http://localhost:8025

## 🔧 Desarrollo

### Estructura de archivos montados:
- El código fuente se monta en `/var/www/html`
- Los logs se mantienen en `storage/logs/`
- La base de datos persiste en el volumen `db_data`

### Hot Reload:
- Los cambios en PHP se reflejan inmediatamente
- Para cambios en assets frontend, usar: `npm run dev`

## 🚀 Configuración para Producción

Si necesitas desplegar en producción, usa los archivos de configuración de servidor:

1. **Usar configuración de servidor**:
   ```bash
   # Usar docker-compose.server.yml para producción
   docker-compose -f docker-compose.server.yml up -d
   ```

2. **Configurar variables de entorno**:
   ```bash
   # Copiar configuración de servidor
   cp env.server.example .env
   # Editar según tu servidor
   nano .env
   ```

## 🐛 Troubleshooting

### Problemas comunes:

1. **Error de permisos**:
   ```bash
   sudo chown -R $USER:$USER storage bootstrap/cache
   ```

2. **Contenedor no inicia**:
   ```bash
   docker-compose logs app
   ```

3. **Base de datos no conecta**:
   ```bash
   docker-compose exec app php artisan config:clear
   ```

4. **Assets no se cargan**:
   ```bash
   docker-compose exec app php artisan storage:link
   ```

### Limpiar todo:
```bash
# Detener y eliminar contenedores
docker-compose down

# Eliminar volúmenes (¡CUIDADO! Elimina datos de BD)
docker-compose down -v

# Eliminar imágenes
docker-compose down --rmi all
```

## 📝 Notas Adicionales

- El archivo `.env` se genera automáticamente si no existe
- Los logs de Laravel se encuentran en `storage/logs/`
- La aplicación está configurada para usar Apache con mod_rewrite habilitado
- Redis se usa para caché y sesiones por defecto
- Los assets se compilan automáticamente durante el build

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request
