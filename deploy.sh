#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Blue-Green Deployment - Deploy        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW} Deteniendo contenedores anteriores...${NC}"
docker-compose down 2>/dev/null || true

echo -e "${YELLOW} Construyendo imágenes...${NC}"
docker-compose build

echo -e "${YELLOW} Iniciando contenedores...${NC}"
docker-compose up -d

echo -e "${YELLOW} Esperando que los servicios estén listos...${NC}"
sleep 25

echo ""
echo -e "${GREEN}Despliegue completado!${NC}"
echo ""
echo -e "${BLUE} URLs de acceso:${NC}"
echo "  Blue:  http://localhost:8081"
echo "  Green: http://localhost:8082"
echo "  Nginx: http://localhost (apunta a Blue)"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  - Cambiar a Green: ./switch.sh green"
echo "  - Cambiar a Blue:  ./switch.sh blue"
echo "  - Ver estado:      ./status.sh"
echo "  - Detener todo:    ./stop.sh"
echo ""
