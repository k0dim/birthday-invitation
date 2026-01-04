#!/bin/bash

# Скрипт деплоя на сервер
set -e

echo "🚀 Начало деплоя..."

# Переменные
APP_NAME="birthday-invitation"
APP_DIR="/var/www/$APP_NAME"
REPO_URL="https://github.com/k0dim/birthday-invitation.git"
BRANCH="main"
SERVER_IP="your-server-ip"
DEPLOY_USER="deploy"

# SSH команда
SSH_CMD="ssh $DEPLOY_USER@$SERVER_IP"

# 1. Клонирование/обновление репозитория
echo "📦 Клонирование репозитория..."
$SSH_CMD "
  if [ -d '$APP_DIR' ]; then
    cd $APP_DIR
    git pull origin $BRANCH
  else
    sudo mkdir -p $APP_DIR
    sudo chown $DEPLOY_USER:$DEPLOY_USER $APP_DIR
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
  fi
"

# 2. Установка зависимостей и сборка
echo "🔨 Сборка проекта..."
$SSH_CMD "
  cd $APP_DIR
  npm ci --only=production
  npm run build
"

# 3. Копирование конфигов nginx
echo "⚙️  Настройка nginx..."
$SSH_CMD "
  sudo cp $APP_DIR/infra/nginx/ssl.conf /etc/nginx/sites-available/$APP_NAME
  sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
  sudo nginx -t
  sudo systemctl reload nginx
"

# 4. Настройка systemd service (опционально)
echo "🔄 Настройка systemd service..."
$SSH_CMD "
  sudo cp $APP_DIR/infra/systemd/$APP_NAME.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable $APP_NAME.service
  sudo systemctl restart $APP_NAME.service
"

echo "✅ Деплой завершен! Приложение доступно по https://$DOMAIN"