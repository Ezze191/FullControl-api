#!/bin/bash

# Script de administración para Laravel API Backend

COMPOSE_FILE="docker-compose.prod.yml"
CONTAINER_NAME="laravel_api_backend"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_menu() {
    echo ""
    echo "╔═══════════════════════════════════════════════╗"
    echo "║     Laravel API Backend - Administración      ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo ""
    echo "1)  🚀 Iniciar servicios"
    echo "2)  🛑 Detener servicios"
    echo "3)  🔄 Reiniciar servicios"
    echo "4)  📊 Ver estado"
    echo "5)  📝 Ver logs en tiempo real"
    echo "6)  🔍 Ver logs completos"
    echo "7)  🐚 Entrar al contenedor (bash)"
    echo "8)  🗄️  Ejecutar migraciones"
    echo "9)  🧹 Limpiar caché"
    echo "10) ⚙️  Cachear configuración"
    echo "11) 🔑 Generar APP_KEY"
    echo "12) 📋 Listar rutas"
    echo "13) 💾 Backup de base de datos"
    echo "14) 📦 Actualizar desde Git"
    echo "15) 🏗️  Reconstruir contenedores"
    echo "16) 🧪 Probar API"
    echo "0)  ❌ Salir"
    echo ""
    echo -n "Selecciona una opción: "
}

start_services() {
    echo -e "${GREEN}🚀 Iniciando servicios...${NC}"
    docker-compose -f $COMPOSE_FILE up -d
    echo -e "${GREEN}✓ Servicios iniciados${NC}"
}

stop_services() {
    echo -e "${YELLOW}🛑 Deteniendo servicios...${NC}"
    docker-compose -f $COMPOSE_FILE down
    echo -e "${GREEN}✓ Servicios detenidos${NC}"
}

restart_services() {
    echo -e "${YELLOW}🔄 Reiniciando servicios...${NC}"
    docker-compose -f $COMPOSE_FILE restart
    echo -e "${GREEN}✓ Servicios reiniciados${NC}"
}

show_status() {
    echo -e "${GREEN}📊 Estado de los servicios:${NC}"
    docker-compose -f $COMPOSE_FILE ps
}

show_logs() {
    echo -e "${GREEN}📝 Logs en tiempo real (Ctrl+C para salir):${NC}"
    docker logs -f $CONTAINER_NAME
}

show_all_logs() {
    echo -e "${GREEN}🔍 Logs completos:${NC}"
    docker logs $CONTAINER_NAME
}

enter_container() {
    echo -e "${GREEN}🐚 Entrando al contenedor...${NC}"
    docker exec -it $CONTAINER_NAME bash
}

run_migrations() {
    echo -e "${GREEN}🗄️  Ejecutando migraciones...${NC}"
    docker exec $CONTAINER_NAME php artisan migrate --force
    echo -e "${GREEN}✓ Migraciones completadas${NC}"
}

clear_cache() {
    echo -e "${GREEN}🧹 Limpiando caché...${NC}"
    docker exec $CONTAINER_NAME php artisan cache:clear
    docker exec $CONTAINER_NAME php artisan config:clear
    docker exec $CONTAINER_NAME php artisan route:clear
    docker exec $CONTAINER_NAME php artisan view:clear
    echo -e "${GREEN}✓ Caché limpiado${NC}"
}

cache_config() {
    echo -e "${GREEN}⚙️  Cacheando configuración...${NC}"
    docker exec $CONTAINER_NAME php artisan config:cache
    docker exec $CONTAINER_NAME php artisan route:cache
    docker exec $CONTAINER_NAME php artisan view:cache
    echo -e "${GREEN}✓ Configuración cacheada${NC}"
}

generate_key() {
    echo -e "${GREEN}🔑 Generando APP_KEY...${NC}"
    docker exec $CONTAINER_NAME php artisan key:generate --force
    echo -e "${GREEN}✓ APP_KEY generado${NC}"
}

list_routes() {
    echo -e "${GREEN}📋 Listado de rutas:${NC}"
    docker exec $CONTAINER_NAME php artisan route:list
}

backup_database() {
    echo -e "${GREEN}💾 Creando backup de base de datos...${NC}"
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    docker exec laravel_api_db mysqladmin -u laravel -plaravel ping >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker exec laravel_api_db mysqldump -u laravel -plaravel laravel > $BACKUP_FILE
        echo -e "${GREEN}✓ Backup creado: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}✗ Error al conectar con la base de datos${NC}"
    fi
}

update_from_git() {
    echo -e "${GREEN}📦 Actualizando desde Git...${NC}"
    git pull
    docker-compose -f $COMPOSE_FILE down
    docker-compose -f $COMPOSE_FILE build --no-cache
    docker-compose -f $COMPOSE_FILE up -d
    sleep 5
    docker exec $CONTAINER_NAME php artisan migrate --force
    docker exec $CONTAINER_NAME php artisan config:cache
    docker exec $CONTAINER_NAME php artisan route:cache
    echo -e "${GREEN}✓ Actualización completada${NC}"
}

rebuild_containers() {
    echo -e "${YELLOW}🏗️  Reconstruyendo contenedores...${NC}"
    docker-compose -f $COMPOSE_FILE down -v
    docker-compose -f $COMPOSE_FILE build --no-cache
    docker-compose -f $COMPOSE_FILE up -d
    echo -e "${GREEN}✓ Contenedores reconstruidos${NC}"
}

test_api() {
    echo -e "${GREEN}🧪 Probando API...${NC}"
    if [ -f "scripts/test-api.sh" ]; then
        bash scripts/test-api.sh
    else
        echo -e "${YELLOW}⚠ Archivo test-api.sh no encontrado${NC}"
        echo "Probando endpoint health:"
        curl -s http://192.168.1.24:8000/api/health | jq '.'
    fi
}

# Loop principal
while true; do
    show_menu
    read -r option
    
    case $option in
        1) start_services ;;
        2) stop_services ;;
        3) restart_services ;;
        4) show_status ;;
        5) show_logs ;;
        6) show_all_logs ;;
        7) enter_container ;;
        8) run_migrations ;;
        9) clear_cache ;;
        10) cache_config ;;
        11) generate_key ;;
        12) list_routes ;;
        13) backup_database ;;
        14) update_from_git ;;
        15) rebuild_containers ;;
        16) test_api ;;
        0)
            echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
    
    echo ""
    echo -n "Presiona Enter para continuar..."
    read
done

