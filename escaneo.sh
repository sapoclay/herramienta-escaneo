#!/bin/bash

# Colores ANSI
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m' # No Color

# Función para instalar un paquete si no está instalado
instalar_paquete_sinosta() {
  package_name="$1"
  if ! dpkg -l | grep -q "^ii\s*$package_name"; then
    echo ""
    echo "Instalando el paquete $package_name ..."
    sudo apt-get install -y "$package_name"
    echo ""
  else 
    echo ""
    echo "La dependencia del paquete $package_name ya está instalada"
    echo ""
    read -p "Presiona Enter para continuar..."
  fi
}

# Comprobar e instalar paquetes necesarios
instalar_paquete_sinosta nmap
instalar_paquete_sinosta ipcalc
instalar_paquete_sinosta nc
instalar_paquete_sinosta tshark

# Función para mostrar la cabecera
cabecera() {
  clear
  echo -e "${AMARILLO}========================================"
  echo "         Herramienta de Escaneo"
  echo -e "========================================${NC}"
  echo -e "${VERDE}Interfaz seleccionada: $selected_interface"
  echo -e "${AMARILLO}Dirección IP del equipo: $ip_address${NC}"
  echo -e "${VERDE}La dirección de red de $selected_interface es: $network_ip${NC}"
  echo "========================================"
  echo "Opción seleccionada: $1"
  echo "========================================"
}

clear

# Obtener lista de interfaces de red disponibles
interfaces=($(ip link | grep 'state UP' | awk -F: '{print $2}'))

clear

