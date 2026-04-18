#!/usr/bin/env bash
# =============================================================================
#  build_openssh.sh
#  Instala y configura OpenSSH Server con hardening completo
#  Compatible: Debian 11/12, Ubuntu 20.04/22.04/24.04
#  Uso: sudo bash build_openssh.sh [--user USUARIO] [--pubkey "ssh-ed25519 AAA..."]
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# ── Colores ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }
section() { echo -e "\n${BOLD}━━━  $*  ━━━${RESET}"; }

# ── Argumentos ─────────────────────────────────────────────────────────────────
SSH_USER=""
PUBKEY=""
SSH_PORT=2222        # Puerto no estándar por defecto (más seguro que 22)
ALLOW_SFTP=false

usage() {
  echo "Uso: sudo bash $0 [opciones]"
  echo ""
  echo "  --user    USUARIO   Usuario no-root que podrá conectarse por SSH"
  echo "  --pubkey  CLAVE     Clave pública SSH (recomendado)"
  echo "  --port    PUERTO    Puerto SSH (defecto: 2222)"
  echo "  --sftp              Habilitar subsistema SFTP (desactivado por defecto)"
  echo "  --help              Mostrar esta ayuda"
  echo ""
  echo "Ejemplo:"
  echo "  sudo bash $0 --user deploy --pubkey \"ssh-ed25519 AAAA... user@host\" --port 2222"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)    SSH_USER="$2"; shift 2 ;;
    --pubkey)  PUBKEY="$2";   shift 2 ;;
    --port)    SSH_PORT="$2"; shift 2 ;;
    --sftp)    ALLOW_SFTP=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *)         error "Argumento desconocido: $1" ;;
  esac
done

# ── Verificaciones previas ─────────────────────────────────────────────────────
section "Verificaciones previas"

[[ $EUID -ne 0 ]] && error "Este script debe ejecutarse como root (sudo)."

# Detectar distro
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  DISTRO="${ID}"
  DISTRO_VER="${VERSION_ID:-unknown}"
else
  error "No se puede detectar la distribución."
fi

info "Sistema: ${PRETTY_NAME:-$DISTRO $DISTRO_VER}"

case "$DISTRO" in
  debian|ubuntu|raspbian) PKG_MGR="apt-get" ;;
  *) error "Distribución no soportada: $DISTRO. Soportadas: Debian, Ubuntu." ;;
esac

# Validar puerto
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || (( SSH_PORT < 1 || SSH_PORT > 65535 )); then
  error "Puerto inválido: $SSH_PORT"
fi

ok "Verificaciones superadas"

# ── Usuario SSH ────────────────────────────────────────────────────────────────
section "Configuración de usuario SSH"

if [[ -z "$SSH_USER" ]]; then
  read -rp "$(echo -e "${CYAN}Introduce el nombre del usuario SSH (no-root): ${RESET}")" SSH_USER
  [[ -z "$SSH_USER" ]] && error "Debes especificar un usuario."
fi

[[ "$SSH_USER" == "root" ]] && error "No se permite usar root como usuario SSH."

if id "$SSH_USER" &>/dev/null; then
  info "El usuario '$SSH_USER' ya existe."
else
  info "Creando usuario '$SSH_USER'..."
  useradd -m -s /bin/bash -c "SSH User" "$SSH_USER"
  # Contraseña bloqueada — solo clave pública
  passwd -l "$SSH_USER"
  ok "Usuario '$SSH_USER' creado con contraseña bloqueada."
fi

# Crear directorio .ssh
SSH_HOME=$(getent passwd "$SSH_USER" | cut -d: -f6)
mkdir -p "${SSH_HOME}/.ssh"
chmod 700 "${SSH_HOME}/.ssh"
touch "${SSH_HOME}/.ssh/authorized_keys"
chmod 600 "${SSH_HOME}/.ssh/authorized_keys"

# Clave pública
if [[ -z "$PUBKEY" ]]; then
  warn "No se proporcionó clave pública con --pubkey."
  read -rp "$(echo -e "${CYAN}Pega tu clave pública SSH (o ENTER para omitir): ${RESET}")" PUBKEY
fi

if [[ -n "$PUBKEY" ]]; then
  # Validar formato básico
  if echo "$PUBKEY" | grep -qE '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256|sk-ssh-ed25519) '; then
    echo "$PUBKEY" >> "${SSH_HOME}/.ssh/authorized_keys"
    ok "Clave pública añadida a authorized_keys."
  else
    warn "La clave pública no parece válida — añádela manualmente después."
  fi
else
  warn "Sin clave pública. ¡Recuerda añadir una antes de deshabilitar contraseñas!"
fi

chown -R "${SSH_USER}:${SSH_USER}" "${SSH_HOME}/.ssh"

# ── Instalar OpenSSH ───────────────────────────────────────────────────────────
section "Instalación de OpenSSH Server"

