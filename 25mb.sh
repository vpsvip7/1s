#!/bin/bash

# Configuración
INTERFACE="eth0"            # Cambiar por tu interfaz de red
LIMIT_GB=0.01                 # Límite de tráfico en GB
LOG_FILE="/var/traffic.log" # Archivo para guardar el consumo

# Verificar root
if [ "$(id -u)" != "0" ]; then
    echo "Ejecutar como root"
    exit 1
fi

# Crear archivo de registro si no existe
if [ ! -f "$LOG_FILE" ]; then
    echo "0" > "$LOG_FILE"
fi

# Obtener tráfico actual de iptables
RX_BYTES=$(iptables -L INPUT -vx | grep "$INTERFACE" | awk '{print $2}')
TX_BYTES=$(iptables -L OUTPUT -vx | grep "$INTERFACE" | awk '{print $2}')
TOTAL_BYTES=$((RX_BYTES + TX_BYTES))

# Convertir a GB (1 GB = 1073741824 bytes)
TOTAL_GB=$(echo "scale=2; $TOTAL_BYTES / 1073741824" | bc)

# Leer consumo acumulado
SAVED_GB=$(cat "$LOG_FILE")

# Sumar al total
NEW_TOTAL=$(echo "$SAVED_GB + $TOTAL_GB" | bc)

# Guardar nuevo total
echo "$NEW_TOTAL" > "$LOG_FILE"

# Reiniciar contadores de iptables
iptables -Z INPUT
iptables -Z OUTPUT

echo "Consumo actual: $NEW_TOTAL GB"

# Bloquear tráfico si se supera el límite
if [ $(echo "$NEW_TOTAL >= $LIMIT_GB" | bc) -eq 1 ]; then
    echo "¡Límite de $LIMIT_GB GB alcanzado! Bloqueando tráfico..."
    iptables -A INPUT -i "$INTERFACE" -j DROP
    iptables -A OUTPUT -o "$INTERFACE" -j DROP
fi