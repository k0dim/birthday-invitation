#!/bin/bash

# Скрипт начальной настройки сервера
set -e

echo "🚀 Начало настройки сервера..."

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка необходимых пакетов
sudo apt install -y nginx certbot python3-certbot-nginx git curl

# Настройка firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Создание пользователя для деплоя
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG sudo deploy

# Настройка SSH ключа (замените на свой)
echo "Добавьте ваш SSH публичный ключ в ~/.ssh/authorized_keys для пользователя deploy"

echo "✅ Настройка сервера завершена!"