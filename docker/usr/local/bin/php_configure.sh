#!/bin/bash

PHP_VERSION=`php -r 'echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;'`
PHP_MODULES=("calendar" "bcmath" "bz2" "curl" "fileinfo" "gettext" "iconv" "imap" "intl" "ldap" "mbstring" "opcache" "pcntl" "pdo" "pdo_mysql" "pdo_pgsql" "pdo_sqlite" "pgsql" "phar" "session" "simplexml" "soap" "xml" "zip")

#
# Helper functions
#
declare -i term_width=80

h1() {
    declare border padding text
    border='\e[1;34m'"$(printf '=%.0s' $(seq 1 "$term_width"))"'\e[0m'
    padding="$(printf ' %.0s' $(seq 1 $(((term_width - $(wc -m <<<"$*")) / 2))))"
    text="\\e[1m$*\\e[0m"
    echo -e "$border"
    echo -e "${padding}${text}${padding}"
    echo -e "$border"
}

h2() {
    printf '\e[1;33m==>\e[37;1m %s\e[0m\n' "$*"
}


h1 "Configure PHP modules"
case $PHP_VERSION in
    '80' )
		h2 "[php8] Configure and install GD"
		docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
    	docker-php-ext-install -j$(nproc) gd

    ;;
    '74' )
		h2 "[php74] Configure and install GD"
    	docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
    	docker-php-ext-install -j$(nproc) gd
		h2 "Install json module"
    	docker-php-ext-install -j$(nproc) json
    ;;
    * )
		h2 "Configure and install GD"
		docker-php-ext-configure gd \
	         --with-freetype-dir=/usr/lib/ \
	         --with-png-dir=/usr/lib/ \
	         --with-jpeg-dir=/usr/lib/ \
	         --with-gd
	    docker-php-ext-install -j$(nproc) gd
		h2 "Install json module"
    	docker-php-ext-install -j$(nproc) json
    break
esac

h1 "Install PHP modules"
for i in "${!PHP_MODULES[@]}"
do
	num=$((i+1))
	h1 " (${num}/${#PHP_MODULES[@]}) > Install module: ${PHP_MODULES[$i]}"
	docker-php-ext-install -j$(nproc) ${PHP_MODULES[$i]}
done
