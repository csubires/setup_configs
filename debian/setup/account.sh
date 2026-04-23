#!/bin/bash
# ==============================================================================
# setup.sh — Configuración inicial del sistema
# ==============================================================================

set -e

# ------------------------------------------------------------------------------
# COLORES
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Verificar que se ejecuta como root
[ "$EUID" -ne 0 ] && error "Ejecuta el script como root: sudo bash setup.sh"

# ==============================================================================
# 1. CREAR USUARIOS Y GRUPOS
# ==============================================================================
echo ""
info "=== Creando usuarios ==="

# manager — administrador
if id "manager" &>/dev/null; then
    warn "Usuario 'manager' ya existe, omitiendo creación."
else
    useradd -m -s /bin/bash -G sudo manager
    success "Usuario 'manager' creado."
fi
echo "Establece la contraseña para 'manager':"
passwd manager

# user — uso diario
if id "user" &>/dev/null; then
    warn "Usuario 'user' ya existe, omitiendo creación."
else
    useradd -m -s /bin/zsh user
    success "Usuario 'user' creado."
fi
echo "Establece la contraseña para 'user':"
passwd user

# guest — invitado con restricciones máximas
if id "guest" &>/dev/null; then
    warn "Usuario 'guest' ya existe, omitiendo creación."
else
    useradd -m -s /usr/sbin/nologin guest
    success "Usuario 'guest' creado."
fi
echo "Establece la contraseña para 'guest':"
passwd guest
chmod 700 /home/guest
usermod -L guest
success "Permisos de 'guest' configurados."

# ==============================================================================
# 2. DESHABILITAR ROOT
# ==============================================================================
echo ""
info "=== Deshabilitando cuenta root ==="

passwd -l root
usermod -s /usr/sbin/nologin root
success "Cuenta root deshabilitada."

# Asegurar shells correctas
usermod -s /bin/bash manager
usermod -s /bin/zsh user
usermod -s /usr/sbin/nologin guest
success "Shells de usuarios verificadas."

# ==============================================================================
# 3. TECLADO ESPAÑOL
# ==============================================================================
echo ""
info "=== Configurando teclado español ==="

localectl set-keymap es
localectl set-x11-keymap es pc105
success "Distribución de teclado establecida a 'es'."

if command -v setupcon &>/dev/null; then
    setupcon
    systemctl restart keyboard-setup 2>/dev/null || true
    success "Servicio de teclado reiniciado."
else
    warn "'setupcon' no encontrado. Puedes ejecutar manualmente: sudo dpkg-reconfigure keyboard-configuration"
fi

# ==============================================================================
# 4. INSTALAR FUENTES (FiraMono Nerd Font)
# ==============================================================================
echo ""
info "=== Instalando fuentes ==="

FONT_SRC="/mnt/hgfs/COMPRESS/FiraMono"
FONT_DST="/usr/share/fonts/FiraMono"

if [ -d "$FONT_SRC" ]; then
    mkdir -p "$FONT_DST"
    cp "$FONT_SRC"/*.otf "$FONT_DST/" 2>/dev/null || cp "$FONT_SRC"/*.ttf "$FONT_DST/" 2>/dev/null || warn "No se encontraron archivos .otf/.ttf en $FONT_SRC"
    fc-cache -fv > /dev/null
    success "Fuentes FiraMono instaladas."
    fc-list | grep -i fira
else
    warn "Directorio de fuentes '$FONT_SRC' no encontrado. Omitiendo instalación de fuentes."
    warn "Descarga FiraMono desde: https://www.nerdfonts.com/font-downloads"
fi

# ==============================================================================
# 5. AUMENTAR TIMEOUT DE SUDO
# ==============================================================================
echo ""
info "=== Configurando timeout de sudo ==="

SUDOERS_FILE="/etc/sudoers.d/custom_timeout"
echo "Defaults        timestamp_timeout=60" | tee "$SUDOERS_FILE" > /dev/null
chmod 440 "$SUDOERS_FILE"
success "Timeout de sudo establecido a 60 minutos."
echo ""
info "Contenido de $SUDOERS_FILE:"
cat "$SUDOERS_FILE"

# ==============================================================================
# RESUMEN
# ==============================================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Configuración completada correctamente   ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${CYAN}manager${NC}  → sudo, shell: /bin/bash"
echo -e "  ${CYAN}user${NC}     → estándar, shell: /bin/zsh"
echo -e "  ${CYAN}guest${NC}    → bloqueado, shell: nologin"
echo -e "  ${CYAN}root${NC}     → deshabilitado"
echo ""
