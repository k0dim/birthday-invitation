# SSL Certificates

## For Development (Self-signed)

1. Generate self-signed certificate:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout selfsigned.key -out selfsigned.crt \
  -subj "/C=RU/ST=Samara/L=Samara/O=Birthday/CN=birthday.local"