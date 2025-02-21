#!/bin/bash

# Configuración
INTERFACE="eth0"         # Nombre de tu interfaz de red (ver con 'ip a')
LIMIT_MB=25              # Límite total (subida + bajada)
BYTE_LIMIT=$((LIMIT_MB * 1024 * 1024))  # Convertir MB a bytes

# Verificar root
if [ "$(id -u)" != "0" ]; then
    echo "Ejecutar como root"
    exit 1
fi

# Limpiar reglas anteriores
iptables -F
iptables -X TRAFFIC_LIMITER 2>/dev/null

# Crear cadena personalizada
iptables -N TRAFFIC_LIMITER

# Redirigir tráfico a la cadena
iptables -A INPUT -i $INTERFACE -j TRAFFIC_LIMITER
iptables -A OUTPUT -o $INTERFACE -j TRAFFIC_LIMITER

# Aplicar límite de 25 MB
iptables -A TRAFFIC_LIMITER -m quota --quota $BYTE_LIMIT --bytes -j ACCEPT
iptables -A TRAFFIC_LIMITER -j DROP

# Mostrar consumo actual
RX=$(iptables -L TRAFFIC_LIMITER -vx | awk 'NR==3 {print $2}')
TX=$(iptables -L TRAFFIC_LIMITER -vx | awk 'NR==3 {print $3}')
TOTAL_MB=$(echo "scale=2; ($RX + $TX)/1048576" | bc)

echo "Límite de $LIMIT_MB MB configurado en $INTERFACE"
echo "Consumo actual: $TOTAL_MB MB"