echo -e "${VERDE}Interfaces de red disponibles:${NC}"
for ((i=0; i<${#interfaces[@]}; i++)); do
  echo "$i: Interfaz -> ${interfaces[$i]}"
done

# Pedir al usuario que seleccione una interfaz
while true; do
  read -p "Selecciona una interfaz (escribe el número): " interface_choice

  if [[ "$interface_choice" =~ ^[0-9]+$ && "$interface_choice" -ge 0 && "$interface_choice" -lt "${#interfaces[@]}" ]]; then
    selected_interface="${interfaces[$interface_choice]}"
    echo -e "${VERDE}Has seleccionado la interfaz: $selected_interface${NC}"

    # Obtener la dirección IP de la interfaz seleccionada
    ip_address=$(ip -o -4 addr show $selected_interface | awk '{print $4}' | cut -d"/" -f1)

    # Mostrar la cabecera nuevamente con los valores actualizados
    cabecera "Seleccionado"

    break
  else
    echo -e "${ROJO}Opción inválida. Por favor, selecciona un número válido de interfaz.${NC}"
  fi
done


# Obtener la dirección de red utilizando ip route
network_ip=$(ip route | grep "$selected_interface" | awk '/proto kernel/ {print $1}')

# Menú de opciones
while true; do
  clear
  cabecera "Menú"
  echo -e "${AMARILLO}Opciones:${NC}"
  echo "1. Escanear puertos abiertos"
  echo "2. Escanear solo los puertos más comunes"
  echo "3. Escanear usando técnicas avanzadas (servicios y sistemas operativos)"
  echo "4. Guardar resultados del escaneo en un archivo"
  echo "5. Realizar un escaneo de ping en la red"
  echo "6. Ingresar argumentos adicionales de nmap"
  echo "7. Ver todas las opciones de nmap"
  echo "8. Añadir dirección IP específica para escaneo"
  echo "9. Conectar por ssh a una IP"
  echo "10. Sniffear la red"
  echo "11. Enviar mensaje a una IP detectada"
  echo "12. Salir"
  echo -e "========================================${NC}"
  read -p "Selecciona una opción (1-12): " option


  case $option in
    1)
    cabecera "Escanear puertos abiertos"
    echo "1. Escanear puertos abiertos en toda la red"
    echo "2. Escanear puertos abiertos en una IP específica"
    read -p "Selecciona una opción (1-2): " scan_option

      case $scan_option in
        1)
          read -p "Escribe el rango de puertos a escanear (ejemplo: 1-999): " port_range
          echo -e "${AMARILLO}Escanendo puertos $port_range en toda la red...${NC}"
          nmap -p $port_range $ip_address
          ;;
        2)
          read -p "Escribe la dirección IP para escanear sus puertos: " target_ip
          read -p "Escribe el rango de puertos a escanear (ejemplo: 1-999): " port_range
          echo -e "${AMARILLO}Escanendo puertos $port_range en la IP $target_ip...${NC}"
          nmap -p $port_range $target_ip
          ;;
        *)
          echo -e "${ROJO}Opción inválida. Por favor, selecciona una opción válida (1-2).${NC}"
          ;;
      esac
      read -p "Presiona Enter para continuar..."
      ;;
    2)
      cabecera "Escanear puertos más comunes"
      echo "1. Escanear puertos más comunes en toda la red"
      echo "2. Escanear puertos más comunes en una IP específica"
      read -p "Selecciona una opción (1-2): " scan_option

        case $scan_option in
          1)
            echo -e "${AMARILLO}Escanendo puertos más comunes en toda la red...${NC}"
            nmap -F $ip_address
            ;;
          2)
            read -p "Escribe la dirección IP para escanear sus puertos más comunes: " target_ip
            echo -e "${AMARILLO}Escanendo puertos más comunes en la IP $target_ip...${NC}"
            nmap -F $target_ip
            ;;
          *)
            echo -e "${ROJO}Opción inválida. Por favor, selecciona una opción válida (1-2).${NC}"
            ;;
        esac
      read -p "Presiona Enter para continuar..."
      ;;
    3)
      cabecera "Escanear usando técnicas avanzadas"
      echo "1. Escanear usando técnicas avanzadas en toda la red"
      echo "2. Escanear usando técnicas avanzadas en una IP específica"
      read -p "Selecciona una opción (1-2): " scan_option

        case $scan_option in
          1)
            echo -e "${AMARILLO}Escanendo con técnicas avanzadas en toda la red...${NC}"
            nmap -A $ip_address
            ;;
          2)
            read -p "Escribe la dirección IP para escanear con técnicas avanzadas: " target_ip
            echo -e "${AMARILLO}Escanendo con técnicas avanzadas en la IP $target_ip...${NC}"
            nmap -A $target_ip
            ;;
          *)
            echo -e "${ROJO}Opción inválida. Por favor, selecciona una opción válida (1-2).${NC}"
            ;;
        esac
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
        active_ips=()  # Lista para almacenar las direcciones IP activas
        
        for i in $(seq 1 254); do
          if ping -c 1 -W 1 $base_ip.$i >/dev/null 2>&1; then
            echo "- La IP -> $base_ip.$i está activa"
            active_ips+=("$base_ip.$i")  # Agregar a la lista de direcciones IP activas
          fi
        done

        echo "-----------------------------------------------"  
      
        # Mostrar la lista de direcciones IP activas
        echo -e "${VERDE}Direcciones IP activas encontradas:${NC}"
        for ip in "${active_ips[@]}"; do
          echo "$ip"
        done
        
        read -p "Presiona Enter para continuar..."
        ;;
    6)
      cabecera "Escribe argumentos adicionales de nmap"
      read -p "Escribe argumentos adicionales de nmap: " nmap_args
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
      cabecera "Escribe una dirección IP específica para el escaneo"
      read -p "Escribe la dirección IP específica para escaneo: " specific_ip
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
      10) # Utilizamos tshark para capturar y leer los paquetes
        cabecera "Sniffear paquetes en la red"
        echo "1. Capturar paquetes en toda la red"
        echo "2. Capturar paquetes de una IP específica"
        echo "3. Guardar la captura de los paquetes de toda la red"
        echo "4. Guardar la captura de los paquetes de una IP específica"
        echo ""
        read -p "Selecciona una opción (1-5): " capture_option

          case $capture_option in
          1)
          echo -e "${YELLOW}Comenzando la captura de todo el tráfico en la red...${NC}"
          sudo tshark -i $selected_interface -Y "http or tls or dns"
          ;;
        2)
          read -p "Escribe la dirección IP para capturar sus paquetes: " capture_ip
          echo -e "${YELLOW}Comenzando la captura de paquetes DNS para la IP $capture_ip...${NC}"
          sudo tshark -i $selected_interface -Y "ip.src == $capture_ip and udp.port == 53"
          ;;
        3)
          echo -e "${YELLOW}Comenzando la captura de todo el tráfico en la red...${NC}"
          sudo tshark -i $selected_interface -w captura.pcap &
          echo -e "${YELLOW}Capturando datos de la red...${NC}"
          sleep 5  # Ajusta según sea necesario
          read -p "Captura completada. ¿Quieres leer el archivo captura.pcap? (s/n): " read_option
          if [[ "$read_option" == "s" ]]; then
            echo -e "${YELLOW}Leyendo el archivo captura.pcap...${NC}"
            tshark -r captura.pcap
          fi
          ;;
        4)
          read -p "Escribe la dirección IP para capturar sus paquetes: " capture_ip
          echo -e "${YELLOW}Comenzando la captura de paquetes para la IP $capture_ip...${NC}"
          sudo tshark -i $selected_interface -w captura.pcap
          echo -e "${YELLOW}Capturando datos de la IP $capture_ip...${NC}"
          sleep 5  # Ajusta según sea necesario
          read -p "Captura completada. ¿Quieres leer el archivo captura.pcap? (s/n): " read_option
          if [[ "$read_option" == "s" ]]; then
            echo -e "${YELLOW}Leyendo el archivo captura.pcap con filtro...${NC}"
            tshark -r captura.pcap -Y "ip.addr == $capture_ip"
          fi
          ;;
          *)
            echo -e "${RED}Opción inválida. Por favor, selecciona una opción válida (1-4).${NC}"
            ;;
        esac
        read -p "Presiona Enter para continuar..."
        ;;
      11) 
        cabecera "Enviar mensaje a una IP detectada"
        echo -e "${AMARILLO}Realizando un escaneo de ping en la red $ip_address...${NC}"

        # Realizar el escaneo de ping y almacenar las direcciones IP en una lista
        base_ip=$(echo $ip_address | cut -d"." -f1-3)
        ip_list=()
        for i in $(seq 1 254); do
          ping -c 1 -W 1 $base_ip.$i >/dev/null 2>&1
          if [[ $? -eq 0 ]]; then
            ip_list+=("$base_ip.$i")
          fi
        done

        # Mostrar las direcciones IP encontradas
        echo -e "${AMARILLO}Direcciones IP encontradas:${NC}"
        for ((i=0; i<${#ip_list[@]}; i++)); do
          echo "$i: ${ip_list[$i]}"
        done

        # Solicitar al usuario que elija una dirección IP para enviar el mensaje
        read -p "Selecciona una dirección IP para enviar el mensaje (escribe el número): " message_ip_choice

        if [[ "$message_ip_choice" -ge 0 && "$message_ip_choice" -lt "${#ip_list[@]}" ]]; then
          selected_message_ip="${ip_list[$message_ip_choice]}"
          read -p "Escribe el mensaje que deseas enviar a $selected_message_ip: " message
          read -p "Escribe el puerto al que deseas enviar el mensaje (123): " message_port
          echo -e "${GREEN}Enviando mensaje \"$message\" a la dirección IP: $selected_message_ip en el puerto $message_port${NC}"
          echo "$message" | nc -w 1 -u $selected_message_ip $message_port
        else
          echo -e "${RED}Opción inválida. Por favor, selecciona un número válido de dirección IP.${NC}"
        fi

        read -p "Presiona Enter para continuar..."
        ;;
      12)
        # Salir del programa
        echo ""
        echo "Saliendo del programa."
        echo ""
        exit 0
        ;;
    *)
      echo -e "${ROJO}Opción inválida. Por favor, selecciona una opción válida (1-9).${NC}"
      read -p "Presiona Enter para continuar..."
      ;;
  esac
done
