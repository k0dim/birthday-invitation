FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY infra/nginx /etc/nginx/conf.d
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
