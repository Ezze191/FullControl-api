# 🚀 Despliegue en Servidor - FullControl System

Esta guía te ayudará a desplegar tu aplicación Laravel en un servidor con acceso desde cualquier IP.

## 📋 Prerrequisitos del Servidor

### 1. Sistema Operativo
- Ubuntu 20.04+ / CentOS 7+ / Debian 10+
- Mínimo 2GB RAM
- Mínimo 20GB espacio en disco
- Acceso root o sudo

### 2. Software Requerido
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reiniciar sesión para aplicar cambios
exit
```

## 🔧 Configuración del Servidor

### 1. Configurar Firewall
```bash
# Ubuntu/Debian
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --reload
```

### 2. Configurar Swap (Recomendado)
```bash
# Crear archivo de swap de 2GB
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Hacer permanente
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 🚀 Despliegue Automático

### Opción 1: Script Automático (Recomendado)
```bash
# Hacer ejecutable el script
chmod +x deploy-server.sh

# Ejecutar despliegue
./deploy-server.sh
```

### Opción 2: Despliegue Manual
```bash
# 1. Copiar configuración
cp env.server.example .env

# 2. Editar configuración
nano .env

# 3. Construir e iniciar
docker-compose -f docker-compose.server.yml build
docker-compose -f docker-compose.server.yml up -d

# 4. Ejecutar migraciones
docker-compose -f docker-compose.server.yml exec app php artisan migrate --force
```

## 🌐 Configuración de Acceso Externo

### 1. Configuración de Red
La aplicación está configurada para escuchar en todas las interfaces:
- **Puerto 80**: Acceso HTTP desde cualquier IP
- **Puerto 443**: Acceso HTTPS (configurar SSL)
- **Puerto 3306**: MySQL (opcional, remover en producción)
- **Puerto 6379**: Redis (opcional, remover en producción)

### 2. Configuración de Dominio
```bash
# Editar .env
APP_URL=http://tu-dominio.com
# o
APP_URL=http://tu-ip-servidor
```

### 3. Configuración de SSL (Opcional)
```bash
# Crear certificados SSL
mkdir -p ssl
# Copiar tus certificados a la carpeta ssl/
# Descomentar configuración HTTPS en nginx.conf
```

## 🔒 Configuración de Seguridad

### 1. Variables de Entorno Importantes
```bash
# En .env
APP_ENV=production
APP_DEBUG=false
APP_URL=http://tu-dominio.com

# Base de datos segura
DB_PASSWORD=password_muy_seguro_123
DB_ROOT_PASSWORD=root_password_muy_seguro_456

# Trusted Proxies (importante para Nginx)
TRUSTED_PROXIES=*
```

### 2. Configuración de Firewall Avanzada
```bash
# Solo permitir puertos necesarios
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 3. Configuración de Nginx
El archivo `nginx.conf` incluye:
- Rate limiting para API
- Headers de seguridad
- Compresión Gzip
- Caché para archivos estáticos
- Protección contra ataques comunes

## 📊 Monitoreo y Mantenimiento

### 1. Ver Estado de los Servicios
```bash
# Estado general
docker-compose -f docker-compose.server.yml ps

# Logs en tiempo real
docker-compose -f docker-compose.server.yml logs -f

# Logs de un servicio específico
docker-compose -f docker-compose.server.yml logs -f app
```

### 2. Comandos de Mantenimiento
```bash
# Reiniciar aplicación
docker-compose -f docker-compose.server.yml restart app

# Actualizar aplicación
git pull
docker-compose -f docker-compose.server.yml build app
docker-compose -f docker-compose.server.yml up -d app

# Backup de base de datos
docker-compose -f docker-compose.server.yml exec db mysqldump -u root -p laravel > backup.sql

# Limpiar caché
docker-compose -f docker-compose.server.yml exec app php artisan cache:clear
```

### 3. Monitoreo de Recursos
```bash
# Uso de CPU y memoria
docker stats

# Espacio en disco
df -h

# Logs del sistema
sudo journalctl -f
```

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Aplicación no accesible desde externo
```bash
# Verificar que el puerto esté abierto
sudo netstat -tlnp | grep :80

# Verificar firewall
sudo ufw status

# Verificar logs de Nginx
docker-compose -f docker-compose.server.yml logs nginx
```

#### 2. Error de permisos
```bash
# Corregir permisos
sudo chown -R $USER:$USER .
docker-compose -f docker-compose.server.yml exec app chown -R www-data:www-data /var/www/html/storage
```

#### 3. Base de datos no conecta
```bash
# Verificar estado de MySQL
docker-compose -f docker-compose.server.yml logs db

# Reiniciar base de datos
docker-compose -f docker-compose.server.yml restart db
```

#### 4. Aplicación lenta
```bash
# Verificar recursos
docker stats

# Limpiar caché
docker-compose -f docker-compose.server.yml exec app php artisan optimize:clear

# Reiniciar servicios
docker-compose -f docker-compose.server.yml restart
```

## 📈 Optimizaciones de Producción

### 1. Configuración de PHP
```bash
# Editar php.ini en el contenedor
docker-compose -f docker-compose.server.yml exec app php -i | grep memory_limit
```

### 2. Configuración de MySQL
```bash
# Optimizar MySQL para producción
# Editar configuración en docker-compose.server.yml
```

### 3. Configuración de Redis
```bash
# Configurar persistencia Redis
# Ya configurado en docker-compose.server.yml
```

## 🚨 Respaldos y Recuperación

### 1. Backup Automático
```bash
# Crear script de backup
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose -f docker-compose.server.yml exec db mysqldump -u root -p laravel > backup_$DATE.sql
tar -czf files_backup_$DATE.tar.gz storage/
EOF

chmod +x backup.sh
```

### 2. Restaurar Backup
```bash
# Restaurar base de datos
docker-compose -f docker-compose.server.yml exec -T db mysql -u root -p laravel < backup.sql

# Restaurar archivos
tar -xzf files_backup.tar.gz
```

## 📞 Soporte

Si tienes problemas con el despliegue:

1. Revisa los logs: `docker-compose -f docker-compose.server.yml logs`
2. Verifica la configuración: `docker-compose -f docker-compose.server.yml config`
3. Consulta la documentación de Laravel
4. Revisa la configuración de red del servidor

---

**¡Tu aplicación Laravel ahora está lista para ser accedida desde cualquier IP!** 🌐
