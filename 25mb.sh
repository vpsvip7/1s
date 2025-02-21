#!/bin/bash

# Configuración
INTERFACE="eth0"               # Nombre de tu interfaz de red (usar ip a para verificar)
LIMIT_MB=25                    # Límite total de tráfico (subida + bajada)
BYTES_LIMIT=$((LIMIT_MB * 1024 * 1024))  # Convertir MB a bytes

# Verificar si se ejecuta como root
if [ "$(id -u)" != "0" ]; then
    echo "¡Ejecuta como root!"
    exit 1
fi

# Limpiar reglas anteriores
iptables -F
iptables -X TRAFFIC_LIMITER 2>/dev/null

# Crear cadena personalizada
iptables -N TRAFFIC_LIMITER

# Redirigir todo el tráfico a la cadena
iptables -A INPUT -i $INTERFACE -j TRAFFIC_LIMITER
iptables -A OUTPUT -o $INTERFACE -j TRAFFIC_LIMITER

# Aplicar límite de 25 MB
iptables -A TRAFFIC_LIMITER -m quota --quota $BYTES_LIMIT 
iptables -A TRAFFIC_LIMITER -j DROP

echo "Límite de $LIMIT_MB MB aplicado en $INTERFACE (tráfico combinado)"