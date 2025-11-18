#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Estado de Servicios               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW} Contenedores:${NC}"
docker-compose ps
echo ""

echo -e "${YELLOW} Health Checks:${NC}"
echo ""

echo -n " Blue (8081):  "
if curl -f -s http://localhost:8081 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
else
    echo -e "${RED}✗ DOWN${NC}"
fi

echo -n " Green (8082): "
if curl -f -s http://localhost:8082 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
else
    echo -e "${RED}✗ DOWN${NC}"
fi

echo -n " Nginx (80):   "
if curl -f -s http://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✓ UP${NC}"
else
    echo -e "${RED}✗ DOWN${NC}"
fi

echo ""
