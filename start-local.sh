#!/bin/bash

# Script de Inicio para Desarrollo Local
# FullControl System - Laravel Docker

set -e

echo "🚀 Iniciando FullControl System para desarrollo local..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker Desktop primero."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

print_header "=== CONFIGURACIÓN INICIAL ==="

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    print_message "Creando archivo .env para desarrollo local..."
    cp env.local.example .env
    print_warning "Archivo .env creado. Puedes editarlo si necesitas cambios específicos."
else
    print_message "Archivo .env ya existe."
fi

print_header "=== CONSTRUCCIÓN DE IMÁGENES ==="

# Construir las imágenes
print_message "Construyendo imágenes de Docker..."
docker-compose build

print_header "=== INICIANDO SERVICIOS ==="

# Detener contenedores existentes
print_message "Deteniendo contenedores existentes..."
docker-compose down

# Iniciar los servicios
print_message "Iniciando servicios para desarrollo local..."
docker-compose up -d

# Esperar a que la base de datos esté lista
print_message "Esperando a que la base de datos esté lista..."
sleep 15

print_header "=== CONFIGURACIÓN DE LARAVEL ==="

# Generar clave de aplicación si no existe
print_message "Generando clave de aplicación..."
docker-compose exec app php artisan key:generate --force

# Ejecutar migraciones
print_message "Ejecutando migraciones..."
docker-compose exec app php artisan migrate --force

# Preguntar si ejecutar seeders
read -p "¿Deseas ejecutar los seeders? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_message "Ejecutando seeders..."
    docker-compose exec app php artisan db:seed --force
fi

# Crear enlace simbólico para storage
print_message "Creando enlace simbólico para storage..."
docker-compose exec app php artisan storage:link

# Limpiar caché
print_message "Limpiando caché..."
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

print_header "=== VERIFICACIÓN ==="

# Mostrar estado de los contenedores
print_message "Estado de los contenedores:"
docker-compose ps

# Verificar que la aplicación esté funcionando
print_message "Verificando que la aplicación esté funcionando..."
if curl -f http://localhost:8000 > /dev/null 2>&1; then
    print_message "✅ Aplicación funcionando correctamente"
else
    print_warning "⚠️  La aplicación podría no estar funcionando correctamente"
    print_message "Revisa los logs: docker-compose logs app"
fi

print_header "=== INFORMACIÓN DE ACCESO ==="

print_message "✅ ¡FullControl System iniciado exitosamente!"
echo ""
echo "🌐 Acceso a la aplicación:"
echo "   Aplicación Laravel: http://localhost:8000"
echo ""
echo "📊 Servicios disponibles (solo local):"
echo "   - Aplicación Laravel: http://localhost:8000"
echo "   - Base de datos MySQL: localhost:3306"
echo "   - Redis: localhost:6379"
echo "   - Mailpit (Web UI): http://localhost:8025"
echo "   - Vite Dev Server: http://localhost:5173"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: docker-compose logs -f"
echo "   Detener: docker-compose down"
echo "   Reiniciar: docker-compose restart"
echo "   Acceder al contenedor: docker-compose exec app bash"
echo ""
echo "📝 Notas importantes:"
echo "   - Todos los servicios son solo para desarrollo local"
echo "   - Los cambios en PHP se reflejan inmediatamente"
echo "   - Para cambios en assets frontend, usar: npm run dev"
echo ""

print_message "¡Disfruta desarrollando con FullControl System! 🎉"
