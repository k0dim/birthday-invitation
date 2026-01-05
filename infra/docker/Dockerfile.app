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

# Production stage - используем Node.js для health check
FROM node:20-alpine

WORKDIR /app

# Копируем только dist
COPY --from=build /app/dist ./dist

# Создаем простой health check сервер
RUN echo 'const http = require("http"); \
    const fs = require("fs"); \
    const path = require("path"); \
    const PORT = process.env.PORT || 3000; \
    \
    const server = http.createServer((req, res) => { \
      if (req.url === "/health") { \
        res.writeHead(200, { "Content-Type": "text/plain" }); \
        res.end("OK"); \
        return; \
      } \
      \
      if (req.url === "/version") { \
        try { \
          const version = fs.readFileSync(path.join(__dirname, ".version"), "utf8"); \
          res.writeHead(200, { "Content-Type": "text/plain" }); \
          res.end(version); \
        } catch { \
          res.writeHead(404); \
          res.end("Not found"); \
        } \
        return; \
      } \
      \
      res.writeHead(404); \
      res.end("Not found"); \
    }); \
    \
    server.listen(PORT, () => { \
      console.log(`Health check server running on port ${PORT}`); \
    });' > server.js

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "server.js"]