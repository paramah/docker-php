#!/bin/sh

PHP_VERSION=`php -r 'echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;'`

echo "Actual environment: ${ENVIRONMENT}"

if [ -f /usr/local/etc/php/php.ini-$ENVIRONMENT ]; then
	mv /usr/local/etc/php/php.ini-$ENVIRONMENT /usr/local/etc/php/php.ini
fi
 

if [ $PHP_VERSION == '72' ]; then 
	wget -O /bin/composer https://getcomposer.org/composer-1.phar
else 
	wget -O /bin/composer https://getcomposer.org/composer.phar 
fi

chmod a+x /bin/composer
