#!/bin/sh
set -e

KEYS_DIR=/etc/ssh/host_keys
BANNER=/etc/ssh/banner.txt

# ── Copiar banner al lugar que espera sshd ───────────────────────────────
cp /entrypoint.sh /entrypoint.sh   # no-op; banner ya está en la imagen

# ── Generar claves de host si el volumen está vacío ──────────────────────
if [ ! -f "${KEYS_DIR}/ssh_host_ed25519_key" ]; then
  echo "[entrypoint] Generando clave ed25519..."
  ssh-keygen -t ed25519 -f "${KEYS_DIR}/ssh_host_ed25519_key" -N ""
fi

if [ ! -f "${KEYS_DIR}/ssh_host_rsa_key" ]; then
  echo "[entrypoint] Generando clave RSA 4096..."
  ssh-keygen -t rsa -b 4096 -f "${KEYS_DIR}/ssh_host_rsa_key" -N ""
fi

chmod 600 "${KEYS_DIR}"/ssh_host_*_key
chmod 644 "${KEYS_DIR}"/ssh_host_*_key.pub

# ── Si se pasa SSH_AUTHORIZED_KEY por variable de entorno en runtime ─────
if [ -n "${SSH_AUTHORIZED_KEY}" ] && [ "${SSH_AUTHORIZED_KEY}" != "CHANGE_ME_PUT_YOUR_PUBLIC_KEY_HERE" ]; then
  AUTH_FILE="/home/${SSH_USER}/.ssh/authorized_keys"
  mkdir -p "$(dirname "$AUTH_FILE")"
  echo "${SSH_AUTHORIZED_KEY}" > "$AUTH_FILE"
  chmod 600 "$AUTH_FILE"
  chown "${SSH_USER}:${SSH_USER}" "$AUTH_FILE"
  echo "[entrypoint] authorized_keys configurado para ${SSH_USER}."
fi

echo "[entrypoint] Iniciando sshd..."
exec /usr/sbin/sshd -D -e
