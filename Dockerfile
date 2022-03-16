ARG PHP_VERSION=8.1-fpm-alpine3.15

FROM paramah/base:alpine as base-config

#
# Build php extenstions
#
#==================================================
FROM php:${PHP_VERSION} as builder

RUN apk add --no-cache --virtual build-essentials build-base \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev \
    wget \
	curl \
	bash \
	git \
	openssh \
	openssl \
	bzip2-dev \
	curl-dev \
	libpng libpng-dev \
	icu-dev \
    gettext gettext-dev \
    imap-dev \
    ldb-dev libldap openldap-dev \
    oniguruma-dev \
    postgresql-dev \
    sqlite sqlite-dev \
    libxml2-dev \
    libzip libzip-dev zip  \
    freetype-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    libssh2-dev \
    net-snmp \
    net-snmp-dev

COPY docker/ /

# Configure & install php extensions
RUN /usr/local/bin/php_configure.sh

#
# Final image
#
#==================================================
FROM php:${PHP_VERSION}
ARG ENVIRONMENT=production

# Add testing alpine repository
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && apk update

# install system libs
RUN apk add --no-cache libintl c-client libpng icu-libs libldap libpq libjpeg libwebp freetype libzip shadow sudo wget bash git openssh supervisor nginx openssl zip fluent-bit \
    && apk --no-cache upgrade && rm -rf /var/cache/apk/*

ENV DIR /var/www
ENV DOCKERIZE_VERSION v0.6.1

# Install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY --from=base-config /etc/supervisor /etc/supervisor
COPY --from=builder /usr/local/lib/php /usr/local/lib/php
COPY --from=builder /usr/local/etc /usr/local/etc

# Copy base files to docker container
COPY docker/ /

#PHP helper
RUN /usr/local/bin/php_helper.sh

#install cachetool
RUN wget -O /bin/cachetool http://gordalina.github.io/cachetool/downloads/cachetool.phar
RUN chmod a+x /bin/cachetool

# Create directories
RUN mkdir -p ${DIR}

WORKDIR $DIR

# Copy base configuration files
COPY docker/etc /etc/


EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]