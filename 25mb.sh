#!/bin/bash

# Configuración
INTERFACE="eth0"                 # Interfaz de red (ver con 'ip a')
LIMIT_MB=100                     # Límite total de tráfico (subida + bajada)
BYTES_LIMIT=$((LIMIT_MB * 1024 * 1024))  # Convertir MB a bytes
CHAIN_NAME="TRAFFIC_100MB"       # Nombre de la cadena iptables

# Verificar root
if [ "$(id -u)" != "0" ]; then
    echo " [!] Ejecuta como root: sudo $0"
    exit 1
fi

# Limpiar reglas anteriores
clean_rules() {
    iptables -D INPUT -i $INTERFACE -j $CHAIN_NAME 2>/dev/null
    iptables -D OUTPUT -o $INTERFACE -j $CHAIN_NAME 2>/dev/null
    iptables -F $CHAIN_NAME 2>/dev/null
    iptables -X $CHAIN_NAME 2>/dev/null
}

# Configurar límite
setup_limit() {
    clean_rules
    
    # Crear cadena personalizada
    iptables -N $CHAIN_NAME
    
    # Redirigir tráfico
    iptables -A INPUT -i $INTERFACE -j $CHAIN_NAME
    iptables -A OUTPUT -o $INTERFACE -j $CHAIN_NAME
    
    # Aplicar cuota
    iptables -A $CHAIN_NAME -m quota --quota $BYTES_LIMIT --bytes -j ACCEPT
    iptables -A $CHAIN_NAME -j DROP
    
    echo " [✓] Límite de $LIMIT_MB MB configurado en $INTERFACE"
}

# Mostrar consumo actual
show_usage() {
    RX=$(iptables -L $CHAIN_NAME -vx | awk '/ACCEPT/ {print $2}')
    TX=$(iptables -L $CHAIN_NAME -vx | awk '/ACCEPT/ {print $3}')
    TOTAL=$((RX + TX))
    TOTAL_MB=$((TOTAL / 1024 / 1024))
    
    echo " Consumo actual: $TOTAL_MB MB / $LIMIT_MB MB"
    echo " Bytes usados: $TOTAL bytes"
}

# Menú principal
case "$1" in
    "start")
        setup_limit
        ;;
    "status")
        show_usage
        ;;
    "reset")
        iptables -Z $CHAIN_NAME
        echo " [✓] Contadores reiniciados"
        ;;
    *)
        echo "Uso: $0 {start|status|reset}"
        echo "Ejemplos:"
        echo "  $0 start    # Activar límite"
        echo "  $0 status   # Ver consumo"
        echo "  $0 reset    # Reiniciar contador"
        exit 1
        ;;
esac