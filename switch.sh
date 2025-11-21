#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}✗ Error: Debes especificar el entorno${NC}"
    echo "Uso: ./switch.sh [blue|green]"
    exit 1
fi

ENV=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$ENV" != "blue" ] && [ "$ENV" != "green" ]; then
    echo -e "${RED}✗ Error: Entorno inválido${NC}"
    echo "Usa: blue o green"
    exit 1
fi

echo -e "${YELLOW}⚙️  Cambiando a entorno $ENV...${NC}"

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

echo -e "${YELLOW} Archivo nginx.conf actualizado${NC}"

if [ ! -f nginx.conf ]; then
    echo -e "${RED}✗ Error: No se pudo crear nginx.conf${NC}"
    exit 1
fi

echo -e "${YELLOW} Recargando Nginx...${NC}"

docker-compose restart nginx

echo -e "${YELLOW} Esperando que Nginx se reinicie...${NC}"
sleep 3

# Verificar que Nginx esté funcionando
if curl -f -s http://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Nginx reiniciado correctamente${NC}"
else
    echo -e "${RED}✗ Error: Nginx no responde${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Cambio exitoso a $ENV!${NC}"
echo ""
echo -e "${BLUE} URLs de acceso:${NC}"
echo "  Nginx Proxy: http://localhost"
echo "  Blue directo: http://localhost:8081"
echo "  Green directo: http://localhost:8082"
echo ""
echo -e "${YELLOW} Verifica el cambio:${NC}"
echo "  curl http://localhost"
echo ""