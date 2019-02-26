FROM wordpress:4.9.6-php7.1-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
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
