########################################
# Stage 1: Build frontend assets (Vite)
########################################
FROM node:18-alpine AS assets

WORKDIR /app

# Copy only files needed to install and build assets
COPY package.json ./
# If you later add a lockfile, copy it too for better caching:
# COPY package-lock.json ./

RUN npm install --no-fund --no-audit
COPY resources ./resources
COPY vite.config.js ./
COPY public ./public

# Build production assets (outputs to public/build when using laravel-vite-plugin)
RUN npm run build

########################################
# Stage 2: PHP 8.2 + Apache app runtime
########################################
FROM php:8.2-apache

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
    libgd-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip \
    && docker-php-ext-install opcache

# Production opcache settings
RUN echo "opcache.enable=1\n" \
         "opcache.enable_cli=0\n" \
         "opcache.memory_consumption=128\n" \
         "opcache.interned_strings_buffer=16\n" \
         "opcache.max_accelerated_files=10000\n" \
         "opcache.validate_timestamps=0\n" \
         "opcache.save_comments=1\n" \
         > /usr/local/etc/php/conf.d/opcache.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache vhost
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options -Indexes +FollowSymLinks\n\
        Header always set Access-Control-Allow-Origin "*"\n\
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"\n\
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin"\n\
        Header always set Access-Control-Max-Age "3600"\n\
        RewriteEngine On\n\
        RewriteCond %{REQUEST_METHOD} OPTIONS\n\
        RewriteRule ^(.*)$ $1 [R=200,L]\n\
    </Directory>\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
    LogLevel warn\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copy composer manifests and install prod deps
COPY composer.json ./
COPY composer.lock ./
# Install dependencies using lockfile for reproducible builds
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Copy application source
COPY . /var/www/html

# Copy built assets from the assets stage
COPY --from=assets /app/public/build ./public/build

# Optimize autoload
RUN composer dump-autoload --optimize

# Permissions for Laravel writable dirs
RUN chown -R www-data:www-data /var/www/html \
    && find storage bootstrap/cache -type d -exec chmod 775 {} \; \
    && find storage bootstrap/cache -type f -exec chmod 664 {} \;

# Expose port 80
EXPOSE 80

# Health check (optional; path must exist in your routes)
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s \
    CMD curl -fsS http://localhost/ || exit 1

# Start Apache
CMD ["apache2-foreground"]
