#!/bin/bash

# Asegúrate de tener nmap instalado. Si no está instalado, puedes usar:
# sudo apt-get install nmap
# Para calcular la ip de la red junto con la mascara de red es necesario instalar:
# sudo apt-get install ipcalc
# El script mejor ejecutarlo con sudo

# Colores ANSI
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m' # No Color

# Instalación dependencias. Función para instalar un paquete si no está instalado
install_package_if_missing() {
  package_name="$1"
  if ! dpkg -l | grep -q "^ii\s*$package_name"; then
    echo "Instalando el paquete $package_name ..."
    sudo apt-get install -y "$package_name"
  else 
    echo "La dependencia del paquete $package_name ya está instalada"
    read -p "Presiona Enter para continuar..."
  fi
}

# Comprobar e instalar paquetes necesarios
install_package_if_missing nmap
install_package_if_missing ipcalc

# Función para mostrar la cabecera
cabecera() {
  clear
  echo -e "${AMARILLO}========================================"
  echo "         Herramienta de Escaneo"
  echo -e "========================================${NC}"
  echo -e "${VERDE}Interfaz seleccionada: $selected_interface"
  echo -e "${AMARILLO}Dirección IP: $ip_address${NC}"
  echo "Opción seleccionada: $1"
  echo "========================================"
}

# Mostrar lista de interfaces de red disponibles
interfaces=($(ip link | grep 'state UP' | awk -F: '{print $2}'))

clear

echo -e "${VERDE}Interfaces de red disponibles:${NC}"
for ((i=0; i<${#interfaces[@]}; i++)); do
  echo "$i: ${interfaces[$i]}"
done

# Pedir al usuario que seleccione una interfaz
while true; do
  read -p "Selecciona una interfaz (escribe el número): " interface_choice

  if [[ "$interface_choice" -ge 0 && "$interface_choice" -lt "${#interfaces[@]}" ]]; then
    selected_interface="${interfaces[$interface_choice]}"
    echo -e "${VERDE}Has seleccionado la interfaz: $selected_interface${NC}"
    break
  else
    echo -e "${ROJO}Opción inválida. Por favor, selecciona un número válido de interfaz.${NC}"
  fi
done

# Obtener la dirección IP de la interfaz seleccionada
ip_address=$(ip -o -4 addr show $selected_interface | awk '{print $4}')
echo -e "${VERDE}La dirección IP de $selected_interface es: $ip_address${NC}"

# Menú de opciones
while true; do
  clear
  cabecera "Menú"
  echo -e "${AMARILLO}Opciones:${NC}"
  echo "1. Escanear puertos abiertos en la red"
  echo "2. Escanear solo los puertos más comunes"
  echo "3. Escanear usando técnicas avanzadas (servicios y sistemas operativos)"
  echo "4. Guardar resultados del escaneo en un archivo"
  echo "5. Realizar un escaneo de ping en la red"
  echo "6. Ingresar argumentos adicionales de nmap"
  echo "7. Ver todas las opciones de nmap"
  echo "8. Agregar dirección IP específica para escaneo"
  echo "9. Conectar por ssh a una IP"
  echo "10. Salir"
  echo -e "========================================${NC}"
  read -p "Selecciona una opción (1-10): " option

  case $option in
    1)
      cabecera "Escanear puertos abiertos en la red"
      read -p "Escribe el rango de puertos a escanear (ejemplo: 1-999): " port_range
      echo -e "${AMARILLO}Escanendo puertos $port_range en la red $ip_address...${NC}"
      nmap -p $port_range $ip_address
      read -p "Presiona Enter para continuar..."
      ;;
    2)
      cabecera "Escanear solo los puertos más comunes"
      echo -e "${AMARILLO}Escanendo puertos más comunes en la red $ip_address...${NC}"
      nmap -F $ip_address
      read -p "Presiona Enter para continuar..."
      ;;
    3)
      cabecera "Escanear usando técnicas avanzadas"
      echo -e "${AMARILLO}Escanendo con técnicas avanzadas en la red $ip_address...${NC}"
      nmap -A $ip_address
      read -p "Presiona Enter para continuar..."
      ;;
    4)
      cabecera "Guardar resultados del escaneo en un archivo"
      read -p "Escribe el nombre del archivo para guardar los resultados: " output_file
      echo -e "${AMARILLO}Guardando resultados en $output_file...${NC}"
      nmap -p- $ip_address > $output_file
      echo -e "${VERDE}Resultados guardados en $output_file${NC}"
      read -p "Presiona Enter para continuar..."
      ;;
    5)
      cabecera "Realizar un escaneo de ping en la red"
      echo -e "${AMARILLO}Realizando un escaneo de ping en la red $ip_address...${NC}"
      
      base_ip=$(echo $ip_address | cut -d"." -f1-3)
      for i in $(seq 1 254); do
        ping -c 1 -W 1 $base_ip.$i
      done
      
      read -p "Presiona Enter para continuar..."
      ;;
    6)
      cabecera "Ingresar argumentos adicionales de nmap"
      read -p "Ingresa argumentos adicionales de nmap: " nmap_args
      echo -e "${AMARILLO}Ejecutando nmap con argumentos adicionales...${NC}"
      nmap $nmap_args $ip_address
      read -p "Presiona Enter para continuar..."
      ;;
    7)
      cabecera "Ver todas las opciones de nmap"
      echo -e "${AMARILLO}Mostrando todas las opciones de nmap...${NC}"
      nmap --help
      read -p "Presiona Enter para continuar..."
      ;;
    8)
      cabecera "Agregar dirección IP específica para escaneo"
      read -p "Ingresa la dirección IP específica para escaneo: " specific_ip
      echo -e "${AMARILLO}Escanendo la dirección IP $specific_ip...${NC}"
      nmap -p- $specific_ip
      read -p "Presiona Enter para continuar..."
      ;;
    9)
      cabecera "Conectar por SSH a una dirección IP"
      # Obtener la dirección de red de la interfaz seleccionada
      network=$(ip -o -4 addr show $selected_interface | awk '{print $4}' | cut -d'/' -f1)
      
      # Realizar el escaneo de direcciones IP y almacenarlas en una lista
      ip_list=($(nmap -sn $network/24 | grep 'Nmap scan report for' | awk '{print $NF}'))

      # Mostrar las direcciones IP encontradas
      echo -e "${YELLOW}Direcciones IP encontradas:${NC}"
      for ((i=0; i<${#ip_list[@]}; i++)); do
        echo "$i: ${ip_list[$i]}"
      done

      # Solicitar al usuario que elija una dirección IP para conectar por SSH
      read -p "Selecciona una dirección IP para conectar por SSH (escribe el número): " ssh_ip_choice

      if [[ "$ssh_ip_choice" -ge 0 && "$ssh_ip_choice" -lt "${#ip_list[@]}" ]]; then
        selected_ssh_ip="${ip_list[$ssh_ip_choice]}"
        echo -e "${GREEN}Conectando por SSH a la dirección IP: $selected_ssh_ip${NC}"
        ssh "$selected_ssh_ip"  # Utiliza el comando ssh para conectar por SSH
      else
        echo -e "${RED}Opción inválida. Por favor, selecciona un número válido de dirección IP.${NC}"
      fi

      read -p "Presiona Enter para continuar..."
      ;;


    *)
      echo -e "${ROJO}Opción inválida. Por favor, selecciona una opción válida (1-9).${NC}"
      read -p "Presiona Enter para continuar..."
      ;;
  esac
done