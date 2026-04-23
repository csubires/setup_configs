#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Bootstrap your development environment
#
#  Modes:
#    - Normal (host):  installs packages via apt/dnf/pacman, then copies configs
#    - Docker build:   DOCKER_BUILD=1  →  skips package install (already done
#                      in Dockerfile), only applies configs
#
#  Usage:
#    bash setup.sh                   # host — full install
#    DOCKER_BUILD=1 bash setup.sh    # inside Dockerfile RUN
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; }
section() { echo -e "\n${BOLD}━━━  $*  ━━━${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
DOCKER_BUILD="${DOCKER_BUILD:-0}"   # set to 1 inside Dockerfile

# =============================================================================
#  1. PACKAGE LIST  (duplicates removed automatically)
# =============================================================================
PACKAGES_RAW=(
  zsh
  kitty
  git
  flatpak
  fd-find
  vim
  bat
  xclip
  tree
  pandoc
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  trash-cli
  starship
  nano
  curl
  wget
  openssl
)

# De-duplicate preserving order
declare -A _seen
PACKAGES=()
for pkg in "${PACKAGES_RAW[@]}"; do
  if [[ -z "${_seen[$pkg]+set}" ]]; then
    _seen[$pkg]=1
    PACKAGES+=("$pkg")
  fi
done

# =============================================================================
#  2. CONFIG FILES  →  source : destination
# =============================================================================
CONFIG_MAP=(
  "zsh/.zshrc:~/.zshrc"
  "zsh/.zsh_aliases:~/.zsh_aliases"
  "kitty/kitty.conf:~/.config/kitty/kitty.conf"
  "git/.gitconfig:~/.gitconfig"
  "vim/.vimrc:~/.vimrc"
  "starship/starship.toml:~/.config/starship.toml"
  "nano/.nanorc:~/.nanorc"
)

# =============================================================================
#  3. PACKAGE INSTALL  (skipped inside Docker — handled by Dockerfile)
# =============================================================================
if [[ "$DOCKER_BUILD" == "1" ]]; then
  section "Docker mode — skipping package install"
  info "Packages were already installed in the Dockerfile layer."
else
  # ── Detect package manager ─────────────────────────────────────────────────
  section "Detecting package manager"

  if command -v apt-get &>/dev/null; then
    PM="apt-get"
    PM_INSTALL="sudo apt-get install -y"
    PM_UPDATE="sudo apt-get update -y"
    info "Using apt-get (Debian/Ubuntu)"
  elif command -v dnf &>/dev/null; then
    PM="dnf"
    PM_INSTALL="sudo dnf install -y"
    PM_UPDATE="sudo dnf check-update || true"
    info "Using dnf (Fedora/RHEL)"
  elif command -v pacman &>/dev/null; then
    PM="pacman"
    PM_INSTALL="sudo pacman -S --noconfirm"
    PM_UPDATE="sudo pacman -Sy"
    info "Using pacman (Arch)"
  else
    error "No supported package manager found (apt-get / dnf / pacman)."
    exit 1
  fi

  # ── Update index ─────────────────────────────────────────────────────────
  section "Updating package index"
  eval "$PM_UPDATE" && ok "Index updated" || warn "Index update failed (continuing)"

  # ── Install packages ──────────────────────────────────────────────────────
  section "Installing packages"

  INSTALLED=()
  SKIPPED=()
  FAILED=()

  for pkg in "${PACKAGES[@]}"; do
    already_installed=false

    case "$PM" in
      apt-get) dpkg -s "$pkg" &>/dev/null && already_installed=true ;;
      dnf)     rpm  -q "$pkg" &>/dev/null && already_installed=true ;;
      pacman)  pacman -Q "$pkg" &>/dev/null && already_installed=true ;;
    esac

    if $already_installed; then
      ok "Already installed: ${BOLD}${pkg}${RESET}"
      SKIPPED+=("$pkg")
    else
      info "Installing ${BOLD}${pkg}${RESET} ..."
      if eval "$PM_INSTALL $pkg" &>/dev/null; then
        ok "Installed: ${BOLD}${pkg}${RESET}"
        INSTALLED+=("$pkg")
      else
        error "Failed to install: ${BOLD}${pkg}${RESET}"
        FAILED+=("$pkg")
      fi
    fi
  done

  # ── Starship fallback ─────────────────────────────────────────────────────
  if ! command -v starship &>/dev/null; then
    info "starship not found via package manager — using official installer..."
    if curl -sS https://starship.rs/install.sh | sh -s -- --yes &>/dev/null; then
      ok "starship installed via curl"
      INSTALLED+=("starship (curl)")
    else
      error "starship installation failed"
      FAILED+=("starship")
    fi
  fi

  # ── Summary ───────────────────────────────────────────────────────────────
  section "Installation summary"

  echo -e "\n  ${GREEN}${BOLD}Newly installed${RESET} (${#INSTALLED[@]}):"
  for p in "${INSTALLED[@]}"; do echo -e "    ✓ $p"; done

  echo -e "\n  ${CYAN}${BOLD}Already present${RESET} (${#SKIPPED[@]}):"
  for p in "${SKIPPED[@]}"; do echo -e "    · $p"; done

  if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo -e "\n  ${RED}${BOLD}Failed${RESET} (${#FAILED[@]}):"
    for p in "${FAILED[@]}"; do echo -e "    ✗ $p"; done
  fi
fi

# =============================================================================
#  4. COPY CONFIG FILES
# =============================================================================
section "Copying configuration files"

if [[ ! -d "$CONFIG_DIR" ]]; then
  warn "Config directory not found at '${CONFIG_DIR}'. Skipping."
else
  for entry in "${CONFIG_MAP[@]}"; do
    src_rel="${entry%%:*}"
    dst_raw="${entry##*:}"
    src="${CONFIG_DIR}/${src_rel}"
    dst="${dst_raw/\~/$HOME}"

    if [[ ! -f "$src" ]]; then
      warn "Source not found, skipping: ${src}"
      continue
    fi

    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    if [[ -f "$dst" ]]; then
      backup="${dst}.backup"
      mv "$dst" "$backup"
      warn "Backed up: ${dst} → ${backup}"
    fi

    cp "$src" "$dst"
    ok "Copied: ${src_rel} → ${dst}"
  done
fi

# =============================================================================
#  5. MANUAL INSTALLATION RECOMMENDATIONS
# =============================================================================
section "Manual installation recommendations"

echo -e "
  The following tools ${BOLD}cannot / should not${RESET} be installed automatically:

  ${YELLOW}${BOLD}🦊  Firefox${RESET}
      Flatpak:  flatpak install flathub org.mozilla.firefox
      Or via:   https://www.mozilla.org/firefox/

  ${YELLOW}${BOLD}🆚  Visual Studio Code${RESET}
      Flatpak:  flatpak install flathub com.visualstudio.code
      Or .deb:  https://code.visualstudio.com/Download

  ${YELLOW}${BOLD}📝  Sublime Text${RESET}
      Flatpak:  flatpak install flathub com.sublimetext.three
      Or repo:  https://www.sublimetext.com/docs/linux_repositories.html

  ${CYAN}${BOLD}💡  Flatpak tip${RESET}
      flatpak remote-add --if-not-exists flathub \\
        https://flathub.org/repo/flathub.flatpakrepo

  ${CYAN}${BOLD}🐚  Set zsh as default shell${RESET} (host only)
      chsh -s \$(which zsh) && logout

  ${CYAN}${BOLD}🖥️  Kitty terminal${RESET} (host only — latest version)
      curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

"

echo -e "${GREEN}${BOLD}Setup complete!${RESET} 🎉\n"
