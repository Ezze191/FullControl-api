#!/bin/bash

# Script de Despliegue para Servidor
# FullControl System - Laravel Docker

set -e

echo "🚀 Iniciando despliegue en servidor..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

# Crear directorio para SSL si no existe
mkdir -p ssl

# Copiar archivo de configuración de servidor
if [ ! -f .env ]; then
    print_message "Copiando configuración de servidor..."
    cp env.server.example .env
    print_warning "Por favor edita el archivo .env con tus configuraciones específicas"
fi

# Generar clave de aplicación si no existe
if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env; then
    print_message "Generando clave de aplicación..."
    # Se generará automáticamente en el contenedor
fi

# Construir las imágenes
print_message "Construyendo imágenes de Docker..."
docker-compose -f docker-compose.server.yml build --no-cache

# Detener contenedores existentes
print_message "Deteniendo contenedores existentes..."
docker-compose -f docker-compose.server.yml down

# Iniciar los servicios
print_message "Iniciando servicios..."
docker-compose -f docker-compose.server.yml up -d

# Esperar a que la base de datos esté lista
print_message "Esperando a que la base de datos esté lista..."
sleep 30

# Ejecutar migraciones
print_message "Ejecutando migraciones..."
docker-compose -f docker-compose.server.yml exec app php artisan migrate --force

# Ejecutar seeders (opcional)
read -p "¿Deseas ejecutar los seeders? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_message "Ejecutando seeders..."
    docker-compose -f docker-compose.server.yml exec app php artisan db:seed --force
fi

# Limpiar caché
print_message "Limpiando caché..."
docker-compose -f docker-compose.server.yml exec app php artisan config:cache
docker-compose -f docker-compose.server.yml exec app php artisan route:cache
docker-compose -f docker-compose.server.yml exec app php artisan view:cache

# Crear enlace simbólico para storage
print_message "Creando enlace simbólico para storage..."
docker-compose -f docker-compose.server.yml exec app php artisan storage:link

# Configurar permisos
print_message "Configurando permisos..."
docker-compose -f docker-compose.server.yml exec app chown -R www-data:www-data /var/www/html/storage
docker-compose -f docker-compose.server.yml exec app chown -R www-data:www-data /var/www/html/bootstrap/cache

# Mostrar estado de los contenedores
print_message "Estado de los contenedores:"
docker-compose -f docker-compose.server.yml ps

# Mostrar información de acceso
print_message "✅ Despliegue completado exitosamente!"
echo ""
echo "🌐 Acceso a la aplicación:"
echo "   HTTP: http://$(hostname -I | awk '{print $1}'):80"
echo "   O desde cualquier IP: http://0.0.0.0:80"
echo ""
echo "📊 Servicios disponibles:"
echo "   - Aplicación Laravel: Puerto 80"
echo "   - Base de datos MySQL: Puerto 3306"
echo "   - Redis: Puerto 6379"
echo "   - Mailpit (Web UI): Puerto 8025"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: docker-compose -f docker-compose.server.yml logs -f"
echo "   Detener: docker-compose -f docker-compose.server.yml down"
echo "   Reiniciar: docker-compose -f docker-compose.server.yml restart"
echo ""

# Verificar que la aplicación esté funcionando
print_message "Verificando que la aplicación esté funcionando..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    print_message "✅ Aplicación funcionando correctamente"
else
    print_warning "⚠️  La aplicación podría no estar funcionando correctamente"
    print_message "Revisa los logs: docker-compose -f docker-compose.server.yml logs app"
fi
