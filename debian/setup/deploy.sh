#!/bin/bash
# ==============================================================================
# deploy.sh — Despliega configuraciones a un SO recién instalado
# Uso: bash deploy.sh [--dry-run]
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# COLORES Y HELPERS
# ------------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[SKIP]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}══ $1 ══${NC}"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true && warn "Modo DRY-RUN activo (no se copiará nada)"

# ------------------------------------------------------------------------------
# RUTAS
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(realpath "$SCRIPT_DIR/../../config")"

if [ ! -d "$CONFIG_DIR" ]; then
    error "No se encuentra el directorio config en: $CONFIG_DIR"
    exit 1
fi
info "Directorio de configuraciones: $CONFIG_DIR"

STATS_OK=0; STATS_SKIP=0; STATS_FAIL=0

# ------------------------------------------------------------------------------
# FUNCIÓN PRINCIPAL DE COPIA
# ------------------------------------------------------------------------------
# deploy_file <archivo_origen> <destino> <permisos> [sudo]
deploy_file() {
    local src_name="$1"
    local dst="$2"
    local perms="$3"
    local use_sudo="${4:-false}"

    local src="$CONFIG_DIR/$src_name"

    # Archivo fuente existe?
    if [ ! -f "$src" ]; then
        warn "'$src_name' no encontrado en config/, omitiendo."
        ((STATS_SKIP++)); return
    fi

    if $DRY_RUN; then
        info "[DRY] cp $src → $dst (chmod $perms)"
        return
    fi

    # Crear directorio destino si no existe
    local dst_dir
    dst_dir="$(dirname "$dst")"
    if [ ! -d "$dst_dir" ]; then
        if $use_sudo; then
            sudo mkdir -p "$dst_dir"
        else
            mkdir -p "$dst_dir"
        fi
    fi

    # Backup si ya existe
    if [ -f "$dst" ]; then
        local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        if $use_sudo; then sudo cp "$dst" "$bak"; else cp "$dst" "$bak"; fi
        info "Backup creado: $bak"
    fi

    # Copiar
    if $use_sudo; then
        sudo cp "$src" "$dst"
        sudo chmod "$perms" "$dst"
    else
        cp "$src" "$dst"
        chmod "$perms" "$dst"
    fi

    success "$src_name → $dst"
    ((STATS_OK++))
}

# ------------------------------------------------------------------------------
# FUNCIÓN: comprobar si un comando existe
# ------------------------------------------------------------------------------
check_cmd() {
    local cmd="$1"; local label="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        success "$label instalado ($(command -v "$cmd"))"
        return 0
    else
        warn "$label NO encontrado — su configuración será ignorada"
        return 1
    fi
}

# Flatpak app instalada?
check_flatpak_app() {
    local app_id="$1"; local label="$2"
    if flatpak list --app 2>/dev/null | grep -q "$app_id"; then
        success "Flatpak: $label ($app_id)"
        return 0
    else
        warn "Flatpak: $label ($app_id) NO instalado — configuración ignorada"
        return 1
    fi
}

# ==============================================================================
# SECCIÓN 1 — VERIFICACIÓN DE PROGRAMAS
# ==============================================================================
section "Verificando programas instalados"

HAS_ZSH=false;        check_cmd zsh         "Zsh"           && HAS_ZSH=true
HAS_VIM=false;        check_cmd vim         "Vim"           && HAS_VIM=true
HAS_NANO=false;       check_cmd nano        "Nano"          && HAS_NANO=true
HAS_STARSHIP=false;   check_cmd starship    "Starship"      && HAS_STARSHIP=true
HAS_KITTY=false;      check_cmd kitty       "Kitty"         && HAS_KITTY=true
HAS_NPM=false;        check_cmd npm         "Node/NPM"      && HAS_NPM=true
HAS_PIP=false;        check_cmd pip3        "pip3"          && HAS_PIP=true
HAS_FLATPAK=false;    check_cmd flatpak     "Flatpak"       && HAS_FLATPAK=true
HAS_GIT=false;        check_cmd git         "Git"           && HAS_GIT=true

