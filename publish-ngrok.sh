#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Publicar Blue-Green con ngrok               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar ngrok
if ! command -v ngrok &> /dev/null; then
    echo -e "${RED} ngrok no instalado${NC}"
    echo ""
    echo "Instala con:"
    echo "curl -o ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip"
    echo "unzip ngrok.zip"
    echo "sudo mv ngrok /usr/local/bin/"
    exit 1
fi

# Verificar configuración
if ! ngrok config check &> /dev/null; then
    echo -e "${YELLOW}⚠️  ngrok no configurado${NC}"
    echo ""
    echo "1. Regístrate: https://dashboard.ngrok.com/signup"
    echo "2. Obtén token: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "3. Configura: ngrok config add-authtoken TU_TOKEN"
    echo ""
    read -p "¿Ya configuraste ngrok? (s/n): " configured
    if [ "$configured" != "s" ]; then
        open "https://dashboard.ngrok.com/signup"
        exit 1
    fi
fi

# Verificar servicios
echo -e "${YELLOW}📡 Verificando servicios...${NC}"
if ! docker ps | grep -q "nginx-proxy"; then
    echo -e "${RED} Servicios no están corriendo${NC}"
    echo ""
    read -p "¿Iniciar servicios ahora? (s/n): " start
    if [ "$start" == "s" ]; then
        ./deploy.sh
        sleep 30
        ./status.sh
    else
        echo "Ejecuta: ./deploy.sh"
        exit 1
    fi
fi

echo -e "${GREEN} Servicios activos${NC}"
echo ""

# Detectar entorno activo
ACTIVE_ENV=$(grep "server.*-environment" nginx.conf | grep -oP "(blue|green)" || echo "green")
if [ "$ACTIVE_ENV" == "blue" ]; then
    ENV_COLOR="${BLUE} BLUE${NC}"
    VERSION="v1.0.0"
else
    ENV_COLOR="${GREEN} GREEN${NC}"
    VERSION="v2.0.0"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "  Entorno activo: $ENV_COLOR ($VERSION)"
echo -e "  Blue:  http://localhost:8081"
echo -e "  Green: http://localhost:8082"
echo -e "  Nginx: http://localhost"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${MAGENTA} Iniciando túnel ngrok...${NC}"
echo ""
echo -e "${YELLOW} Para cambiar entre Blue/Green:${NC}"
echo "  1. Abre OTRA terminal"
echo "  2. cd $(pwd)"
echo "  3. ./switch.sh blue   (o green)"
echo ""

# Iniciar ngrok
LOG_FILE="/tmp/ngrok-$$.log"
ngrok http 80 --log=stdout > "$LOG_FILE" 2>&1 &
NGROK_PID=$!

echo -e "${CYAN}⏳ Estableciendo conexión...${NC}"
sleep 5

# Obtener URL pública
PUBLIC_URL=""
for i in {1..15}; do
    PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o 'https://[^"]*\.ngrok[^"]*' | head -1)
    if [ ! -z "$PUBLIC_URL" ]; then
        break
    fi
    sleep 1
done

if [ -z "$PUBLIC_URL" ]; then
    echo -e "${RED} No se pudo obtener la URL pública${NC}"
    kill $NGROK_PID 2>/dev/null
    exit 1
fi

clear
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               TÚNEL ACTIVO                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${MAGENTA}🌐 URL PÚBLICA (COPIA ESTA):${NC}"
echo ""
echo -e "   ${CYAN}$PUBLIC_URL${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW} Información:${NC}"
echo "  • Entorno: $ENV_COLOR ($VERSION)"
echo "  • Dashboard: http://localhost:4040"
echo "  • Blue: http://localhost:8081"
echo "  • Green: http://localhost:8082"
echo ""
echo -e "${CYAN} Para cambiar de entorno:${NC}"
echo "  1. Abre otra terminal"
echo "  2. cd $(pwd)"
echo "  3. ./switch.sh blue   (o green)"
echo "  4. Refresca tu URL pública"
echo ""
echo -e "${RED}⚠️  IMPORTANTE:${NC}"
echo "  • Mantén esta terminal abierta"
echo "  • Presiona Ctrl+C para detener"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Presiona Ctrl+C para detener el túnel...${NC}"

# Cleanup al salir
cleanup() {
    echo ""
    echo -e "${YELLOW} Deteniendo ngrok...${NC}"
    kill $NGROK_PID 2>/dev/null
    rm -f "$LOG_FILE"
    echo -e "${GREEN} Túnel cerrado${NC}"
    exit 0
}

trap cleanup INT TERM

wait $NGROK_PID
