#!/bin/bash

INTERFACE="eth0"
LIMIT_MB=100
BYTES_LIMIT=$((LIMIT_MB * 1024 * 1024))
CHAIN_NAME="TRAFFIC_LIMITER"

# Cargar módulo necesario
sudo modprobe xt_quota

# Limpiar reglas anteriores
sudo iptables -D INPUT -i $INTERFACE -j $CHAIN_NAME 2>/dev/null
sudo iptables -D OUTPUT -o $INTERFACE -j $CHAIN_NAME 2>/dev/null
sudo iptables -F $CHAIN_NAME 2>/dev/null
sudo iptables -X $CHAIN_NAME 2>/dev/null

# Crear cadena y reglas
sudo iptables -N $CHAIN_NAME
sudo iptables -A INPUT -i $INTERFACE -j $CHAIN_NAME
sudo iptables -A OUTPUT -o $INTERFACE -j $CHAIN_NAME

# Regla corregida para quota
sudo iptables -A $CHAIN_NAME -m quota --quota $BYTES_LIMIT -j ACCEPT
sudo iptables -A $CHAIN_NAME -j DROP

echo "Límite de $LIMIT_MB MB aplicado"