HAS_VSCODE=false
HAS_OBSIDIAN=false
HAS_SUBLIME=false
if $HAS_FLATPAK; then
    check_flatpak_app "com.visualstudio.code"  "VS Code"      && HAS_VSCODE=true
    check_flatpak_app "md.obsidian.Obsidian"   "Obsidian"     && HAS_OBSIDIAN=true
fi
check_cmd subl "Sublime Text" && HAS_SUBLIME=true || true

# ==============================================================================
# SECCIÓN 2 — SHELL (bash / zsh)
# ==============================================================================
section "Shell — Bash & Zsh"

deploy_file "favorites.sh" "$HOME/.aliasrc.zsh" "644"   # aliases compartidos

if $HAS_ZSH; then
    # .zshrc no está en config/ → avisamos pero no fallamos
    if [ -f "$CONFIG_DIR/.zshrc" ]; then
        deploy_file ".zshrc" "$HOME/.zshrc" "644"
    else
        warn ".zshrc no encontrado en config/ (puede vivir fuera de la carpeta)"
    fi
fi

# ==============================================================================
# SECCIÓN 3 — EDITORES
# ==============================================================================
section "Editores — Vim / Nano"

$HAS_VIM  && deploy_file ".vimrc"  "$HOME/.vimrc"  "644" || true
$HAS_NANO && deploy_file ".nanorc" "$HOME/.nanorc" "644" || true

# ==============================================================================
# SECCIÓN 4 — VS CODE
# ==============================================================================
section "VS Code"

if $HAS_VSCODE; then
    VSCODE_USER="$HOME/.var/app/com.visualstudio.code/config/Code/User"
    VSCODE_SNIP="$VSCODE_USER/snippets"

    deploy_file "settings.json"    "$VSCODE_USER/settings.json"          "600"
    deploy_file "keybindings.json" "$VSCODE_USER/keybindings.json"       "600"
    deploy_file "markdown.json"    "$VSCODE_SNIP/markdown.json"          "644"
    deploy_file "python.json"      "$VSCODE_SNIP/python.json"            "644"
    deploy_file "shellscript.json" "$VSCODE_SNIP/shellscript.json"       "644"

    # Copia extra al repo git si existe
    if $HAS_GIT && [ -d "$HOME/Documents/GIT/42_commoncore" ]; then
        GIT_VSCODE="$HOME/Documents/GIT/42_commoncore/.vscode"
        mkdir -p "$GIT_VSCODE"
        cp "$CONFIG_DIR/settings.json" "$GIT_VSCODE/settings.json"
        success "settings.json copiado también al repo git"
    fi
else
    warn "VS Code no instalado — saltando toda su configuración"
    ((STATS_SKIP+=5))
fi

# ==============================================================================
# SECCIÓN 5 — SUBLIME TEXT
# ==============================================================================
section "Sublime Text"

if $HAS_SUBLIME; then
    SUBL_USER="$HOME/.config/sublime-text/Packages/User"
    deploy_file "Preferences.sublime-settings" \
        "$SUBL_USER/Preferences.sublime-settings" "644"
    deploy_file "Default (Linux).sublime-keymap" \
        "$SUBL_USER/Default (Linux).sublime-keymap" "644"
else
    warn "Sublime Text no instalado — saltando configuración"
    ((STATS_SKIP+=2))
fi

# ==============================================================================
# SECCIÓN 6 — OBSIDIAN
# ==============================================================================
section "Obsidian"

if $HAS_OBSIDIAN; then
    deploy_file "Preferences" \
        "$HOME/.var/app/md.obsidian.Obsidian/config/obsidian/Preferences" "600"
else
    warn "Obsidian no instalado — saltando configuración"
    ((STATS_SKIP++))
fi

# ==============================================================================
# SECCIÓN 7 — HERRAMIENTAS DE DESARROLLO
# ==============================================================================
section "Herramientas — pip / npm / starship / kitty"

