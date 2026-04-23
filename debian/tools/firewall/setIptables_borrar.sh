#!/usr/bin/env bash
# 2023/03/09
source ./../utils.sh

INTERFAZ="ens33"
IPTABLES_PATH="/etc/iptables-persistent/"
FILE_SERVICE="/etc/systemd/system/iptables-persistent.service"
FILE_EXECUTE="restore.sh"
FILE_DUMPV4='$(date +%Y%m%d)_iptables_rules.v4'
FILE_DUMPV6='$(date +%Y%m%d)_iptables_rules.v6'

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


# Ir a la carpeta
cd "$IPTABLES_PATH"

# Detener el UFW
if ufw status | grep -q activo$; then
    ufw disable
    lg_prt "y" "\n[▲] El cortafuegos UFW fue deshabilitado\n"
fi

# Salvar configuración iptables
lg_prt "y" "\n\t LISTADO ORIGINAL"
iptables -L -nv --line-number
lg_prt "v" "\n\t LISTADO NUEVO"
iptables-save > "$(date +%Y%m%d)_iptables_rules.v4"
ip6tables-save > "$(date +%Y%m%d)_ip6tables_rules.v6"

# Limpiar reglas antetiores
iptables -F
ip6tables -F

# Limpiar cadenas
iptables -X
ip6tables -X

# Pondemos a 0 el contador de paquetes y bytes
iptables -Z
ip6tables -Z

# Limpiar la tabla NAT
iptables -t nat -F
ip6tables -t nat -F

# Política por defecto descartar todo (P Política de cadena)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

# Permitir localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Permitimos consultas DNS
iptables -A OUTPUT -d 1.1.1.1 -p udp --sport 1024:65535 --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -d 1.0.0.1 -p udp --sport 1024:65535 --dport 53 -m state --state NEW -j ACCEPT

# Permitir todo HTTP/S (CAMBIAR INTERFAZ)
#iptables -A OUTPUT -j ACCEPT -o $INTERFAZ -p tcp --sport 1024:65535 -m multiport --dports 80,443

# Permitir todo HTTPS siempre que se ejecute desde el grupo "INTERNET"
iptables -A OUTPUT -o $INTERFAZ -p tcp --sport 1024:65535 -m multiport --dports 80,443 -m owner --gid-owner internet -j ACCEPT

# Permitir qbittorrent siempre que se ejecute desde el grupo "INTERNET"
#iptables -A INPUT -o $INTERFAZ -p tcp --sport 1024:65535 -m multiport --dport 6881:6999 -m owner --gid-owner internet -j ACCEPT
#iptables -A OUTPUT -o $INTERFAZ -p tcp --sport 6881:6999 -m multiport --sport 6881:6999 -m owner --gid-owner internet -j ACCEPT

# Permitir conexiones entrantes que estén relacionadas o establecidas anteriormente, es decir, HTTP, HTTPS Y DNS
iptables -A INPUT -i $INTERFAZ -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables-save > "${IPTABLES_PATH}${FILE_DUMPV4}"
ip6tables-save > "${IPTABLES_PATH}${FILE_DUMPV6}"

iptables -L -nv --line-number



# ------------------ PERSISTENCIA

# Crear la carpeta si no existe
if [ ! -d "$IPTABLES_PATH" ]; then
    mkdir -p "$IPTABLES_PATH"
    lg_prt "g" "\t[✔] Carpeta ${IPTABLES_PATH} creada"
fi

# Crear archivo para el servicio de restauración de reglas
if [ ! -e "$FILE_EXECUTE" ]; then
    echo "#!/usr/bin/env bash" > "$FILE_EXECUTE"
    echo "flock /run/.iptables-restore iptables-restore < ${IPTABLES_PATH}${FILE_DUMPV4}" >> "$FILE_EXECUTE"
    echo "flock /run/.ip6tables-restore ip6tables-restore < ${IPTABLES_PATH}${FILE_DUMPV6}" >> "$FILE_EXECUTE"
    # Darle permisos de ejecución
    chmod +x "$FILE_EXECUTE"
    lg_prt "g" "\t[✔] Archivo a ejecutar ${FILE_EXECUTE} creado"
fi

# Crear servicio
if [ ! -e "$FILE_SERVICE" ]; then
cat << EOF > "$FILE_SERVICE"
[Unit]
Description=Service for iptables persistent
ConditionFileIsExecutable=${IPTABLES_PATH}${FILE_EXECUTE}
After=network.target

[Service]
Type=forking
ExecStart=${IPTABLES_PATH}${FILE_EXECUTE}
start TimeoutSec=0
RemainAfterExit=yes
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOF

    lg_prt "g" "\t[✔] Archivo de servicio ${FILE_SERVICE} creado"
    lg_prt "g" "\t[▲] Comprobando existencia del servicio ${FILE_SERVICE}"
    systemctl list-unit-files --type=service | grep iptables
    # Reiniciar servicio:           sudo systemctl restart iptables-persistent
    # Ver errores:                  sudo systemctl status iptables-persistent.service
fi

# Habilitar servicio
lg_prt "yby" "\n[▲] Ejecute el comando" "sudo systemctl enable iptables-persistent.service" "para iniciar el servicio\n"
lg_prt  "yw" "[▲] Compruebe que los archivos de reglas están disponibles en" "${IPTABLES_PATH}"
ls "${IPTABLES_PATH}"
# sudo systemctl enable iptables-persistent.service

# -------------------------------

lg_prt "g" "\n[✔] Tarea finalizada correctamente"
