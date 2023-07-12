FROM php:7.3-apache

RUN apt-get update && apt-get install --no-install-recommends -y \
		libpng-dev \
		libjpeg-dev \
		libfreetype6-dev \
                libjpeg62-turbo-dev \
                libzip-dev \
                libmagickwand-dev \
                libpq-dev \
                nano \
                sudo \
                iputils-ping \
		postgresql-client \
		openssh-client \
		autossh \
		net-tools \
		iproute2 \
		netbase \
        && update-ca-certificates --fresh \
        && rm -rf /var/lib/apt/lists/* \
        && printf "\n" | pecl install imagick \
        && curl -s https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz | \
           tar zxf - ioncube/ioncube_loader_lin_7.3.so \
        && mv ioncube/ioncube_loader_lin_7.3.so `php-config --extension-dir` \
        && rm -Rf ioncube \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install -j$(nproc) zip \
        && docker-php-ext-install -j$(nproc) pdo \
        && docker-php-ext-install -j$(nproc) pgsql \
        && docker-php-ext-install -j$(nproc) pdo_pgsql \
        && docker-php-ext-install -j$(nproc) sockets \
        && docker-php-ext-enable imagick ioncube_loader_lin_7.3 \
        && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
        && sed -i '/^upload_max_filesize/s/\([^=]*\).*/\1 = 32M/' "$PHP_INI_DIR/php.ini" \
        && sed -i '/^post_max_size/s/\([^=]*\).*/\1 = 32M/' "$PHP_INI_DIR/php.ini" \
	&& a2enmod ssl proxy proxy_html rewrite headers

RUN mkdir /var/www/scanywhere

EXPOSE 80 443

WORKDIR /var/www/html

#ENTRYPOINT ["/bin/sh", "-c", "/entrypoint.sh"]
