#!/bin/bash

# Script de despliegue para Laravel API Backend en Ubuntu Server
# IP del servidor: 192.168.1.24

set -e

echo "🚀 Iniciando despliegue de Laravel API Backend..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Instalando Docker..."
    
    # Actualizar paquetes
    sudo apt-get update
    
    # Instalar dependencias
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Agregar la clave GPG oficial de Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Configurar el repositorio
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalar Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    print_message "Docker instalado correctamente"
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Instalando Docker Compose..."
    
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    print_message "Docker Compose instalado correctamente"
fi

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    print_warning "Archivo .env no encontrado. Creando desde .env.production..."
    cp .env.production .env
    
    # Generar APP_KEY
    print_message "Generando APP_KEY..."
    APP_KEY=$(openssl rand -base64 32)
    sed -i "s/APP_KEY=/APP_KEY=base64:$APP_KEY/" .env
fi

# Crear directorios necesarios
print_message "Creando directorios necesarios..."
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p storage/logs
mkdir -p bootstrap/cache
mkdir -p docker/mysql

# Crear configuración MySQL
cat > docker/mysql/my.cnf << EOF
[mysqld]
general_log = 0
slow_query_log = 0
max_connections = 100
innodb_buffer_pool_size = 256M
EOF

# Detener contenedores existentes
if [ "$(docker ps -q -f name=laravel_api)" ]; then
    print_message "Deteniendo contenedores existentes..."
    docker-compose -f docker-compose.prod.yml down
fi

# Construir y levantar contenedores
print_message "Construyendo imagen Docker..."
docker-compose -f docker-compose.prod.yml build --no-cache

print_message "Levantando contenedores..."
docker-compose -f docker-compose.prod.yml up -d

# Esperar a que los contenedores estén saludables
print_message "Esperando a que los servicios estén listos..."
sleep 10

# Ejecutar migraciones
print_message "Ejecutando migraciones de base de datos..."
docker exec laravel_api_backend php artisan migrate --force

# Generar caché de configuración
print_message "Generando caché de configuración..."
docker exec laravel_api_backend php artisan config:cache
docker exec laravel_api_backend php artisan route:cache
docker exec laravel_api_backend php artisan view:cache

# Limpiar caché
print_message "Limpiando caché..."
docker exec laravel_api_backend php artisan cache:clear

# Establecer permisos
print_message "Estableciendo permisos..."
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/storage
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/bootstrap/cache

# Configurar firewall (opcional)
print_warning "Configurando firewall UFW..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 8000/tcp comment 'Laravel API Backend'
    print_message "Firewall configurado para permitir el puerto 8000"
else
    print_warning "UFW no está instalado. Considera instalarlo para mayor seguridad."
fi

# Mostrar información
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    ✓ DESPLIEGUE COMPLETADO                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
print_message "API Backend disponible en: http://192.168.1.24:8000"
print_message "Para probar: curl http://192.168.1.24:8000/api/health"
echo ""
print_warning "Configuración de Angular:"
echo "  En tu archivo environment.ts de Angular, configura:"
echo "  apiUrl: 'http://192.168.1.24:8000/api'"
echo ""
print_warning "Comandos útiles:"
echo "  Ver logs:           docker logs -f laravel_api_backend"
echo "  Entrar al contenedor: docker exec -it laravel_api_backend bash"
echo "  Reiniciar:          docker-compose -f docker-compose.prod.yml restart"
echo "  Detener:            docker-compose -f docker-compose.prod.yml down"
echo "  Ver estado:         docker-compose -f docker-compose.prod.yml ps"
echo ""

