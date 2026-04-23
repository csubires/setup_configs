#!/usr/bin/env bash

# Script de configuración automática para servidor Ubuntu
# Ejecutar como: sudo bash setup-server.sh

set -e  # Detener script en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para loggear
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Verificar que se ejecute como root
if [ "$EUID" -ne 0 ]; then
    error "Por favor, ejecuta como root: sudo bash $0"
    exit 1
fi

# Configuración
MAIN_USER="user"
MANAGER_USER="manager"
SSH_USER="sshuser"
PODMAN_USER="podman"
SERVER_IP="192.168.0.20"
SSH_PORT="22"

log "Iniciando configuración automática del servidor..."

# =============================================================================
# 1. CONFIGURACIÓN DE USUARIOS Y GRUPOS
# =============================================================================

log "Configurando usuarios y grupos..."

# Configurar teclado español
loadkeys es

# Crear usuarios
useradd -m -s /bin/bash "$MAIN_USER" 2>/dev/null || warn "Usuario $MAIN_USER ya existe"
useradd -m -s /bin/bash "$MANAGER_USER" 2>/dev/null || warn "Usuario $MANAGER_USER ya existe"
useradd -r -s /bin/false "$PODMAN_USER" 2>/dev/null || warn "Usuario $PODMAN_USER ya existe"
useradd --gecos "" "$SSH_USER" 2>/dev/null || warn "Usuario $SSH_USER ya existe"

# Configurar grupos y permisos
usermod -aG sudo "$MANAGER_USER"
usermod -aG sudo "$SSH_USER"
usermod -aG "$PODMAN_USER" "$MANAGER_USER"
usermod -aG "$PODMAN_USER" "$MAIN_USER"
usermod -aG "$MAIN_USER" "$SSH_USER"

# Deshabilitar root
passwd -l root
usermod -s /usr/sbin/nologin root

# Crear estructura de directorios
mkdir -p "/home/$MAIN_USER/server"
chmod 751 "/home/$MAIN_USER"
chmod 755 "/home/$MAIN_USER/server"
mkdir -p "/home/$MAIN_USER/server/"{data,composes,scripts,configs,backups,box}
chmod 750 "/home/$MAIN_USER/server/"{data,composes,scripts,configs,backups,box}
setfacl -m u:"$MANAGER_USER":rwx "/home/$MAIN_USER/server"
chown -R "$MAIN_USER:$MAIN_USER" "/home/$MAIN_USER/server"

# =============================================================================
# 2. INSTALACIÓN DE PAQUETES BÁSICOS
# =============================================================================

log "Instalando paquetes básicos..."

# Detener servicios innecesarios
systemctl stop chrony 2>/dev/null || true
systemctl disable chrony 2>/dev/null || true

# Actualizar sistema
apt update && apt upgrade -y

# Instalar paquetes básicos
apt install -y acl vim net-tools open-vm-tools open-vm-tools-desktop \
    openssh-server podman podman-compose samba nftables unattended-upgrades \
    auditd audispd-plugins fail2ban

# =============================================================================
# 3. CONFIGURACIÓN DE SSH
# =============================================================================

log "Configurando SSH..."

# Backup de configuración
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configuración SSH (append si no existe)
if ! grep -q "Port 22" /etc/ssh/sshd_config; then
    cat >> /etc/ssh/sshd_config << 'EOF'

# Configuración personalizada
Port 22
Protocol 2
PermitRootLogin no
MaxAuthTries 3
MaxSessions 5
ClientAliveInterval 300
ClientAliveCountMax 2
PasswordAuthentication no
PubkeyAuthentication yes
LoginGraceTime 60
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
AuthorizedKeysFile /home/manager/.ssh/authorized_keys
AllowUsers sshuser
PermitEmptyPasswords no
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
AllowTcpForwarding no
PermitTunnel no
EOF
fi

