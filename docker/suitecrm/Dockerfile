FROM --platform=linux/amd64 php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    mariadb-client \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        pdo_mysql \
        mysqli \
        xml \
        zip \
        mbstring \
        curl \
        opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite ssl headers

# Set working directory
WORKDIR /var/www/html

# Copy SuiteCRM files
COPY . /var/www/html/

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/cache \
    /var/www/html/upload \
    /var/www/html/logs \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/cache \
    && chmod -R 775 /var/www/html/upload \
    && chmod -R 775 /var/www/html/logs

# Install Composer dependencies (include dev dependencies for testing)
RUN if [ -f composer.json ]; then \
    composer install --optimize-autoloader --no-scripts; \
    fi

# Configure PHP
COPY docker/suitecrm/php.ini /usr/local/etc/php/conf.d/suitecrm.ini

# Configure Apache
COPY docker/suitecrm/apache.conf /etc/apache2/sites-available/000-default.conf

# Copy startup script
COPY docker/suitecrm/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/index.php || exit 1

# Expose port
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]