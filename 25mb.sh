#!/bin/bash

# Configuración
INTERFACE="eth0"         # Nombre de la interfaz de red
LIMIT_MB=25              # Límite de tráfico en MB
BYTES_LIMIT=$((LIMIT_MB * 1024 * 1024))  # Convertir MB a bytes

# Verificar ejecución como root
if [ "$(id -u)" != "0" ]; then
    echo "Ejecutar como root"
    exit 1
fi

# Limpiar reglas anteriores (¡cuidado!)
iptables -F
iptables -X TRAFFIC_CTRL 2>/dev/null

# Crear cadena personalizada
iptables -N TRAFFIC_CTRL

# Redirigir tráfico a la cadena personalizada
iptables -A INPUT -i $INTERFACE -j TRAFFIC_CTRL
iptables -A OUTPUT -o $INTERFACE -j TRAFFIC_CTRL

# Reglas para limitar tráfico
iptables -A TRAFFIC_CTRL -m quota --quota $BYTES_LIMIT --bytes -j ACCEPT
iptables -A TRAFFIC_CTRL -j DROP

echo "Límite de $LIMIT_MB MB configurado para $INTERFACE (entrante y saliente combinados)"