# Crear clave SSH para el usuario manager
sudo -u "$MANAGER_USER" mkdir -p "/home/$MANAGER_USER/.ssh"
sudo -u "$MANAGER_USER" ssh-keygen -t ed25519 -C "sshuser@$SERVER_IP" \
    -f "/home/$MANAGER_USER/.ssh/servermedia2" -N ""

# Configurar cliente SSH
sudo -u "$MANAGER_USER" mkdir -p "/home/$MANAGER_USER/.ssh"
cat > "/home/$MANAGER_USER/.ssh/config" << EOF
Host server20
    HostName $SERVER_IP
    User $SSH_USER
    IdentityFile ~/.ssh/servermedia2
EOF

chown "$MANAGER_USER:$MANAGER_USER" "/home/$MANAGER_USER/.ssh/config"
chmod 600 "/home/$MANAGER_USER/.ssh/config"

# Validar y reiniciar SSH
sshd -t
systemctl enable ssh
systemctl restart ssh

# =============================================================================
# 4. CONFIGURACIÓN DE RED
# =============================================================================

log "Configurando red..."

cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - $SERVER_IP/24
      gateway4: 192.168.0.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
EOF

netplan apply

# =============================================================================
# 5. CONFIGURACIÓN DE SAMBA
# =============================================================================

log "Configurando Samba..."

# Crear directorio compartido
mkdir -p "/home/$MAIN_USER/server/shared_folder"
chmod 770 "/home/$MAIN_USER/server/shared_folder"
chown "$MANAGER_USER:$MANAGER_USER" "/home/$MAIN_USER/server/shared_folder"

# Backup de configuración Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Configuración Samba (append)
if ! grep -q "\[share\]" /etc/samba/smb.conf; then
    cat >> /etc/samba/smb.conf << 'EOF'

[global]
	workgroup = WORKGROUP
	security = user
	map to guest = never
	server min protocol = SMB2

[share]
    path = /home/user/server/shared_folder
    valid users = manager, user
    read only = no
    browseable = yes
    writable = yes
    guest ok = no
    create mask = 0777
    directory mask = 0777
    force user = user
    force group = user
EOF
fi

# Configurar usuarios Samba
echo "Configura la contraseña de Samba para $MANAGER_USER:"
smbpasswd -a "$MANAGER_USER"

echo "Configura la contraseña de Samba para $MAIN_USER:"
smbpasswd -a "$MAIN_USER"

systemctl enable smbd
systemctl restart smbd

# =============================================================================
# 6. CONFIGURACIÓN DE FIREWALL (NFTABLES)
# =============================================================================

log "Configurando firewall..."

cat > /etc/nftables.conf << 'EOF'
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    set allowed_ssh {
        type ipv4_addr
        elements = { 192.168.0.10 }
    }
    set allowed_smb {
        type ipv4_addr
        elements = { 192.168.65.10 }
    }
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iif lo accept
        oif lo accept
        # PODMAN
        iifname "podman*" accept
        oifname "podman*" accept
        tcp dport { 80, 443, 8080, 3000 } accept
        # END PODMAN
        tcp dport 22 ip saddr @allowed_ssh accept
        tcp dport 443 accept
	ip saddr @allowed_smb tcp dport { 139, 445 } accept
        ip saddr @allowed_smb udp dport { 137, 138 } accept
        ip protocol icmp drop
        ip6 nexthdr icmpv6 drop
        limit rate 2/second log prefix "nftables denied: " drop
	}

chain forward {
        type filter hook forward priority 0; policy drop;
        # PODMAN
        iifname "podman*" oifname "ens33" ct state related,established accept
        iifname "ens33" oifname "podman*" ct state established,related accept
        iifname "podman*" oifname "podman*" accept
        # END PODMAN
	}

chain output {
	type filter hook output priority 0; policy drop;
	tcp dport { 80, 443 } accept
	udp dport { 53 } accept
	iif lo accept
	oif lo accept
	ct state established,related accept
	}

}

table ip nat {
    chain prerouting { type nat hook prerouting priority -100; policy accept; }
    chain postrouting { type nat hook postrouting priority 100; policy accept; }
}
EOF

