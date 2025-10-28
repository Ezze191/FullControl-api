# 📦 Instrucciones de Despliegue para Ubuntu Server

## 🎯 Resumen
Este proyecto Laravel está configurado como **backend API** para comunicarse con tu aplicación Angular. Ambos estarán en el servidor **192.168.1.24**.

---

## 🚀 Paso a Paso - Despliegue en Ubuntu Server

### 1️⃣ Preparar el Servidor

```bash
# Conectarse al servidor Ubuntu
ssh usuario@192.168.1.24

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Git si no está instalado
sudo apt install git -y
```

### 2️⃣ Clonar el Proyecto

```bash
# Crear directorio para el proyecto
sudo mkdir -p /opt/laravel-api
sudo chown $USER:$USER /opt/laravel-api

# Clonar el repositorio
cd /opt
git clone <URL_DE_TU_REPOSITORIO> laravel-api
cd laravel-api
```

### 3️⃣ Configurar Variables de Entorno

```bash
# Copiar el archivo de configuración de producción
cp .env.production.example .env

# Editar el archivo .env (IMPORTANTE: cambiar las contraseñas)
nano .env
```

**⚠️ Cambiar estas líneas en el archivo .env:**
```env
DB_PASSWORD=TU_PASSWORD_SEGURO_AQUI
REDIS_PASSWORD=TU_REDIS_PASSWORD_AQUI
```

### 4️⃣ Ejecutar el Script de Despliegue

```bash
# Dar permisos de ejecución al script
chmod +x deploy.sh

# Ejecutar el despliegue (esto instalará Docker automáticamente si no está)
./deploy.sh
```

El script hará todo automáticamente:
- ✅ Instalar Docker y Docker Compose
- ✅ Construir la imagen Docker
- ✅ Levantar los contenedores (API + MySQL + Redis)
- ✅ Ejecutar migraciones
- ✅ Configurar permisos
- ✅ Generar cachés

### 5️⃣ Verificar que Funciona

```bash
# Desde el servidor
curl http://localhost:8000/api/health

# Desde otra máquina en la red
curl http://192.168.1.24:8000/api/health
```

**Respuesta esperada:**
```json
{
  "status": "ok",
  "message": "API is running",
  "timestamp": "2025-10-28T12:00:00.000000Z"
}
```

---

## 🌐 Configurar Angular para Conectarse a la API

### En tu proyecto Angular:

**archivo: `src/environments/environment.ts`**
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

**archivo: `src/environments/environment.prod.ts`**
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://192.168.1.24:8000/api'
};
```

### Ejemplo de Servicio en Angular:

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/environment';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  // Probar conexión
  testConnection(): Observable<any> {
    return this.http.get(`${this.apiUrl}/test`);
  }

  // Ejemplo: obtener datos
  getData(): Observable<any> {
    return this.http.get(`${this.apiUrl}/items`);
  }

  // Ejemplo: enviar datos
  postData(data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/items`, data);
  }
}
```

---

## 🔧 Comandos Útiles

### Ver logs en tiempo real:
```bash
docker logs -f laravel_api_backend
```

### Ver estado de los contenedores:
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Entrar al contenedor (para ejecutar comandos artisan):
```bash
docker exec -it laravel_api_backend bash

# Una vez dentro:
php artisan migrate
php artisan cache:clear
php artisan route:list
```

### Reiniciar el backend:
```bash
cd /opt/laravel-api
docker-compose -f docker-compose.prod.yml restart
```

### Detener el backend:
```bash
docker-compose -f docker-compose.prod.yml down
```

### Actualizar el código:
```bash
cd /opt/laravel-api
git pull
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
docker exec laravel_api_backend php artisan migrate --force
docker exec laravel_api_backend php artisan config:cache
```

---

## 🔒 Seguridad

### Configurar Firewall:
```bash
# Habilitar UFW
sudo ufw enable

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir API Backend
sudo ufw allow 8000/tcp

# Si Angular también está en este servidor
sudo ufw allow 4200/tcp

# Ver estado
sudo ufw status
```

### Cambiar Contraseñas:
Edita `/opt/laravel-api/.env` y cambia:
- `DB_PASSWORD`
- `REDIS_PASSWORD`

Luego reinicia:
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🐛 Solución de Problemas

### ❌ Angular no puede conectarse a la API

**1. Verificar que el backend esté corriendo:**
```bash
curl http://192.168.1.24:8000/api/health
```

**2. Verificar firewall:**
```bash
sudo ufw status
sudo ufw allow 8000/tcp
```

**3. Verificar CORS:**
```bash
curl -X OPTIONS http://192.168.1.24:8000/api/test \
  -H "Origin: http://192.168.1.24:4200" \
  -v
```

### ❌ Error de base de datos

```bash
# Ver logs de MySQL
docker logs laravel_api_db

# Verificar conexión
docker exec laravel_api_backend php artisan tinker
>>> DB::connection()->getPdo();
```

### ❌ Error 500 en el backend

```bash
# Ver logs de Laravel
docker exec laravel_api_backend tail -f storage/logs/laravel.log

# Ver logs de Apache
docker exec laravel_api_backend tail -f /var/log/apache2/error.log
```

### ❌ Permisos denegados

```bash
docker exec laravel_api_backend chown -R www-data:www-data /var/www/html/storage
docker exec laravel_api_backend chmod -R 775 /var/www/html/storage
```

---

## 📊 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────┐
│                  Servidor Ubuntu                         │
│                  IP: 192.168.1.24                        │
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │   Angular App    │────────▶│  Laravel API     │     │
│  │   Puerto 4200    │  HTTP   │  Puerto 8000     │     │
│  │  (Frontend)      │         │  (Backend)       │     │
│  └──────────────────┘         └────────┬─────────┘     │
│                                         │               │
│                                ┌────────▼─────────┐     │
│                                │  MySQL Database  │     │
│                                │  Puerto 3306     │     │
│                                └──────────────────┘     │
│                                                          │
│                                ┌──────────────────┐     │
│                                │  Redis Cache     │     │
│                                │  Puerto 6379     │     │
│                                └──────────────────┘     │
└─────────────────────────────────────────────────────────┘

Desde otra PC en la red (ej: 192.168.1.100):
  ┌──────────────┐
  │  Navegador   │──────▶ http://192.168.1.24:4200 (Angular)
  └──────────────┘              │
                                ▼
                        http://192.168.1.24:8000/api (Laravel)
```

---

## ✅ Checklist Final

- [ ] Docker y Docker Compose instalados
- [ ] Variables de entorno configuradas (.env)
- [ ] Contraseñas cambiadas
- [ ] Contenedores corriendo (`docker ps`)
- [ ] Health check funciona (`curl http://192.168.1.24:8000/api/health`)
- [ ] Firewall configurado (`sudo ufw status`)
- [ ] Angular configurado con la IP correcta
- [ ] CORS funcionando (no hay errores en consola de Angular)

---

## 📞 Endpoints Disponibles

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/health` | Verificar estado de la API |
| GET | `/api/test` | Probar CORS y conectividad |
| GET | `/api/user` | Usuario autenticado (requiere auth) |

**Agrega tus propios endpoints en:** `routes/api.php`

---

¡Listo! Tu backend Laravel está configurado y listo para recibir peticiones de Angular. 🎉

