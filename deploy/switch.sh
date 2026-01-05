#!/bin/bash
set -e

NEW=$1
OLD=$2

echo "Switching from $OLD to $NEW"

sed -i "s/$OLD/$NEW/g" infra/nginx/conf.d/upstream.conf
docker exec birthday_nginx nginx -s reload

docker stop $OLD || true
docker rm $OLD || true
