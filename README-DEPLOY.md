# Деплой на VPS с nginx и SSL

## Предварительные требования

1. VPS с Ubuntu 20.04/22.04
2. Доменное имя (например, birthday.your-domain.com)
3. SSH доступ к серверу

## Настройка сервера

### 1. Начальная настройка
```bash
# На локальной машине
chmod +x deploy/setup-server.sh
./deploy/setup-server.sh