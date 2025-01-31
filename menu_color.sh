#!/bin/bash

# Definir colores
rojo="\e[31m"
verde="\e[32m"
amarillo="\e[33m"
azul="\e[34m"
magenta="\e[35m"
cyan="\e[36m"
reset="\e[0m"

# Función para mostrar el menú
mostrar_menu() {
    clear
    echo -e "${azul}
    ██████╗  █████╗ ███████╗██╗  ██╗
    ██╔══██╗██╔══██╗██╔════╝██║  ██║
    ██████╔╝███████║███████╗███████║
    ██╔══██╗██╔══██║╚════██║██╔══██║
    ██████╔╝██║  ██║███████║██║  ██║
    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═║
    ${amarillo}===============================${reset}
    ${cyan}1.${reset} Mostrar fecha y hora
    ${cyan}2.${reset} Listar archivos
    ${cyan}3.${reset} Espacio en disco
    ${cyan}4.${reset} Salir
    ${amarillo}===============================${reset}
    "
}

# Bucle principal
while true; do
    mostrar_menu
    echo -ne "${verde}Seleccione una opción [1-4]: ${reset}"
    read opcion
    
    case $opcion in
        1)
            echo -e "\n${cyan}Fecha y hora:${reset} $(date)"
            read -p "Presione Enter para continuar..."
            ;;
        2)
            echo -e "\n${cyan}Archivos en el directorio:${reset}"
            ls -l --color=auto
            read -p "Presione Enter para continuar..."
            ;;
        3)
            echo -e "\n${cyan}Espacio en disco:${reset}"
            df -h | grep -v loop
            read -p "Presione Enter para continuar..."
            ;;
        4)
            echo -e "\n${verde}¡Hasta luego!${reset}\n"
            exit 0
            ;;
        *)
            echo -e "\n${rojo}Opción no válida!${reset}"
            sleep 1
            ;;
    esac
done