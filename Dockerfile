# Use PHP 8.2 with Apache
FROM php:8.2-apache

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
    libgd-dev \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules for API
RUN a2enmod rewrite headers

# Configure Apache for API backend
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    \n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options -Indexes +FollowSymLinks\n\
        \n\
        # Enable CORS headers\n\
        Header always set Access-Control-Allow-Origin "*"\n\
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"\n\
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin"\n\
        Header always set Access-Control-Max-Age "3600"\n\
        \n\
        # Handle preflight requests\n\
        RewriteEngine On\n\
        RewriteCond %{REQUEST_METHOD} OPTIONS\n\
        RewriteRule ^(.*)$ $1 [R=200,L]\n\
    </Directory>\n\
    \n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
    LogLevel warn\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copy composer.json first
COPY composer.json ./

# Generate fresh composer.lock with PHP 8.2 and install dependencies (without scripts)
RUN composer update --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copy rest of application files
COPY . /var/www/html

# Run composer scripts after all files are in place
RUN composer dump-autoload --optimize

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD curl -f http://localhost/api/health || exit 1

# Start Apache
CMD ["apache2-foreground"]
