#!/bin/bash
set -e

echo "🚀 Starting Laravel application..."

cd /var/www/html

# Ensure storage directories exist and have correct permissions
mkdir -p storage/logs
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p bootstrap/cache

# Create log file if it doesn't exist
touch storage/logs/laravel.log

# Set correct ownership and permissions
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
chmod 664 storage/logs/laravel.log 2>/dev/null || true

# Generate APP_KEY if not set
if [ -f .env ] && ( [ -z "$(grep 'APP_KEY=base64:' .env 2>/dev/null)" ] || [ "$(grep '^APP_KEY=$' .env 2>/dev/null)" != "" ] ); then
    echo "📝 Generating APP_KEY..."
    php artisan key:generate --force || true
fi

# Clear config cache
echo "⚙️ Optimizing configuration..."
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true

# Execute the main command (apache2-foreground)
echo "✅ Starting Apache..."
exec "$@"

