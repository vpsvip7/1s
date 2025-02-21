#!/bin/bash

# Configuración
INTERFACE="eth0"            # Interfaz de red
MODE="limit"                # Modos: limit, throttle, monitor
LIMIT_MB=100                # Límite total en MB
THROTTLE_SPEED="500kbit"    # Velocidad máxima (para modo throttle)
LOG_FILE="/var/traffic.log" # Archivo de registro

# Validar ejecución como root
if [ "$(id -u)" != "0" ]; then
    echo " [!] Debes ejecutar como root"
    exit 1
fi

# Limpiar reglas anteriores
clean_rules() {
    iptables -F
    iptables -X TRAFFIC_CONTROL 2>/dev/null
    tc qdisc del dev $INTERFACE root 2>/dev/null
}

# Modo 1: Límite de tráfico absoluto
set_traffic_limit() {
    clean_rules
    BYTES_LIMIT=$((LIMIT_MB * 1024 * 1024))
    
    iptables -N TRAFFIC_CONTROL
    iptables -A INPUT -i $INTERFACE -j TRAFFIC_CONTROL
    iptables -A OUTPUT -o $INTERFACE -j TRAFFIC_CONTROL
    
    iptables -A TRAFFIC_CONTROL -m quota --quota $BYTES_LIMIT  -j ACCEPT
    iptables -A TRAFFIC_CONTROL -j DROP
    
    echo "$(date) - Límite de $LIMIT_MB MB establecido" >> $LOG_FILE
}

# Modo 2: Throttle de velocidad
set_throttle() {
    clean_rules
    tc qdisc add dev $INTERFACE root handle 1: htb
    tc class add dev $INTERFACE parent 1: classid 1:1 htb rate $THROTTLE_SPEED
    tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1
    iptables -t mangle -A POSTROUTING -o $INTERFACE -j MARK --set-mark 1
    
    echo "$(date) - Throttle de $THROTTLE_SPEED aplicado" >> $LOG_FILE
}

# Modo 3: Monitoreo en tiempo real
monitor_traffic() {
    echo " [*] Monitoreo de tráfico (Ctrl+C para detener)"
    watch -n 2 "iptables -L TRAFFIC_CONTROL -vx | grep -A 1 TRAFFIC_CONTROL"
}

# Mostrar ayuda
show_help() {
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -i <interfaz>   Especificar interfaz de red (default: eth0)"
    echo "  -m <modo>       Modos: limit, throttle, monitor"
    echo "  -l <MB>         Límite en MB (para modo limit)"
    echo "  -s <velocidad>  Velocidad (ej: 1mbit, 500kbit) para modo throttle"
    echo "  -r              Reiniciar contadores"
    echo "  -h              Mostrar ayuda"
}

# Procesar parámetros
while getopts "i:m:l:s:rh" opt; do
    case $opt in
        i) INTERFACE="$OPTARG";;
        m) MODE="$OPTARG";;
        l) LIMIT_MB="$OPTARG";;
        s) THROTTLE_SPEED="$OPTARG";;
        r) clean_rules
           echo " [✓] Contadores reiniciados"
           exit 0;;
        h) show_help
           exit 0;;
        *) echo "Opción inválida"
           exit 1;;
    esac
done

# Ejecutar modo seleccionado
case $MODE in
    "limit") set_traffic_limit;;
    "throttle") set_throttle;;
    "monitor") monitor_traffic;;
    *) echo "Modo no válido. Usar: limit, throttle, monitor"
       exit 1;;
esac

echo " [✓] Configuración aplicada en $INTERFACE"