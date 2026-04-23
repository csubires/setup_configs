#!/usr/bin/env bash
# 2023/07/04
source ./../utils.sh

FOLDER_RAM="/var/ramdisk/RAMDISK"

# Comprobación de tamaño previa
lg_prt "yry" "\n[▲] Desinstalar ramdisk"
lg_prt "w" " "
read -p "¿Estas seguro? (S/N): " -n 1 -r
lg_prt "w" " "
[[ $REPLY =~ ^[Ss]$ ]] && lg_prt "w" " \n" || exit 0

# Comprobar que se ejecuta en modo root
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

# Desmontar unidad
umount -l ${FOLDER_RAM}
umount ${FOLDER_RAM}
lg_prt "g" "[✔] Desmontar unidad"

# Eliminar servicio
systemctl stop ramdisk.service
systemctl disable ramdisk.service
systemctl status ramdisk.service
[[ -e "/etc/init.d/ramdisk" ]] && rm /etc/init.d/ramdisk
lg_prt "g" "[✔] Deshabilitado servicio"

# Eliminar tarea
[[ -e "/etc/cron.hourly/ramdisk_sync" ]] && rm /etc/cron.hourly/ramdisk_sync
lg_prt "g" "[✔] Eliminado tarea de backup"