systemctl enable nftables
systemctl restart nftables

# =============================================================================
# 7. CONFIGURACIÓN DE PODMAN
# =============================================================================

log "Configurando Podman..."

# Configurar subuids
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$MANAGER_USER"
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$MAIN_USER"

# Habilitar linger
loginctl enable-linger "$MANAGER_USER"
loginctl enable-linger "$MAIN_USER"

# Crear directorios de almacenamiento
sudo -u "$MANAGER_USER" mkdir -p "/home/$MANAGER_USER/.local/share/containers/storage"
sudo -u "$MAIN_USER" mkdir -p "/home/$MAIN_USER/.local/share/containers/storage"

# Configurar registros
mkdir -p "/home/$MANAGER_USER/.config/containers"
cat > "/home/$MANAGER_USER/.config/containers/registries.conf" << 'EOF'
unqualified-search-registries = ["docker.io"]

[[registry]]
location = "docker.io"
EOF

chown -R "$MANAGER_USER:$MANAGER_USER" "/home/$MANAGER_USER/.config"

systemctl enable podman.socket
systemctl restart podman.socket

# =============================================================================
# 8. CONFIGURACIÓN DE SYSCTL
# =============================================================================

log "Configurando parámetros del kernel..."

cat > /etc/sysctl.d/99-security.conf << 'EOF'
# IP spoofing
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1

# ICMP redirects
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0

# ICMP broadcast
net.ipv4.icmp_echo_ignore_broadcasts=1

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# SYN floods
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog=2048
net.ipv4.tcp_synack_retries=2

# Log martian packets
net.ipv4.conf.all.log_martians=1

# Disable IP source routing
net.ipv4.conf.all.accept_source_route=0
net.ipv6.conf.all.accept_source_route=0

# Execshield protection
kernel.exec-shield=1
kernel.randomize_va_space=2
EOF

sysctl --system

# =============================================================================
# 9. CONFIGURACIÓN DE FAIL2BAN
# =============================================================================

log "Configurando Fail2Ban..."

mkdir -p /etc/fail2ban/jail.d

cat > /etc/fail2ban/jail.d/ssh.local << 'EOF'
[DEFAULT]
ignoreip = 127.0.0.1/8 192.168.0.0/24 192.168.65.0/24
bantime = 3600
findtime = 600
maxretry = 3
backend = auto

[sshd]
enabled = true
port    = 22
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# =============================================================================
# 10. CONFIGURACIONES FINALES
# =============================================================================

log "Aplicando configuraciones finales..."

# Configurar aliases para usuarios
for user in "$MAIN_USER" "$MANAGER_USER"; do
    user_home="/home/$user"
    if [ -d "$user_home" ]; then
        cat >> "$user_home/.bashrc" << 'EOF'

# Aliases personalizados
alias server="cd /home/user/server"
alias shared="cd /home/user/server/shared_folder"
EOF
        chown "$user:$user" "$user_home/.bashrc"
    fi
done

# Configurar actualizaciones automáticas
dpkg-reconfigure --priority=low unattended-upgrades -f noninteractive

log "Configuración completada!"
echo ""
echo "Resumen de la configuración:"
echo "- Usuarios creados: $MAIN_USER, $MANAGER_USER, $SSH_USER, $PODMAN_USER"
echo "- SSH configurado en puerto $SSH_PORT"
echo "- Firewall nftables activado"
echo "- Samba compartido en /home/$MAIN_USER/server/shared_folder"
echo "- Podman configurado para $MANAGER_USER y $MAIN_USER"
echo "- Fail2Ban protegiendo SSH"
echo ""
echo "Recomendaciones:"
echo "1. Configurar las contraseñas de los usuarios: passwd $MANAGER_USER"
echo "2. Guardar la clave SSH: /home/$MANAGER_USER/.ssh/servermedia2.pub"
echo "3. Reiniciar el sistema: reboot"
