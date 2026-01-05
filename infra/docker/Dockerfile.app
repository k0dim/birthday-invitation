# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Копируем package.json и устанавливаем зависимости
COPY package*.json ./
RUN npm ci --only=production

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# Создаем файл с метаданными
RUN echo "version=$(node -p "require('./package.json').version")" > /app/dist/build-info.txt && \
    echo "build_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> /app/dist/build-info.txt && \
    echo "commit=${GITHUB_SHA:-local-build}" >> /app/dist/build-info.txt && \
    echo "$(date -u +'%Y%m%d%H%M%S')" > /app/dist/.version

# Production stage
FROM node:20-alpine

WORKDIR /app

# Копируем собранное приложение
COPY --from=build /app/dist ./dist

# Создаем простой сервер
RUN echo 'const http = require("http"); \
    const fs = require("fs"); \
    const path = require("path"); \
    const PORT = process.env.PORT || 3000; \
    \
    const mimeTypes = { \
      ".html": "text/html", \
      ".js": "text/javascript", \
      ".css": "text/css", \
      ".json": "application/json", \
      ".png": "image/png", \
      ".jpg": "image/jpeg", \
      ".gif": "image/gif", \
      ".svg": "image/svg+xml", \
      ".ico": "image/x-icon" \
    }; \
    \
    const server = http.createServer((req, res) => { \
      const filePath = req.url === "/" ? "/index.html" : req.url; \
      const extname = path.extname(filePath); \
      let contentType = mimeTypes[extname] || "application/octet-stream"; \
      \
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
      const fullPath = path.join(__dirname, filePath); \
      \
      fs.readFile(fullPath, (error, content) => { \
        if (error) { \
          if (error.code === "ENOENT") { \
            fs.readFile(path.join(__dirname, "/index.html"), (err, content) => { \
              if (err) { \
                res.writeHead(500); \
                res.end("Server Error"); \
              } else { \
                res.writeHead(200, { "Content-Type": "text/html" }); \
                res.end(content, "utf-8"); \
              } \
            }); \
          } else { \
            res.writeHead(500); \
            res.end("Server Error: " + error.code); \
          } \
        } else { \
          res.writeHead(200, { "Content-Type": contentType }); \
          res.end(content, "utf-8"); \
        } \
      }); \
    }); \
    \
    server.listen(PORT, () => { \
      console.log(`Server running on port ${PORT}`); \
    });' > server.js

# Открываем порт
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "server.js"]