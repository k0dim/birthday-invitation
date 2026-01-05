# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Копируем package.json и устанавливаем зависимости
COPY package*.json ./
RUN npm ci --only=production

# Копируем исходный код
COPY . .

# Сборка с переменными окружения
ARG VITE_TELEGRAM_BOT_TOKEN
ARG VITE_TELEGRAM_CHAT_ID
ARG VITE_APP_VERSION

ENV VITE_TELEGRAM_BOT_TOKEN=$VITE_TELEGRAM_BOT_TOKEN
ENV VITE_TELEGRAM_CHAT_ID=$VITE_TELEGRAM_CHAT_ID
ENV VITE_APP_VERSION=$VITE_APP_VERSION
ENV VITE_BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Собираем приложение
RUN npm run build

# Создаем файл версии
RUN echo "$VITE_APP_VERSION-$(date +%Y%m%d%H%M%S)" > /app/dist/.version

# Production stage
FROM nginx:alpine

# Устанавливаем дополнительные инструменты для отладки
RUN apk add --no-cache curl

# Копируем собранное приложение
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем кастомную nginx конфигурацию
COPY infra/nginx/nginx.conf /etc/nginx/nginx.conf
COPY infra/nginx/default.conf /etc/nginx/conf.d/default.conf

# Здоровье чек
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Открываем порты
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]