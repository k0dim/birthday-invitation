# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Копируем package.json
COPY package*.json ./

# Устанавливаем все зависимости (нужен vite для сборки)
RUN npm ci

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# Создаем файл с метаданными
RUN VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*"version": "\([^"]*\).*/\1/') && \
    echo "version=$VERSION" > /app/dist/build-info.txt && \
    echo "build_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> /app/dist/build-info.txt && \
    echo "commit=${GITHUB_SHA:-local-build}" >> /app/dist/build-info.txt && \
    echo "$(date -u +'%Y%m%d%H%M%S')" > /app/dist/.version

# Production stage - используем Nginx
FROM nginx:alpine

# Копируем собранное приложение
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем nginx конфигурацию
COPY infra/nginx/nginx.conf /etc/nginx/nginx.conf
COPY infra/nginx/sites/app.conf /etc/nginx/conf.d/default.conf

# Создаем health check endpoint
RUN echo 'location /health { return 200 "healthy\n"; add_header Content-Type text/plain; }' > /etc/nginx/conf.d/health.conf
RUN echo 'location /version { alias /usr/share/nginx/html/.version; add_header Content-Type text/plain; }' >> /etc/nginx/conf.d/health.conf

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]