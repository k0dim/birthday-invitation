set -e

IMAGE=ghcr.io/${{ github.repository }}/app:${{ github.sha }}

docker login ghcr.io -u ${{ secrets.GHCR_USERNAME }} -p ${{ secrets.GHCR_TOKEN }}
docker pull $IMAGE

# Проверяем, какие контейнеры существуют
if docker ps -a --format "{{.Names}}" | grep -q "^app_blue$"; then
    echo "Container app_blue exists"
fi

if docker ps -a --format "{{.Names}}" | grep -q "^app_green$"; then
    echo "Container app_green exists"
fi

# Определяем, какой контейнер старый, какой новый
RUNNING=$(docker ps --format "{{.Names}}" | grep app_ || true)

if [ "$RUNNING" = "app_blue" ]; then
  NEW=app_green
  OLD=app_blue
else
  NEW=app_blue
  OLD=app_green
fi

# Удаляем старый контейнер, если он существует
if docker ps -a --format "{{.Names}}" | grep -q "^$NEW$"; then
  echo "Removing existing $NEW container..."
  docker rm -f $NEW
fi

# Запускаем новый контейнер
docker run -d \
  --name $NEW \
  --network backend \
  -e GIT_COMMIT=${{ github.sha }} \
  $IMAGE

# Проверяем healthcheck
for i in {1..10}; do
  docker exec $NEW wget -qO- http://localhost:3000/health && break
  sleep 3
done

# Переключаем nginx
sed -i "s/$OLD/$NEW/g" /opt/birthday/nginx/upstream.conf
docker exec birthday_nginx nginx -s reload

# Удаляем старый контейнер
docker rm -f $OLD || true
