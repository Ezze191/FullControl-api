# Use PHP 8.1 with Apache
FROM php:8.1-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libgd-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache for local development
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options -Indexes +FollowSymLinks\n\
    </Directory>\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
    LogLevel info\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copy application files
COPY . /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Install Node.js dependencies and build assets
RUN npm install && npm run build

# Create .env file if it doesn't exist
RUN if [ ! -f .env ]; then \
    echo "APP_NAME=Laravel" > .env && \
    echo "APP_ENV=local" >> .env && \
    echo "APP_KEY=" >> .env && \
    echo "APP_DEBUG=true" >> .env && \
    echo "APP_URL=http://localhost:8000" >> .env && \
    echo "" >> .env && \
    echo "LOG_CHANNEL=stack" >> .env && \
    echo "LOG_DEPRECATIONS_CHANNEL=null" >> .env && \
    echo "LOG_LEVEL=debug" >> .env && \
    echo "" >> .env && \
    echo "DB_CONNECTION=mysql" >> .env && \
    echo "DB_HOST=db" >> .env && \
    echo "DB_PORT=3306" >> .env && \
    echo "DB_DATABASE=laravel" >> .env && \
    echo "DB_USERNAME=laravel" >> .env && \
    echo "DB_PASSWORD=laravel" >> .env && \
    echo "" >> .env && \
    echo "BROADCAST_DRIVER=log" >> .env && \
    echo "CACHE_DRIVER=file" >> .env && \
    echo "FILESYSTEM_DISK=local" >> .env && \
    echo "QUEUE_CONNECTION=sync" >> .env && \
    echo "SESSION_DRIVER=file" >> .env && \
    echo "SESSION_LIFETIME=120" >> .env && \
    echo "" >> .env && \
    echo "MEMCACHED_HOST=127.0.0.1" >> .env && \
    echo "" >> .env && \
    echo "REDIS_HOST=127.0.0.1" >> .env && \
    echo "REDIS_PASSWORD=null" >> .env && \
    echo "REDIS_PORT=6379" >> .env && \
    echo "" >> .env && \
    echo "MAIL_MAILER=smtp" >> .env && \
    echo "MAIL_HOST=mailpit" >> .env && \
    echo "MAIL_PORT=1025" >> .env && \
    echo "MAIL_USERNAME=null" >> .env && \
    echo "MAIL_PASSWORD=null" >> .env && \
    echo "MAIL_ENCRYPTION=null" >> .env && \
    echo "MAIL_FROM_ADDRESS=\"hello@example.com\"" >> .env && \
    echo "MAIL_FROM_NAME=\"\${APP_NAME}\"" >> .env && \
    echo "" >> .env && \
    echo "AWS_ACCESS_KEY_ID=" >> .env && \
    echo "AWS_SECRET_ACCESS_KEY=" >> .env && \
    echo "AWS_DEFAULT_REGION=us-east-1" >> .env && \
    echo "AWS_BUCKET=" >> .env && \
    echo "AWS_USE_PATH_STYLE_ENDPOINT=false" >> .env && \
    echo "" >> .env && \
    echo "PUSHER_APP_ID=" >> .env && \
    echo "PUSHER_APP_KEY=" >> .env && \
    echo "PUSHER_APP_SECRET=" >> .env && \
    echo "PUSHER_HOST=" >> .env && \
    echo "PUSHER_PORT=443" >> .env && \
    echo "PUSHER_SCHEME=https" >> .env && \
    echo "PUSHER_APP_CLUSTER=mt1" >> .env && \
    echo "" >> .env && \
    echo "VITE_PUSHER_APP_KEY=\"\${PUSHER_APP_KEY}\"" >> .env && \
    echo "VITE_PUSHER_HOST=\"\${PUSHER_HOST}\"" >> .env && \
    echo "VITE_PUSHER_PORT=\"\${PUSHER_PORT}\"" >> .env && \
    echo "VITE_PUSHER_SCHEME=\"\${PUSHER_SCHEME}\"" >> .env && \
    echo "VITE_PUSHER_APP_CLUSTER=\"\${PUSHER_APP_CLUSTER}\"" >> .env; \
fi

# Generate application key
RUN php artisan key:generate --force

# Clear and cache config
RUN php artisan config:clear && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Expose port 80 for local access
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
