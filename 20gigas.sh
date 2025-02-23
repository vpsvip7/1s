#!/bin/bash

   # Configuración
   USER_PORT="80"
   LIMIT_GB=20
   LIMIT_BYTES=$((LIMIT_GB * 1024 * 1024 * 1024))  # 20 GB en bytes
   TRAFFIC_LOG="/var/log/limiteduser_traffic.log"

   # Obtener contadores de iptables
   INPUT_BYTES=$(iptables -L USER_LIMIT -v -n -x | awk -v port="$USER_PORT" '/dpt:'port'/ {print $2}')
   OUTPUT_BYTES=$(iptables -L USER_LIMIT -v -n -x | awk -v port="$USER_PORT" '/spt:'port'/ {print $2}')
   TOTAL_BYTES=$((INPUT_BYTES + OUTPUT_BYTES))

   # Cargar total acumulado o inicializar
   if [ -f "$TRAFFIC_LOG" ]; then
       PREV_TOTAL=$(cat "$TRAFFIC_LOG")
   else
       PREV_TOTAL=0
   fi

   NEW_TOTAL=$((PREV_TOTAL + TOTAL_BYTES))

   # Verificar límite
   if [ "$NEW_TOTAL" -ge "$LIMIT_BYTES" ]; then
       echo "[!] Límite alcanzado. Bloqueando tráfico en puerto $USER_PORT..."
       sudo iptables -A INPUT -p tcp --dport "$USER_PORT" -j DROP
       sudo iptables -A OUTPUT -p tcp --sport "$USER_PORT" -j DROP
       exit 0
   else
       echo "$NEW_TOTAL" > "$TRAFFIC_LOG"
       echo "[+] Tráfico actual: $((NEW_TOTAL / 1024**3)) GB / $LIMIT_GB GB"
   fi