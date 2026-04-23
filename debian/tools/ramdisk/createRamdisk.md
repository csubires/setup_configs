
### Crear RAMDISK y establecer como archivos temporales
free -m 				// Ver memoria disponible

### Crear estructura de carpetas de RAMDISK
cd /mnt
mkdir ramdisk

### Persistencia
sudo nano /etc/fstab
ramdisk /mnt/ramdisk tmpfs defaults,nodev,nosuid,noexec,
noatime,nodiratime,size=10M,x-gvfs-show 0 0

mkdir -p ramdisk/{downloads,internet,temp,"temp/logs",vmware,firejail}
sudo chmod -R 777 /mnt/ramdisk

### Comprobación
sudo mount -t tmpfs -o size=10M ramdisk /mnt/ramdisk
df -h /mnt/ramdisk

### Desmontar
#sudo umount /tmp/ramdisk/

### Fuente
https://www.linuxbabe.com/command-line/create-ramdisk-linux
https://gitlab.com/jamesdawson1995/persist/-/blob/master/persist
