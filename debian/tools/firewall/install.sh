#!/usr/bin/env bash
# 2023/03/09
source ./../utils.sh

INTERFAZ="ens160"
FILE_DUMPV4='rules.v4'
FILE_DUMPV6='rules.v6'
NUM_RAND="$(shuf -i 1-100000 -n 1)"

<<COMMENT
    - Deshabilitar IVP6 Manualmente

    - Añadir grupo
        groupadd internet
        cat /etc/group | grep internet
        cat /etc/gshadow | grep internet

    - Obtener ruta del binario de firefox
        which firefox

    - Ejecutar Firefox desde grupo internet
        xhost +
        xhost si:localuser:root
        sg internet -c firefox
        xhost -si:localuser:root

    - Ver el grupo en el que se ejecuta una aplicación
        ps -eo "user,group,args" | grep firefox


# Restaurar configuración iptables
# iptables -F
# iptables -L -nv --line-number
# iptables-restore < savedrules.txt
COMMENT

if [[ "$EUID" != 0 ]]; then
	 lg_prt "r" "[✖] Es necesario tener permisos ROOT"
	 exit 1
fi

# Se ejecuta al pulsar Ctrl+C
trap ctrl_c INT

function ctrl_c() {
    lg_prt "y" "\n[▲] Saliendo con interrupción"
	exit 1
}

# Crear backups
lg_prt "b" "\nCreando copias de seguridad de la configuración actual ..."
iptables-save > "backups/$(date +%Y%m%d)T$(date +%H%M%S)_iptables_rules.v4"
ip6tables-save > "backups/$(date +%Y%m%d)T$(date +%H%M%S)_ip6tables_rules.v6"

# Limpiar reglas anteriores
iptables -F
ip6tables -F
lg_prt "g" "[✔] Limpiar reglas anteriores"

# Limpiar cadenas
iptables -X
ip6tables -X
lg_prt "g" "[✔] Limpiar cadenas"

# Pondemos a 0 el contador de paquetes y bytes
iptables -Z
ip6tables -Z
lg_prt "g" "[✔] Resetear el contador de paquetes"

# Limpiar la tabla NAT
iptables -t nat -F
ip6tables -t nat -F
lg_prt "g" "[✔] Limpiar reglas NAT"

# Política por defecto descartar todo (P Política de cadena)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
lg_prt "g" "[✔] Establecido DROP (no permitir nada) por defecto"

# Permitir localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
lg_prt "g" "[✔] Permitir conectiones interna (bucle) lo"

# Permitimos consultas DNS --sport 1024:65535
iptables -A OUTPUT -d 1.1.1.1 -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -d 1.0.0.1 -p udp --dport 53 -m state --state NEW -j ACCEPT
lg_prt "g" "[✔] Permitir DNS de Cloudflare"

# Permitir todo HTTP/S (CAMBIAR INTERFAZ) --sport 1024:65535
iptables -A OUTPUT -o $INTERFAZ -p tcp -m multiport --dports 80,443 -j ACCEPT
lg_prt "g" "[✔] Permitir conexiones HTTP/S"


# Permitir todo HTTPS siempre que se ejecute desde el grupo "INTERNET" --sport 1024:65535
# iptables -A OUTPUT -o $INTERFAZ -p tcp -m multiport --dports 80,443 -m owner --gid-owner internet -j ACCEPT

# Permitir qbittorrent siempre que se ejecute desde el grupo "INTERNET"
#iptables -A INPUT -o $INTERFAZ -p tcp --sport 1024:65535 -m multiport --dport 6881:6999 -m owner --gid-owner internet -j ACCEPT
#iptables -A OUTPUT -o $INTERFAZ -p tcp --sport 6881:6999 -m multiport --sport 6881:6999 -m owner --gid-owner internet -j ACCEPT

# Permitir conexiones entrantes que estén relacionadas o establecidas anteriormente, es decir, HTTP, HTTPS Y DNS
iptables -A INPUT -i $INTERFAZ -m state --state ESTABLISHED,RELATED -j ACCEPT
lg_prt "g" "[✔] Permitir conexiones existentes"


mkdir -p /etc/iptables
iptables-save > "/etc/iptables/${FILE_DUMPV4}"
ip6tables-save > "/etc/iptables/${FILE_DUMPV6}"
lg_prt "g" "[✔] Guardar reglas en /etc/iptables/"

#iptables-restore < "${FILE_DUMPV4}"
#ip6tables-restore < "${FILE_DUMPV6}"
#lg_prt "g" "[✔] Restaurar reglas"

# Instalar persistencia
if [[ -x "$(which iptables-persistent)" ]]; then
    lg_prt "ywy" "[▲] El programa" "\"iptables-persistent\"" "ya estaba desinstalado"
else
    apt install iptables-persistent
    lg_prt "gwg" "[✔]" "\"iptables-persistent\"" "instalado"
fi

lg_prt "y" "\n\n Configuración actual\n"
iptables -L -nv --line-number
lg_prt "y" "\n"
