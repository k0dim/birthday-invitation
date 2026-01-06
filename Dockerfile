FROM nginx:alpine

# Копируем React сборку
COPY dist /usr/share/nginx/html

# Копируем статические файлы для /health и /version
COPY infra/nginx/html/ /usr/share/nginx/html/

# Копируем конфиги Nginx
COPY infra/nginx/upstream.conf /etc/nginx/conf.d/upstream.conf
COPY infra/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
