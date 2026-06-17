FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    zip \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    xml

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory to the Laravel app (inside dashboard/)
WORKDIR /app

# Copy application files (dashboard/ contains the Laravel app)
COPY dashboard/ .

# Create minimal .env (actual env vars come from Render dashboard)
RUN echo "APP_KEY=" > .env && \
    mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views storage/logs && \
    chmod -R 777 bootstrap/cache storage

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Expose port
EXPOSE 8000

# Start server (NO config:cache — it freezes env() which TursoService needs)
CMD php artisan serve --host=0.0.0.0 --port=8000
