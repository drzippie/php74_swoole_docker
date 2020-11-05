FROM php:7.4.2-cli-alpine3.10
RUN apk add --no-cache bash $PHPIZE_DEPS openssl-dev
RUN yes '' | pecl install swoole
RUN docker-php-ext-enable swoole
RUN docker-php-source delete  && pecl clear-cache  && 	rm -rf /tmp/pear ~/.pearrc;
RUN docker-php-ext-install bcmath pcntl mysqli pdo_mysql
RUN set -ex && apk --no-cache add libxml2-dev
RUN docker-php-ext-install soap
RUN apk add --no-cache icu-dev && docker-php-ext-configure intl   && docker-php-ext-install intl
RUN apk add --no-cache libzip-dev && docker-php-ext-configure zip   && docker-php-ext-install zip
RUN apk add --no-cache gettext-dev && docker-php-ext-install gettext
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-freetype  \
    --with-jpeg && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev
RUN yes '' | pecl install inotify
RUN docker-php-ext-enable inotify
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
COPY dockerfiles/entrypoint.sh entrypoint
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app
COPY dockerfiles/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN apk add --no-cache openssl inotify-tools 
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
USER app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-a"]

