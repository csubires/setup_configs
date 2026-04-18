# =============================================================================
#  Dockerfile — Dev environment based on Debian Bookworm Slim
# =============================================================================
FROM debian:bookworm-slim

# ── Build args (override in docker-compose or --build-arg) ───────────────────
ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000

# ── System base + packages ────────────────────────────────────────────────────
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      # shell & terminal
      zsh \
      nano \
      vim \
      # git & friends
      git \
      curl \
      wget \
      # search & navigation
      fd-find \
      fzf \
      tree \
      # text processing
      bat \
      pandoc \
      # clipboard (headless-safe stub)
      xclip \
      # trash instead of rm
      trash-cli \
      # zsh plugins
      zsh-autosuggestions \
      zsh-syntax-highlighting \
      # misc
      openssl \
      ca-certificates \
      locales \
      # needed to create user
      sudo \
    && \
    # Generate UTF-8 locale
    sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen && \
    # Clean apt cache to keep image lean
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Install Starship (not in Debian repos) ────────────────────────────────────
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# ── Create non-root user ──────────────────────────────────────────────────────
RUN groupadd -g ${DEV_GID} ${DEV_USER} && \
    useradd  -m -u ${DEV_UID} -g ${DEV_GID} -s /bin/zsh ${DEV_USER} && \
    echo "${DEV_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── Switch to user home ───────────────────────────────────────────────────────
USER ${DEV_USER}
WORKDIR /home/${DEV_USER}

# ── Copy setup script + config folder ────────────────────────────────────────
COPY --chown=${DEV_USER}:${DEV_USER} setup.sh  ./setup.sh
COPY --chown=${DEV_USER}:${DEV_USER} config/   ./config/

# ── Run setup (packages already installed above; this applies configs) ────────
RUN chmod +x ./setup.sh && bash ./setup.sh

# ── Default shell & locale env ───────────────────────────────────────────────
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/zsh \
    TERM=xterm-256color

# ── Drop into zsh ─────────────────────────────────────────────────────────────
CMD ["zsh"]
