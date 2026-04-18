#!/usr/bin/env bash
# =============================================================================
#  build_docker.sh
#  Instala Docker CE oficial (desde repos de Docker Inc.) + Docker Compose v2
#  Compatible: Debian 11/12, Ubuntu 20.04/22.04/24.04
#  Uso: sudo bash build_docker.sh [--user USUARIO] [--no-compose]
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
DOCKER_USER=""
INSTALL_COMPOSE=true
INSTALL_BUILDX=true

usage() {
  echo "Uso: sudo bash $0 [opciones]"
  echo ""
  echo "  --user       USUARIO   Añadir usuario al grupo docker (sin sudo)"
  echo "  --no-compose           No instalar Docker Compose v2"
  echo "  --no-buildx            No instalar Docker Buildx"
  echo "  --help                 Mostrar esta ayuda"
  echo ""
  echo "Ejemplo:"
  echo "  sudo bash $0 --user deploy"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)        DOCKER_USER="$2"; shift 2 ;;
    --no-compose)  INSTALL_COMPOSE=false; shift ;;
    --no-buildx)   INSTALL_BUILDX=false; shift ;;
    --help|-h)     usage; exit 0 ;;
    *)             error "Argumento desconocido: $1" ;;
  esac
done

# ── Verificaciones previas ─────────────────────────────────────────────────────
section "Verificaciones previas"

[[ $EUID -ne 0 ]] && error "Este script debe ejecutarse como root (sudo)."

# Detectar distro
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  DISTRO="${ID}"
  DISTRO_VER="${VERSION_ID:-}"
  DISTRO_CODENAME="${VERSION_CODENAME:-}"
else
  error "No se puede detectar la distribución."
fi

info "Sistema: ${PRETTY_NAME:-$DISTRO $DISTRO_VER}"

# Mapear a los nombres que usa Docker en sus repos
case "$DISTRO" in
  ubuntu)
    DOCKER_DISTRO="ubuntu"
    ;;
  debian|raspbian)
    DOCKER_DISTRO="debian"
    DISTRO="debian"
    ;;
  *)
    error "Distribución no soportada: $DISTRO (soportadas: Debian, Ubuntu)."
    ;;
esac

# Detectar arquitectura
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
  amd64|arm64|armhf) ok "Arquitectura soportada: $ARCH" ;;
  *) error "Arquitectura no soportada: $ARCH" ;;
esac

# Verificar conectividad
info "Verificando conectividad con download.docker.com..."
if ! curl -fsSL --max-time 10 https://download.docker.com > /dev/null 2>&1; then
  error "Sin acceso a download.docker.com. Verifica tu conexión a internet."
fi
ok "Conectividad OK."

# ── Desinstalar versiones antiguas ────────────────────────────────────────────
section "Eliminando versiones antiguas de Docker"

OLD_PKGS=(
  docker
  docker-engine
  docker.io
  containerd
  runc
  docker-ce
  docker-ce-cli
  docker-compose
  docker-compose-plugin
)

PKGS_TO_REMOVE=()
for pkg in "${OLD_PKGS[@]}"; do
  if dpkg -l "$pkg" &>/dev/null 2>&1; then
    PKGS_TO_REMOVE+=("$pkg")
  fi
done