$HAS_PIP     && deploy_file "pip.conf"      "$HOME/.config/pip/pip.conf"   "644" || true
$HAS_NPM     && deploy_file "package.json"  "$HOME/package.json"           "644" || true
$HAS_STARSHIP && deploy_file "starship.toml" "$HOME/.config/starship.toml" "644" || true

if $HAS_KITTY; then
    deploy_file "kitty.conf" "$HOME/.config/kitty/kitty.conf" "644"
fi

# Rofi
if command -v rofi &>/dev/null; then
    deploy_file "config.rasi" "$HOME/.config/rofi/config.rasi" "644"
else
    warn "Rofi no instalado — config.rasi ignorado"
    ((STATS_SKIP++))
fi

# ==============================================================================
# SECCIÓN 8 — ARCHIVOS DE SISTEMA (requieren sudo)
# ==============================================================================
section "Archivos de sistema (sudo)"

deploy_file "fstab"                        "/etc/fstab"                              "644" true
deploy_file "hosts"                        "/etc/hosts"                              "644" true
deploy_file "nftables.conf"                "/etc/nftables.conf"                      "640" true
deploy_file "01-network-manager-all.yaml"  "/etc/netplan/01-network-manager-all.yaml" "600" true
deploy_file "Broadcast.conf"               "/etc/pulse/Broadcast.conf"               "644" true

# Netplan necesita permisos estrictos
if [ -f "/etc/netplan/01-network-manager-all.yaml" ]; then
    sudo chmod 600 /etc/netplan/01-network-manager-all.yaml
    success "Permisos 600 aplicados al yaml de netplan"
fi

# ==============================================================================
# SECCIÓN 9 — INSTALAR PAQUETES APT (opcional)
# ==============================================================================
section "Paquetes APT"

read -rp "¿Instalar paquetes APT recomendados? [s/N] " REPLY
if [[ "$REPLY" =~ ^[Ss]$ ]]; then
    info "Actualizando e instalando paquetes..."
    sudo apt update -qq
    sudo apt install -y \
        vim tree bat xclip trash-cli fzf fd-find \
        zsh zsh-autosuggestions zsh-syntax-highlighting \
        kitty starship git curl wget
    success "Paquetes APT instalados."
else
    info "Saltando instalación de paquetes APT."
fi

# ==============================================================================
# SECCIÓN 10 — INSTALAR APPS FLATPAK (opcional)
# ==============================================================================
section "Apps Flatpak"

if $HAS_FLATPAK; then
    read -rp "¿Instalar apps Flatpak recomendadas? [s/N] " REPLY
    if [[ "$REPLY" =~ ^[Ss]$ ]]; then
        flatpak remote-add --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo

        FLATPAK_APPS=(
            "com.visualstudio.code"
            "md.obsidian.Obsidian"
            "io.dbeaver.DBeaverCommunity"
            "org.freefilesync.FreeFileSync"
            "org.videolan.VLC"
            "org.kde.okular"
            "com.slack.Slack"
        )
        for app in "${FLATPAK_APPS[@]}"; do
            if flatpak list --app 2>/dev/null | grep -q "$app"; then
                warn "$app ya instalado, omitiendo."
            else
                info "Instalando $app..."
                sudo flatpak install -y flathub "$app" && success "$app instalado" \
                    || error "Fallo al instalar $app"
            fi
        done
    else
        info "Saltando instalación de apps Flatpak."
    fi
else
    warn "Flatpak no disponible — instálalo primero con: sudo apt install flatpak"
fi

# ==============================================================================
# RESUMEN FINAL
# ==============================================================================
echo ""
echo -e "${BOLD}${GREEN}══════════════════════════════════════${NC}"
echo -e "${BOLD}  Despliegue finalizado${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo -e "  ${GREEN}Copiados:${NC}  $STATS_OK"
echo -e "  ${YELLOW}Omitidos:${NC}  $STATS_SKIP"
echo -e "  ${RED}Errores:${NC}   $STATS_FAIL"
echo ""
echo -e "${CYAN}Consejo:${NC} Recarga la shell con: ${BOLD}source ~/.zshrc${NC} o ${BOLD}exec zsh${NC}"
echo ""
