#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${YELLOW} Deteniendo servicios Blue-Green...${NC}"
docker-compose down
echo -e "${GREEN} Servicios detenidos${NC}"
