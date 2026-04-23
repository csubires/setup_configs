#!/usr/bin/env bash
# 2023/07/04
source ./utils.sh


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

# Comprobar si la aplicación está instalada y desinstalarla
function check_install() {
	if [[ -x "$(which $1)" ]]; then
		apt remove $1
		lg_prt "gwg" "[✔]" "\"$1\"" "desinstalado"
	else
		lg_prt "ywy" "[▲] El programa" "\"$1\"" "ya estaba desinstalado"
	fi
}

# Deshabilitar un servicio
function disable_service() {
	if systemctl is-active --quiet $1; then
		systemctl stop $1
		systemctl disable $1
		lg_prt "gwg" "[✔]" "\"$1\"" "deshabilitado"
	else
		lg_prt "ywy" "[▲] El servicio" "\"$1\"" "ya estaba deshabilitado"
	fi
}

lg_prt "b" "\n Desinstalando programas innecesarios ..."
check_install hexchat
check_install webapp-manager
check_install thingy
check_install thunderbird
check_install bulky
check_install onboard
check_install warpinator
check_install pix
check_install transmission transmission-common transmission-gtk
check_install hypnotix
check_install celluloid
check_install rhythmbox

lg_prt "b" "\n Deshabilitando servicios innecesarios ..."
lg_prt "v" "[▲] Deshabilitar logs del sistema"
disable_service rsyslog
lg_prt "v" "[▲] Deshabilitar bluetooh"
disable_service bluetooth
disable_service bluetooth-mechanism
lg_prt "v" "[▲] Deshabilitar openVPN"
disable_service openvpn
lg_prt "v" "[▲] Deshabilitar ufw"
disable_service ufw

lg_prt "b" "\nDeshabilitando servicios con puertos abiertos ..."
lg_prt "v" "[▲] Deshabilitar IPP (Internet Printing Protocol) - Puerto 631"
disable_service cups
disable_service cups-browsed
lg_prt "v" "[▲] Deshabilitar multicast DNS - Puerto 5353"
disable_service avahi-daemon

lg_prt "v", "\n\n - Para deshabilitar el puerto 68 DHCP, establece la IP manualmente"
lg_prt "v", " desde la aplicación gráfica\n"

lg_prt "y" "\n\n Configuración actual\n"
systemctl list-unit-files --state=enabled
lg_prt "y" "\n"
