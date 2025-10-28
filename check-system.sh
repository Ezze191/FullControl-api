#!/bin/bash

# Script para verificar requisitos del sistema antes del despliegue

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║    Verificación de Requisitos del Sistema - Laravel API      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Función para verificar
check_item() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        ERRORS=$((ERRORS + 1))
    fi
}

# 1. Verificar sistema operativo
echo "📋 Sistema Operativo:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "   OS: $NAME $VERSION"
    check_item 0 "Sistema operativo detectado"
else
    check_item 1 "No se pudo detectar el sistema operativo"
fi
echo ""

# 2. Verificar arquitectura
echo "💻 Arquitectura:"
ARCH=$(uname -m)
echo "   Arquitectura: $ARCH"
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "aarch64" ]; then
    check_item 0 "Arquitectura soportada"
else
    check_item 1 "Arquitectura no soportada"
fi
echo ""

# 3. Verificar RAM
echo "🧠 Memoria RAM:"
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
echo "   RAM Total: ${TOTAL_RAM}MB"
if [ $TOTAL_RAM -ge 2000 ]; then
    check_item 0 "RAM suficiente (>= 2GB recomendado)"
else
    check_item 1 "RAM insuficiente (se recomienda >= 2GB)"
fi
echo ""

# 4. Verificar espacio en disco
echo "💾 Espacio en Disco:"
DISK_AVAIL=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
echo "   Espacio disponible: ${DISK_AVAIL}GB"
if [ $DISK_AVAIL -ge 10 ]; then
    check_item 0 "Espacio en disco suficiente (>= 10GB recomendado)"
else
    check_item 1 "Espacio en disco insuficiente (se recomienda >= 10GB)"
fi
echo ""

# 5. Verificar Git
echo "📦 Git:"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo "   Versión: $GIT_VERSION"
    check_item 0 "Git instalado"
else
    check_item 1 "Git no instalado (ejecutar: sudo apt install git)"
fi
echo ""

# 6. Verificar Docker
echo "🐳 Docker:"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo "   Versión: $DOCKER_VERSION"
    check_item 0 "Docker instalado"
    
    # Verificar que Docker esté corriendo
    if docker ps &> /dev/null; then
        check_item 0 "Docker daemon corriendo"
    else
        check_item 1 "Docker daemon no está corriendo"
    fi
else
    echo -e "${YELLOW}   Docker no instalado (el script de despliegue lo instalará)${NC}"
fi
echo ""

# 7. Verificar Docker Compose
echo "🐙 Docker Compose:"
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | awk '{print $4}' | sed 's/,//')
    echo "   Versión: $COMPOSE_VERSION"
    check_item 0 "Docker Compose instalado"
else
    echo -e "${YELLOW}   Docker Compose no instalado (el script de despliegue lo instalará)${NC}"
fi
echo ""

# 8. Verificar curl
echo "🌐 Curl:"
if command -v curl &> /dev/null; then
    CURL_VERSION=$(curl --version | head -n1 | awk '{print $2}')
    echo "   Versión: $CURL_VERSION"
    check_item 0 "Curl instalado"
else
    check_item 1 "Curl no instalado (ejecutar: sudo apt install curl)"
fi
echo ""

# 9. Verificar puertos disponibles
echo "🔌 Puertos:"
PORT_8000=$(netstat -tuln 2>/dev/null | grep ':8000 ' || ss -tuln 2>/dev/null | grep ':8000 ')
if [ -z "$PORT_8000" ]; then
    check_item 0 "Puerto 8000 disponible (Backend API)"
else
    echo -e "${YELLOW}⚠${NC} Puerto 8000 en uso (puede causar conflictos)"
fi

PORT_3306=$(netstat -tuln 2>/dev/null | grep ':3306 ' || ss -tuln 2>/dev/null | grep ':3306 ')
if [ -z "$PORT_3306" ]; then
    check_item 0 "Puerto 3306 disponible (MySQL)"
else
    echo -e "${YELLOW}⚠${NC} Puerto 3306 en uso (puede causar conflictos)"
fi
echo ""

# 10. Verificar firewall
echo "🔥 Firewall:"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status | grep -i "Status:" | awk '{print $2}')
    echo "   UFW Status: $UFW_STATUS"
    check_item 0 "UFW instalado"
else
    echo -e "${YELLOW}   UFW no instalado (recomendado para producción)${NC}"
fi
echo ""

# 11. Verificar IP del servidor
echo "📡 Configuración de Red:"
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "   IP del servidor: $SERVER_IP"
if [ "$SERVER_IP" = "192.168.1.24" ]; then
    check_item 0 "IP del servidor coincide con la configuración"
else
    echo -e "${YELLOW}⚠${NC} IP del servidor ($SERVER_IP) diferente a la configurada (192.168.1.24)"
    echo -e "${YELLOW}   Actualiza los archivos de configuración con la IP correcta${NC}"
fi
echo ""

# 12. Verificar archivos necesarios
echo "📄 Archivos del Proyecto:"
if [ -f "Dockerfile" ]; then
    check_item 0 "Dockerfile encontrado"
else
    check_item 1 "Dockerfile no encontrado"
fi

if [ -f "docker-compose.prod.yml" ]; then
    check_item 0 "docker-compose.prod.yml encontrado"
else
    check_item 1 "docker-compose.prod.yml no encontrado"
fi

if [ -f "deploy.sh" ]; then
    check_item 0 "deploy.sh encontrado"
else
    check_item 1 "deploy.sh no encontrado"
fi

if [ -f "composer.json" ]; then
    check_item 0 "composer.json encontrado (proyecto Laravel)"
else
    check_item 1 "composer.json no encontrado"
fi
echo ""

# Resumen
echo "╔═══════════════════════════════════════════════════════════════╗"
if [ $ERRORS -eq 0 ]; then
    echo -e "║           ${GREEN}✓ Sistema listo para el despliegue${NC}                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}🚀 Puedes proceder con el despliegue:${NC}"
    echo "   chmod +x deploy.sh"
    echo "   ./deploy.sh"
else
    echo -e "║         ${RED}✗ Se encontraron $ERRORS problema(s)${NC}                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${RED}⚠️  Corrige los problemas antes de continuar${NC}"
    echo ""
    echo "Problemas comunes:"
    echo "  • Instalar Git: sudo apt install git"
    echo "  • Instalar Curl: sudo apt install curl"
    echo "  • Docker se instalará automáticamente con deploy.sh"
    echo "  • Verificar espacio en disco: df -h"
fi
echo ""

