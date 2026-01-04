#!/bin/bash

# Генерация самоподписанного SSL сертификата
set -e

DOMAIN="dimaparty.ru"
SSL_DIR="/etc/nginx/ssl"

echo "🔐 Генерация самоподписанного SSL сертификата для $DOMAIN..."

sudo mkdir -p $SSL_DIR

# Генерация приватного ключа
sudo openssl genrsa -out $SSL_DIR/selfsigned.key 2048

# Генерация CSR
sudo openssl req -new -key $SSL_DIR/selfsigned.key -out $SSL_DIR/selfsigned.csr \
  -subj "/C=RU/ST=Samara/L=Samara/O=Birthday/CN=$DOMAIN"

# Генерация самоподписанного сертификата
sudo openssl x509 -req -days 365 -in $SSL_DIR/selfsigned.csr \
  -signkey $SSL_DIR/selfsigned.key -out $SSL_DIR/selfsigned.crt

# Установка прав
sudo chmod 600 $SSL_DIR/selfsigned.key
sudo chmod 644 $SSL_DIR/selfsigned.crt

echo "✅ SSL сертификат сгенерирован в $SSL_DIR"