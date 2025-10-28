#!/bin/bash

# Script para probar la API desde Angular
# Simula las peticiones que haría Angular

API_URL="http://192.168.1.24:8000/api"
ORIGIN="http://192.168.1.24:4200"

echo "========================================"
echo "🧪 Prueba de API Laravel desde Angular"
echo "========================================"
echo ""

# Test 1: Health Check
echo "📡 Test 1: Health Check"
echo "GET $API_URL/health"
curl -s -X GET "$API_URL/health" \
  -H "Accept: application/json" \
  -H "Origin: $ORIGIN" | jq '.'
echo ""

# Test 2: CORS Preflight
echo "📡 Test 2: CORS Preflight (OPTIONS)"
echo "OPTIONS $API_URL/test"
curl -s -X OPTIONS "$API_URL/test" \
  -H "Origin: $ORIGIN" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "< HTTP|< Access-Control"
echo ""

# Test 3: Test endpoint
echo "📡 Test 3: Test Endpoint"
echo "GET $API_URL/test"
curl -s -X GET "$API_URL/test" \
  -H "Accept: application/json" \
  -H "Origin: $ORIGIN" | jq '.'
echo ""

# Test 4: POST request
echo "📡 Test 4: POST Request con CORS"
echo "POST $API_URL/test"
curl -s -X POST "$API_URL/test" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Origin: $ORIGIN" \
  -d '{"test": "data"}' 2>&1 | head -n 5
echo ""

echo "========================================"
echo "✅ Pruebas completadas"
echo "========================================"
echo ""
echo "💡 Si ves errores CORS, verifica:"
echo "   1. El contenedor está corriendo: docker ps"
echo "   2. El firewall permite el puerto 8000: sudo ufw status"
echo "   3. Los logs del contenedor: docker logs laravel_api_backend"

