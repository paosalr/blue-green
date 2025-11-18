#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED} Error: Debes especificar el entorno${NC}"
    echo "Uso: ./switch.sh [blue|green]"
    exit 1
fi

ENV=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$ENV" != "blue" ] && [ "$ENV" != "green" ]; then
    echo -e "${RED} Error: Entorno inválido${NC}"
    echo "Usa: blue o green"
    exit 1
fi

echo -e "${YELLOW} Cambiando a entorno $ENV...${NC}"

cat > nginx.conf << EOFNGINX
worker_processes auto;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    upstream backend {
        server ${ENV}-environment:80;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOFNGINX

docker cp nginx.conf nginx-proxy:/etc/nginx/nginx.conf
docker exec nginx-proxy nginx -s reload

echo ""
echo -e "${GREEN} Cambio exitoso a $ENV!${NC}"
echo ""
echo "Verifica en: http://localhost"
echo ""
