# 🔧 Solución: Puerto 3306 en Uso

## ❌ Error

```
ERROR: for db  Cannot start service db: failed to bind host port for 127.0.0.1:3306:172.18.0.3:3306/tcp: address already in use
```

## 🔍 Causa

El puerto 3306 (MySQL) ya está siendo usado por:
- MySQL instalado en Ubuntu
- Otro contenedor Docker
- Contenedor anterior que no se detuvo correctamente

## ✅ Solución Rápida (Recomendada)

**Opción A: No exponer el puerto MySQL** (más seguro)

El contenedor Laravel puede acceder a MySQL sin exponer el puerto al host.

---

## 🚀 APLICAR SOLUCIÓN AHORA

### Paso 1: Verificar qué está usando el puerto

```bash
# Ver qué usa el puerto 3306
sudo lsof -i :3306
# O
sudo netstat -tulpn | grep 3306
# O
sudo ss -tulpn | grep 3306
```

### Paso 2: Elegir una solución

#### ✅ **OPCIÓN A - No exponer MySQL (RECOMENDADO)**

MySQL solo será accesible desde dentro de Docker (más seguro).

```bash
cd ~/FullControl-api

# Editar docker-compose
nano docker-compose.prod.yml
```

Cambiar la sección de `db`:

**ANTES:**
```yaml
db:
  ports:
    - "127.0.0.1:3306:3306"
```

**DESPUÉS:**
```yaml
db:
  # ports:  # Comentar o eliminar esta línea
  #   - "127.0.0.1:3306:3306"
```

Guardar (Ctrl+O, Enter, Ctrl+X) y ejecutar:

```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

---

#### **OPCIÓN B - Detener MySQL del sistema**

Si tienes MySQL instalado en Ubuntu y NO lo necesitas:

```bash
# Detener MySQL del sistema
sudo systemctl stop mysql

# Deshabilitarlo para que no inicie automáticamente
sudo systemctl disable mysql

# Verificar que se detuvo
sudo systemctl status mysql

# Ahora ejecutar deploy
bash deploy.sh
```

---

#### **OPCIÓN C - Usar otro puerto**

Cambiar MySQL Docker a otro puerto (ej: 3307):

```bash
nano docker-compose.prod.yml
```

Cambiar:
```yaml
db:
  ports:
    - "127.0.0.1:3307:3306"  # Puerto 3307 en el host
```

---

#### **OPCIÓN D - Limpiar contenedores anteriores**

```bash
# Ver todos los contenedores (incluso detenidos)
docker ps -a

# Detener y eliminar contenedores con MySQL
docker stop $(docker ps -a -q --filter ancestor=mysql:8.0)
docker rm $(docker ps -a -q --filter ancestor=mysql:8.0)

# O eliminar por nombre
docker stop laravel_api_db
docker rm laravel_api_db

# Limpiar todo
docker-compose -f docker-compose.prod.yml down -v
docker system prune -af

# Reintentar
bash deploy.sh
```

---

## 🎯 Solución Permanente Recomendada

La mejor práctica es **NO exponer MySQL** al host. Laravel se conecta internamente en Docker.

### Modificar docker-compose.prod.yml:

```yaml
db:
  image: mysql:8.0
  container_name: laravel_api_db
  restart: always
  environment:
    MYSQL_DATABASE: ${DB_DATABASE:-laravel}
    MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:-rootpassword}
    MYSQL_USER: ${DB_USERNAME:-laravel}
    MYSQL_PASSWORD: ${DB_PASSWORD:-laravel}
  volumes:
    - db_data:/var/lib/mysql
    - ./docker/mysql/my.cnf:/etc/mysql/conf.d/my.cnf
  # NO exponer puerto - solo acceso interno
  # ports:
  #   - "127.0.0.1:3306:3306"
  networks:
    - laravel_network
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${DB_ROOT_PASSWORD:-rootpassword}"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 30s
```

### Ventajas:
- ✅ Más seguro (MySQL no accesible desde fuera)
- ✅ No hay conflictos de puertos
- ✅ Laravel se conecta internamente (red Docker)
- ✅ Performance ligeramente mejor

---

## 🔧 Comandos de Diagnóstico

```bash
# Ver qué proceso usa el puerto 3306
sudo lsof -i :3306

# Ver contenedores Docker corriendo
docker ps -a

# Ver contenedores que usan puertos
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Ver servicios de sistema
sudo systemctl list-units --type=service --state=running | grep mysql

# Ver todos los puertos en uso
sudo netstat -tulpn | grep LISTEN
```

---

## 📝 Después de Aplicar Solución

```bash
# 1. Limpiar
docker-compose -f docker-compose.prod.yml down -v

# 2. Verificar que 3306 está libre
sudo lsof -i :3306
# No debería mostrar nada

# 3. Desplegar
bash deploy.sh

# 4. Verificar contenedores
docker ps

# 5. Verificar conexión a base de datos
docker exec laravel_api_backend php artisan tinker
>>> DB::connection()->getPdo();
>>> exit

# 6. Probar API
curl http://192.168.1.24:8000/api/health
```

---

## 💡 Acceder a MySQL si NO expones el puerto

Si necesitas acceder a MySQL para debuggear:

```bash
# Opción 1: Desde el contenedor Laravel
docker exec -it laravel_api_backend php artisan tinker
>>> DB::select('SHOW DATABASES;');

# Opción 2: Directamente al contenedor MySQL
docker exec -it laravel_api_db mysql -u laravel -p
# Password: laravel_secure_password_change_this

# Opción 3: Port forwarding temporal
docker port laravel_api_db
ssh -L 3307:localhost:3306 usuario@192.168.1.24
# Conectar localmente en localhost:3307
```

---

## 🎯 MI RECOMENDACIÓN

**Usar OPCIÓN A (No exponer puerto MySQL)**

Es la solución más simple y segura:

1. No hay conflictos de puertos
2. MySQL solo accesible desde Laravel (más seguro)
3. No necesitas MySQL expuesto para nada

---

## ✅ Verificación Final

```bash
# Ver que los 3 contenedores están corriendo
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Deberías ver:
# laravel_api_backend   Up   0.0.0.0:8000->80/tcp
# laravel_api_db        Up   (SIN PUERTO EXPUESTO)
# laravel_api_redis     Up   (SIN PUERTO EXPUESTO)

# Probar conexión a BD desde Laravel
docker exec laravel_api_backend php artisan migrate:status

# Probar API
curl http://192.168.1.24:8000/api/health
```

---

**PRÓXIMO PASO:** Aplica la Opción A (más simple) o la que prefieras y ejecuta `bash deploy.sh` nuevamente.

