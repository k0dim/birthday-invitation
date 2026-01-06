#!/bin/bash
set -e

# Создаем сеть
docker network inspect backend >/dev/null 2>&1 || docker network create backend

# Запуск приложения
docker rm -f birthday_app || true
docker run -d --name birthday_app --network backend -p 3000:3000 ghcr.io/k0dim/birthday-invitation/app:latest

# Запуск nginx
docker rm -f birthday_nginx || true
docker run -d --name birthday_nginx --network backend -p 80:80 -p 443:443 \
    -v /opt/birthday/nginx/certs:/etc/letsencrypt \
    -v /opt/birthday/nginx/conf:/etc/nginx/conf.d \
    nginx:alpine
