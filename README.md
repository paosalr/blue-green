# Blue-Green Deployment Project

## Descripción
Implementación de estrategia de despliegue Blue-Green usando Docker y Nginx.

## Uso

### Desplegar todo
```bash
./deploy.sh
```

### Cambiar entre entornos
```bash
./switch.sh blue   # Activar Blue
./switch.sh green  # Activar Green
```

### Ver estado
```bash
./status.sh
```

### Detener servicios
```bash
./stop.sh
```

## URLs
- **Blue directo**: http://localhost:8081
- **Green directo**: http://localhost:8082
- **Nginx proxy**: http://localhost

## Componentes
- Docker & Docker Compose
- Nginx como reverse proxy
- Blue Environment (v1.0.0)
- Green Environment (v2.0.0)