info "Actualizando índice de paquetes..."
$PKG_MGR update -qq

if dpkg -l openssh-server &>/dev/null 2>&1; then
  info "OpenSSH Server ya instalado. Actualizando..."
  $PKG_MGR install -y -qq openssh-server
else
  info "Instalando openssh-server..."
  $PKG_MGR install -y -qq openssh-server
fi

# Herramientas adicionales de seguridad
info "Instalando herramientas de seguridad complementarias..."
$PKG_MGR install -y -qq \
  fail2ban \
  ufw \
  libpam-google-authenticator 2>/dev/null || \
$PKG_MGR install -y -qq \
  fail2ban \
  ufw

ok "Paquetes instalados"

# ── Backup de configuración original ──────────────────────────────────────────
section "Backup de sshd_config original"

SSHD_CONF="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SSHD_CONF" "$BACKUP"
ok "Backup guardado en $BACKUP"

# ── Generar claves de host fuertes ────────────────────────────────────────────
section "Claves de host SSH"

info "Eliminando claves de host débiles (DSA, ECDSA antiguo)..."
rm -f /etc/ssh/ssh_host_dsa_key*
rm -f /etc/ssh/ssh_host_ecdsa_key*

# Regenerar ed25519 y RSA-4096
if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" -q
  ok "Clave de host ed25519 generada."
else
  info "Clave de host ed25519 ya existe."
fi

if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
  ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" -q
  ok "Clave de host RSA-4096 generada."
else
  # Verificar que la RSA existente sea >= 4096 bits
  RSA_BITS=$(ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key | awk '{print $1}')
  if (( RSA_BITS < 4096 )); then
    warn "Clave RSA existente es de ${RSA_BITS} bits. Regenerando a 4096..."
    rm -f /etc/ssh/ssh_host_rsa_key*
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" -q
    ok "Clave RSA-4096 regenerada."
  else
    info "Clave RSA de ${RSA_BITS} bits ya existe."
  fi
fi

chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# ── Escribir sshd_config hardened ─────────────────────────────────────────────
section "Escribiendo sshd_config hardened"

SFTP_LINE="# Subsystem sftp /usr/lib/openssh/sftp-server  # desactivado"
if [[ "$ALLOW_SFTP" == true ]]; then
  SFTP_LINE="Subsystem sftp /usr/lib/openssh/sftp-server"
  info "SFTP habilitado."
fi

cat > "$SSHD_CONF" << EOF
# =============================================================================
#  /etc/ssh/sshd_config – Configuración hardened
#  Generado por build_openssh.sh el $(date '+%Y-%m-%d %H:%M:%S')
# =============================================================================

# ── Claves de host ────────────────────────────────────────────────────────────
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# ── Red ───────────────────────────────────────────────────────────────────────
Port ${SSH_PORT}
AddressFamily inet
ListenAddress 0.0.0.0

# ── Autenticación ─────────────────────────────────────────────────────────────
# Solo clave pública — sin contraseñas bajo ningún concepto
PubkeyAuthentication          yes
AuthorizedKeysFile            .ssh/authorized_keys
PasswordAuthentication        no
PermitEmptyPasswords          no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication  no
UsePAM                        no

# Sin root
PermitRootLogin               no

# Usuarios explícitamente permitidos
AllowUsers                    ${SSH_USER}

# Tiempo de gracia reducido
LoginGraceTime                15
MaxAuthTries                  3
MaxSessions                   4
MaxStartups                   5:50:10

# ── Seguridad ─────────────────────────────────────────────────────────────────
StrictModes                   yes
PermitUserEnvironment         no
PermitTunnel                  no
AllowAgentForwarding          no
AllowTcpForwarding            no
GatewayPorts                  no
X11Forwarding                 no
PrintMotd                     no
PrintLastLog                  yes
TCPKeepAlive                  yes
Compression                   no
IgnoreRhosts                  yes
HostbasedAuthentication       no
IgnoreUserKnownHosts          yes

# ── Algoritmos modernos (eliminar curvas y cifrados débiles) ──────────────────
KexAlgorithms          curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers                chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs                   hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
HostKeyAlgorithms      ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# ── Keepalive y sesión ────────────────────────────────────────────────────────
ClientAliveInterval    60
ClientAliveCountMax    3

# ── Logging (VERBOSE para registrar fingerprints de claves) ──────────────────
SyslogFacility         AUTH
LogLevel               VERBOSE

# ── Banner ────────────────────────────────────────────────────────────────────
Banner                 /etc/ssh/banner.txt

# ── SFTP ──────────────────────────────────────────────────────────────────────
${SFTP_LINE}
EOF

ok "sshd_config escrito."

