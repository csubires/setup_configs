# ── SSH Server – Alpine (imagen ~10 MB resultado final) ──────────────────
FROM alpine:3.20

# Instalar solo lo imprescindible
RUN apk add --no-cache \
        openssh \
        netcat-openbsd \
    && rm -rf /var/cache/apk/*

# ── Copiar configuración sshd endurecida ─────────────────────────────────
COPY sshd_config /etc/ssh/sshd_config

# ── Script de entrypoint (genera claves de host si no existen) ───────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ── Usuario no-root que se usará para acceder ────────────────────────────
ARG SSH_USER=sysadmin
ARG SSH_AUTHORIZED_KEY=""

RUN addgroup -S ${SSH_USER} \
    && adduser  -S -G ${SSH_USER} -s /bin/ash ${SSH_USER} \
    && mkdir -p /home/${SSH_USER}/.ssh \
    && chmod 700 /home/${SSH_USER}/.ssh \
    && chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}

# Escribir clave pública si se pasó como build arg
RUN if [ -n "${SSH_AUTHORIZED_KEY}" ]; then \
      echo "${SSH_AUTHORIZED_KEY}" > /home/${SSH_USER}/.ssh/authorized_keys && \
      chmod 600 /home/${SSH_USER}/.ssh/authorized_keys && \
      chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh/authorized_keys; \
    fi

# Guardar nombre de usuario para el entrypoint
ENV SSH_USER=${SSH_USER}

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
