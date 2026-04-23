#!/usr/bin/env bash
# 2023/07/04
source ./../utils.sh

SIZE="100M"	# Tamaño del ramdisk
FOLDER_RAM="/var/ramdisk/RAMDISK"
FOLDER_HDD="/var/ramdisk/persistent"
PERMMODE="0755"

# Comprobación de tamaño previa
lg_prt "yry" "\n[▲] ¿Quieres montar" "/tmp" "de archivos temporales en memoria RAM (tmpfs)?:"
free -h
lg_prt "w" " "
read -p "¿Estas seguro? (S/N): " -n 1 -r
lg_prt "w" " "
if [[ $REPLY =~ ^[Ss]$ ]]; then
	cp /usr/share/systemd/tmp.mount /etc/systemd/system
	read -p "A continuación edita el tamaño máximo (Ex:size=100m) " -n 1 -r
	sudo systemctl edit --full tmp.mount
	systemctl enable tmp.mount
	systemctl status tmp.mount
	lg_prt "w" " "
	findmnt | grep /tmp
	lg_prt "g" "[✔] Tarea finalizada\n"
fi

# Comprobación de tamaño previa
lg_prt "yry" "\n[▲] Crear una ramdisk de" ${SIZE} "con la memoria actual:"
free -h
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

# Crear la estructura
lg_prt "b" "\n [▲] Creando estructura ..."
if [ ! -d "${FOLDER_RAM}" ]; then
	mkdir -p $FOLDER_RAM
	lg_prt "gw" "[✔] Creado" ${FOLDER_RAM}
	mkdir -p ${FOLDER_RAM}/{profiles,downloads,downloads/images,downloads/music,temp,temp/internet,temp/logs,vmware,vcontainer}
	lg_prt "g" "[✔] Creado jerarquía de directorios"
fi

if [ ! -d "${FOLDER_HDD}" ]; then
	mkdir -p $FOLDER_HDD
	lg_prt "gw" "[✔] Creado" ${FOLDER_HDD}
fi

lg_prt "b" "\n [▲] Estableciendo permisos ..."
chmod -R ${PERMMODE} ${FOLDER_RAM}
chown -R user:user ${FOLDER_RAM}
chmod -R ${PERMMODE} ${FOLDER_HDD}
chown -R user:user ${FOLDER_HDD}
lg_prt "g" "[✔] Tarea finalizada\n"

# Crear servicio para el inicio automático
lg_prt "b" "\n [▲] Creando servicio para inicio automático ..."
cp ramdisk /etc/init.d
chmod +x /etc/init.d/ramdisk
update-rc.d ramdisk defaults
systemctl enable ramdisk.service
systemctl start ramdisk.service
systemctl status ramdisk.service
lg_prt "g" "[✔] Tarea finalizada\n"

# Crear tarea para backup automático
lg_prt "b" "\n [▲] Creando tarea para backup automático ..."
cp ramdisk_sync /etc/cron.hourly
chmod +x /etc/cron.hourly/ramdisk_sync
lg_prt "g" "[✔] Tarea finalizada\n"