# ── Banner de advertencia ──────────────────────────────────────────────────────
cat > /etc/ssh/banner.txt << 'BANNER'
*******************************************************************************
  SISTEMA DE ACCESO RESTRINGIDO

  Solo personal autorizado. Toda actividad es monitorizada y registrada.
  El acceso no autorizado está sujeto a acciones legales.
*******************************************************************************
BANNER
ok "Banner SSH creado."

# ── Validar configuración ──────────────────────────────────────────────────────
section "Validación de sshd_config"

if sshd -t -f "$SSHD_CONF"; then
  ok "sshd_config válido — sin errores de sintaxis."
else
  error "Error en sshd_config. Restaurando backup..."
  cp "$BACKUP" "$SSHD_CONF"
fi

# ── Configurar fail2ban ────────────────────────────────────────────────────────
section "Configurando fail2ban"

cat > /etc/fail2ban/jail.d/sshd-hardened.conf << EOF
[sshd]
enabled   = true
port      = ${SSH_PORT}
filter    = sshd
backend   = systemd
logpath   = /var/log/auth.log
maxretry  = 3
findtime  = 300
bantime   = 3600
ignoreip  = 127.0.0.1/8
EOF

systemctl enable fail2ban --quiet
systemctl restart fail2ban
ok "fail2ban configurado: 3 intentos → ban 1h."

# ── Configurar UFW ─────────────────────────────────────────────────────────────
section "Configurando firewall (UFW)"

# Verificar si UFW está disponible
if command -v ufw &>/dev/null; then
  # Política por defecto
  ufw --force reset         > /dev/null 2>&1
  ufw default deny incoming > /dev/null 2>&1
  ufw default allow outgoing > /dev/null 2>&1

  # Permitir SSH en el puerto configurado
  ufw allow "${SSH_PORT}/tcp" comment "SSH hardened" > /dev/null 2>&1

  # Habilitar sin preguntar
  ufw --force enable > /dev/null 2>&1
  ok "UFW activado. Puerto ${SSH_PORT}/tcp abierto."
  ufw status numbered
else
  warn "UFW no disponible. Configura el firewall manualmente."
fi

# ── Permisos y módulo SSH ──────────────────────────────────────────────────────
section "Ajustes finales de seguridad"

# Permisos correctos en /etc/ssh
chmod 755 /etc/ssh
chmod 600 /etc/ssh/sshd_config
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# Deshabilitar módulos PAM peligrosos si existen
if [[ -f /etc/pam.d/sshd ]]; then
  # Deshabilitar autenticación por contraseña via PAM (ya que UsePAM=no)
  info "PAM sshd: UsePAM desactivado en sshd_config, sin cambios en pam.d/sshd."
fi

# Asegurar que sshd no se ejecute como root innecesariamente
# (el proceso privilegiado cae a sshd tras autenticar, comportamiento normal)

# Deshabilitar SSH v1 a nivel de kernel modules (si aplica)
# SSH v2 ya es el único soportado por OpenSSH moderno

ok "Permisos de /etc/ssh ajustados."

# ── Reiniciar SSH ──────────────────────────────────────────────────────────────
section "Reiniciando OpenSSH Server"

systemctl enable ssh --quiet 2>/dev/null || systemctl enable sshd --quiet 2>/dev/null || true
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

sleep 1

if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
  ok "OpenSSH Server corriendo en puerto ${SSH_PORT}."
else
  error "El servicio SSH no arrancó. Revisa: journalctl -xe -u ssh"
fi

# ── Resumen final ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  INSTALACIÓN COMPLETADA${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${CYAN}Puerto SSH:${RESET}      ${SSH_PORT}"
echo -e "  ${CYAN}Usuario:${RESET}         ${SSH_USER}"
echo -e "  ${CYAN}Autenticación:${RESET}   Solo clave pública"
echo -e "  ${CYAN}Root login:${RESET}      Deshabilitado"
echo -e "  ${CYAN}Fail2ban:${RESET}        Activo (3 intentos, ban 1h)"
echo -e "  ${CYAN}Firewall UFW:${RESET}    Puerto ${SSH_PORT}/tcp abierto"
echo -e "  ${CYAN}Algoritmos:${RESET}      curve25519, chacha20-poly1305, aes256-gcm"
echo -e "  ${CYAN}Backup config:${RESET}   ${BACKUP}"
echo ""
echo -e "  ${BOLD}Conectar:${RESET}"
echo -e "  ssh -p ${SSH_PORT} -i ~/.ssh/tu_clave_privada ${SSH_USER}@<IP_SERVIDOR>"
echo ""
if [[ -z "$PUBKEY" ]]; then
  echo -e "  ${YELLOW}⚠ IMPORTANTE: Añade tu clave pública antes de cerrar la sesión actual:${RESET}"
  echo -e "  echo 'ssh-ed25519 AAAA...' >> ${SSH_HOME}/.ssh/authorized_keys"
  echo ""
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