if [[ ${#PKGS_TO_REMOVE[@]} -gt 0 ]]; then
  warn "Eliminando: ${PKGS_TO_REMOVE[*]}"
  apt-get remove -y "${PKGS_TO_REMOVE[@]}" --purge > /dev/null 2>&1 || true
  ok "Versiones antiguas eliminadas."
else
  ok "No se encontraron versiones antiguas."
fi

# ── Dependencias ───────────────────────────────────────────────────────────────
section "Instalando dependencias"

apt-get update -qq
apt-get install -y -qq \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https

ok "Dependencias instaladas."

# ── Añadir repositorio oficial de Docker ───────────────────────────────────────
section "Configurando repositorio oficial de Docker"

DOCKER_KEYRING="/etc/apt/keyrings/docker.gpg"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"

# Crear directorio de keyrings si no existe
install -m 0755 -d /etc/apt/keyrings

# Descargar y verificar la clave GPG oficial de Docker
info "Descargando clave GPG de Docker..."
curl -fsSL "https://download.docker.com/linux/${DOCKER_DISTRO}/gpg" \
  | gpg --dearmor -o "$DOCKER_KEYRING"
chmod a+r "$DOCKER_KEYRING"
ok "Clave GPG guardada en $DOCKER_KEYRING"

# Detectar codename si no está disponible
if [[ -z "$DISTRO_CODENAME" ]]; then
  DISTRO_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")
  [[ -z "$DISTRO_CODENAME" ]] && error "No se pudo detectar el codename de la distro."
fi

info "Codename: ${DISTRO_CODENAME}"

# Añadir el repositorio
echo "deb [arch=${ARCH} signed-by=${DOCKER_KEYRING}] \
https://download.docker.com/linux/${DOCKER_DISTRO} \
${DISTRO_CODENAME} stable" > "$DOCKER_LIST"

ok "Repositorio añadido: $DOCKER_LIST"

# ── Instalar Docker CE ─────────────────────────────────────────────────────────
section "Instalando Docker CE"

apt-get update -qq

info "Instalando docker-ce, docker-ce-cli, containerd.io..."
apt-get install -y -qq \
  docker-ce \
  docker-ce-cli \
  containerd.io

# Instalar plugins adicionales
EXTRA_PLUGINS=()
[[ "$INSTALL_COMPOSE" == true ]] && EXTRA_PLUGINS+=(docker-compose-plugin)
[[ "$INSTALL_BUILDX" == true ]]  && EXTRA_PLUGINS+=(docker-buildx-plugin)

if [[ ${#EXTRA_PLUGINS[@]} -gt 0 ]]; then
  info "Instalando plugins: ${EXTRA_PLUGINS[*]}"
  apt-get install -y -qq "${EXTRA_PLUGINS[@]}"
fi

ok "Docker CE instalado."

# ── Versiones instaladas ───────────────────────────────────────────────────────
DOCKER_VER=$(docker --version 2>/dev/null || echo "desconocida")
info "Versión Docker: $DOCKER_VER"

if [[ "$INSTALL_COMPOSE" == true ]]; then
  COMPOSE_VER=$(docker compose version 2>/dev/null || echo "desconocida")
  info "Versión Compose: $COMPOSE_VER"
fi

# ── Hardening del demonio Docker ───────────────────────────────────────────────
section "Aplicando hardening al demonio Docker"

DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
mkdir -p /etc/docker

# ¿Hay configuración previa?
if [[ -f "$DOCKER_DAEMON_JSON" ]]; then
  cp "$DOCKER_DAEMON_JSON" "${DOCKER_DAEMON_JSON}.backup.$(date +%Y%m%d_%H%M%S)"
  warn "Backup de daemon.json guardado."
fi

cat > "$DOCKER_DAEMON_JSON" << 'DAEMON_EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "icc": false,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "storage-driver": "overlay2"
}
DAEMON_EOF

ok "daemon.json escrito:"
info "  log-driver json-file (max 10m × 3 archivos)"
info "  live-restore: los contenedores sobreviven reinicios del demonio"
info "  userland-proxy: false (rendimiento)"
info "  no-new-privileges: true (hardening)"
info "  icc: false (contenedores aislados entre sí por defecto)"

# ── Usuario en grupo docker ────────────────────────────────────────────────────
section "Permisos de usuario"

if [[ -z "$DOCKER_USER" ]]; then
  # Intentar detectar el usuario que invocó sudo
  SUDO_ORIG="${SUDO_USER:-}"
  if [[ -n "$SUDO_ORIG" && "$SUDO_ORIG" != "root" ]]; then
    DOCKER_USER="$SUDO_ORIG"
    info "Usuario detectado automáticamente: $DOCKER_USER"
  else
    read -rp "$(echo -e "${CYAN}Usuario a añadir al grupo docker (ENTER para omitir): ${RESET}")" DOCKER_USER
  fi
fi

if [[ -n "$DOCKER_USER" ]]; then
  if id "$DOCKER_USER" &>/dev/null; then
    usermod -aG docker "$DOCKER_USER"
    ok "Usuario '$DOCKER_USER' añadido al grupo docker."
    warn "El usuario debe cerrar sesión y volver a entrar para que surta efecto."
  else
    warn "Usuario '$DOCKER_USER' no existe. No se añadió al grupo docker."
  fi
else
  warn "Sin usuario especificado. Usa 'sudo usermod -aG docker TU_USUARIO' manualmente."
fi

# ── Configurar systemd ─────────────────────────────────────────────────────────
section "Configurando systemd"

# Override del servicio para protección extra
SYSTEMD_OVERRIDE_DIR="/etc/systemd/system/docker.service.d"
mkdir -p "$SYSTEMD_OVERRIDE_DIR"

cat > "${SYSTEMD_OVERRIDE_DIR}/override.conf" << 'SYSTEMD_EOF'
[Service]
# Límites de seguridad adicionales en el servicio systemd
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

# Reiniciar automáticamente si falla
Restart=always
RestartSec=5s
SYSTEMD_EOF

systemctl daemon-reload
systemctl enable docker --quiet
systemctl restart docker

sleep 2

if systemctl is-active --quiet docker; then
  ok "Docker daemon corriendo."
else
  error "Docker no arrancó. Revisa: journalctl -xe -u docker"
fi

# ── Test de funcionamiento ─────────────────────────────────────────────────────
section "Test de funcionamiento"

info "Ejecutando docker run hello-world..."
if docker run --rm hello-world > /dev/null 2>&1; then
  ok "hello-world ejecutado correctamente — Docker funciona."
else
  warn "hello-world falló. Puede ser problema de red o permisos."
fi

# Limpiar imagen de prueba
docker rmi hello-world > /dev/null 2>&1 || true

# ── Contenedor de red para containerd ─────────────────────────────────────────
# Asegurar que containerd esté configurado correctamente
systemctl enable containerd --quiet
systemctl is-active --quiet containerd || systemctl start containerd

ok "containerd activo."

# ── Resumen final ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  DOCKER CE INSTALADO Y CONFIGURADO${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${CYAN}Docker:${RESET}         $(docker --version)"
if [[ "$INSTALL_COMPOSE" == true ]]; then
  echo -e "  ${CYAN}Compose:${RESET}        $(docker compose version 2>/dev/null || echo 'ver. desconocida')"
fi
if [[ "$INSTALL_BUILDX" == true ]]; then
  echo -e "  ${CYAN}Buildx:${RESET}         $(docker buildx version 2>/dev/null || echo 'ver. desconocida')"
fi
echo -e "  ${CYAN}Repositorio:${RESET}    docker.com/linux/${DOCKER_DISTRO} (oficial)"
echo -e "  ${CYAN}Storage driver:${RESET} overlay2"
echo -e "  ${CYAN}Live restore:${RESET}   sí"
echo -e "  ${CYAN}ICC:${RESET}            desactivado (contenedores aislados)"
echo -e "  ${CYAN}no-new-privs:${RESET}   sí"
echo ""
echo -e "  ${BOLD}Comandos útiles:${RESET}"
echo -e "  docker ps                   # contenedores en ejecución"
echo -e "  docker compose up -d        # levantar stack"
echo -e "  docker system prune -af     # limpiar recursos no usados"
echo -e "  journalctl -u docker -f     # logs del demonio"
echo ""
if [[ -n "$DOCKER_USER" ]] && id "$DOCKER_USER" &>/dev/null; then
  echo -e "  ${YELLOW}Cierra y vuelve a abrir sesión como '$DOCKER_USER' para usar docker sin sudo.${RESET}"
  echo ""
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
