#!/bin/bash

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Uso: $0 <nginx|php|mariadb>"
    exit 1
fi

case "$SERVICE" in
    nginx)
        if ps ax | grep -v grep | grep -q "nginx: master process"; then
            echo "✓ Nginx está RODANDO"
            exit 0
        else
            echo "✗ Nginx está PARADO"
            exit 1
        fi
        ;;
    php)
        if ps ax | grep -v grep | grep -q "php-fpm: master process"; then
            echo "✓ PHP-FPM está RODANDO"
            exit 0
        else
            echo "✗ PHP-FPM está PARADO"
            exit 1
        fi
        ;;
    mariadb)
        if ps ax | grep -v grep | grep -q "mariadbd"; then
            echo "✓ MariaDB está RODANDO"
            exit 0
        else
            echo "✗ MariaDB está PARADO"
            exit 1
        fi
        ;;
    *)
        echo "Serviço inválido. Use: nginx, php ou mariadb"
        exit 1
        ;;
esac
