FROM wordpress:6.5.4-php8.1-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd

# Allow upload of large files, e.g. templates, backups
COPY default.ini /usr/local/etc/php/conf.d/default.ini

# This code sets AllowOverride All in the default configuration
# for maximum flexibility (but not maximum security.)
RUN sed -i \
        -e '/<\/VirtualHost>/i\' \
        -e '        <Directory "/var/www/html">\' \
        -e '                Options Indexes FollowSymLinks MultiViews\' \
        -e '                AllowOverride All\' \
        -e '        </Directory>' \
        /etc/apache2/sites-available/000-default.conf
# Uncomment this if you have certificates to install.
# Certs should be placed in the same directory as the Dockerfile.
# COPY cert.pem /etc/ssl/certs/cert.pem
# COPY cert.key /etc/ssl/private/cert.key
# RUN sed -i \
#         -e "s/^\\s*SSLCertificateFile\\s.*/\t\tSSLCertificateFile \/etc\/ssl\/certs\/cert.pem/" \
#         -e "s/^\\s*SSLCertificateKeyFile\\s.*/\t\tSSLCertificateKeyFile \/etc\/ssl\/private\/cert.key/" \
#         /etc/apache2/sites-available/default-ssl.conf \
#     && a2enmod ssl \
#     && a2ensite default-ssl
