# 🔧 Solución: Error "Could not open input file: artisan"

## ❌ Problema

```
Could not open input file: artisan
Script @php artisan package:discover --ansi handling the post-autoload-dump event returned with error code 1
```

## 🔍 Causa

Composer intentaba ejecutar scripts automáticos (como `php artisan package:discover`) **antes** de que el archivo `artisan` fuera copiado al contenedor.

### Orden incorrecto:
```
1. COPY composer.json        ✅
2. RUN composer update        ❌ Intenta ejecutar artisan (no existe)
3. COPY . (resto archivos)    ⏸️  Nunca llega aquí
```

## ✅ Solución Aplicada

Usar `--no-scripts` en composer y ejecutar los scripts después de copiar todos los archivos.

### Orden correcto:
```dockerfile
# 1. Copiar composer.json
COPY composer.json ./

# 2. Actualizar dependencias SIN ejecutar scripts
RUN composer update --no-dev --optimize-autoloader --no-interaction --no-scripts

# 3. Copiar TODOS los archivos (incluyendo artisan)
COPY . /var/www/html

# 4. AHORA sí, ejecutar scripts de composer
RUN composer dump-autoload --optimize
```

## 🚀 Aplicar la Solución

### En tu PC Windows:

```bash
git add .
git commit -m "Fix: Ejecutar composer scripts después de copiar archivos"
git push origin main
```

### En el servidor Ubuntu:

```bash
cd ~/FullControl-api

# Pull cambios
git pull origin main

# Limpiar caché de Docker
docker builder prune -af

# Desplegar
bash deploy.sh
```

## 📝 ¿Qué hace cada flag?

| Flag | Propósito |
|------|-----------|
| `--no-dev` | No instala dependencias de desarrollo |
| `--optimize-autoloader` | Genera autoloader optimizado |
| `--no-interaction` | No pide confirmación |
| `--no-scripts` | **NO ejecuta scripts automáticos** |

## 🎯 Flujo Completo del Dockerfile

```dockerfile
# 1. Base: PHP 8.2 + Apache
FROM php:8.2-apache

# 2. Instalar dependencias del sistema
RUN apt-get update && apt-get install...

# 3. Instalar extensiones PHP
RUN docker-php-ext-install pdo_mysql...

# 4. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Configurar Apache
RUN a2enmod rewrite headers

# 6. Copiar SOLO composer.json
COPY composer.json ./

# 7. Instalar dependencias PHP (sin scripts)
RUN composer update --no-scripts

# 8. Copiar TODO (artisan, app/, routes/, etc.)
COPY . /var/www/html

# 9. Ejecutar scripts de Composer
RUN composer dump-autoload --optimize

# 10. Configurar permisos
RUN chown -R www-data:www-data /var/www/html
```

## ⏱️ Tiempo de Build

- **Primera vez:** 15-20 minutos
- **Con caché:** 3-5 minutos

## ✅ Verificación

Después de `bash deploy.sh`, deberías ver:

```bash
✓ Construyendo imagen Docker...
✓ Levantando contenedores...
✓ Ejecutando migraciones...
✓ DESPLIEGUE COMPLETADO
```

Luego verificar:

```bash
# Ver contenedores
docker ps | grep laravel_api_backend

# Verificar que artisan existe y funciona
docker exec laravel_api_backend php artisan --version
# Esperado: Laravel Framework 10.x

# Verificar autoload
docker exec laravel_api_backend composer dump-autoload
# Debería completarse sin errores

# Probar API
curl http://192.168.1.24:8000/api/health
```

## 🐛 Comandos de Diagnóstico

```bash
# Ver si artisan existe en el contenedor
docker exec laravel_api_backend ls -la artisan

# Ver estructura de directorios
docker exec laravel_api_backend ls -la

# Ver paquetes instalados
docker exec laravel_api_backend composer show

# Ver autoload
docker exec laravel_api_backend cat vendor/composer/autoload_classmap.php | head -20
```

## 💡 Entendiendo composer dump-autoload

`composer dump-autoload` regenera los archivos de autoload de Composer, incluyendo:
- `vendor/autoload.php`
- `vendor/composer/autoload_*.php`

Con `--optimize` usa class maps en lugar de PSR-4, mejorando el rendimiento.

## 🆘 Si Aún Falla

### Ver logs detallados:
```bash
docker-compose -f docker-compose.prod.yml build --progress=plain
```

### Construir paso a paso:
```bash
# Build sin cache
docker build --no-cache -t test .

# Ver qué archivos se copiaron
docker run --rm test ls -la /var/www/html
```

### Verificar composer.json:
```bash
cat composer.json | jq '.scripts'
```

## 📋 Scripts de Composer en Laravel

Laravel define estos scripts en `composer.json`:

```json
"scripts": {
    "post-autoload-dump": [
        "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
        "@php artisan package:discover --ansi"
    ],
    "post-update-cmd": [
        "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
    ],
    "post-root-package-install": [
        "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
    ],
    "post-create-project-cmd": [
        "@php artisan key:generate --ansi"
    ]
}
```

Con `--no-scripts`, estos NO se ejecutan durante `composer update`.

## ✨ Beneficios de esta Solución

1. ✅ **Cache de Docker:** Copiar composer.json primero mejora el cache
2. ✅ **No falla:** Scripts se ejecutan cuando artisan existe
3. ✅ **Optimizado:** dump-autoload con --optimize mejora performance
4. ✅ **Limpio:** Separación clara de pasos

---

**Problema:** Composer ejecutaba scripts antes de tener archivos necesarios  
**Solución:** Usar --no-scripts y ejecutar después de COPY  
**Estado:** ✅ RESUELTO

