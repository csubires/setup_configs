# Docker Stack · Nginx + SSH

Stack mínimo y seguro con:
- **Nginx Alpine** – servidor web con headers de seguridad
- **OpenSSH Alpine** – servidor SSH hardened, solo clave pública

---

## Estructura de ficheros

```
docker-stack/
├── docker-compose.yml
├── .env                        ← variables de configuración
├── nginx/
│   ├── nginx.conf              ← configuración global endurecida
│   ├── conf.d/
│   │   └── default.conf        ← virtual host
│   └── html/
│       ├── index.html          ← página de prueba
│       └── 404.html
└── ssh/
    ├── Dockerfile
    ├── sshd_config             ← configuración SSH hardened
    ├── banner.txt              ← banner de acceso
    ├── entrypoint.sh           ← genera claves y arranca sshd
    └── keys/                   ← claves de host (autogeneradas, persistentes)
```

---

## Inicio rápido

### 1. Configurar la clave pública SSH

Edita `.env` y sustituye el valor de `SSH_AUTHORIZED_KEY` por tu clave pública:

```bash
# Mostrar tu clave pública
cat ~/.ssh/id_ed25519.pub
```

Luego pégala en `.env`:

```
SSH_AUTHORIZED_KEY=ssh-ed25519 AAAA... tu@maquina
```

Si aún no tienes clave SSH:

```bash
ssh-keygen -t ed25519 -C "tu@email.com"
```

### 2. Construir y arrancar

```bash
docker compose up -d --build
```

### 3. Verificar

```bash
# Ver estado de los contenedores
docker compose ps

# Ver logs
docker compose logs -f

# Probar la web
curl http://localhost:8080

# Conectar por SSH
ssh -p 2222 sysadmin@localhost
```

---

## Variables de entorno (.env)

| Variable            | Defecto    | Descripción                          |
|---------------------|------------|--------------------------------------|
| `NGINX_HTTP_PORT`   | `8080`     | Puerto HTTP en el host               |
| `NGINX_HTTPS_PORT`  | `8443`     | Puerto HTTPS en el host (reservado)  |
| `SSH_PORT`          | `2222`     | Puerto SSH en el host                |
| `SSH_USER`          | `sysadmin` | Usuario creado en el contenedor SSH  |
| `SSH_AUTHORIZED_KEY`| —          | Clave pública SSH autorizada         |

---

## Medidas de seguridad implementadas

### Nginx
- `server_tokens off` – oculta versión
- Headers: `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `CSP`, `Referrer-Policy`
- Filesystem en **solo lectura** (`read_only: true`)
- `no-new-privileges` activo
- Bloqueo de archivos ocultos (`.htaccess`, `.env`, etc.)
- Límites de tamaño de body y timeouts

### SSH
- **Sin contraseñas** – solo clave pública
- `PermitRootLogin no`
- X11, TCP forwarding y Agent forwarding desactivados
- Algoritmos modernos: `curve25519`, `chacha20-poly1305`, `aes256-gcm`
- `MaxAuthTries 3`, `LoginGraceTime 20s`
- Banner de advertencia legal
- `cap_drop: ALL` + solo capabilities mínimas

### Docker
- Red interna aislada (`172.28.0.0/24`)
- Healthchecks en ambos servicios
- `restart: unless-stopped`

---

## Parar el stack

```bash
docker compose down          # para y elimina contenedores
docker compose down -v       # también elimina volúmenes (logs)
```

---

## Añadir HTTPS a Nginx

Coloca tu certificado en `nginx/certs/` y añade un nuevo fichero `nginx/conf.d/ssl.conf`:

```nginx
server {
    listen 443 ssl http2;
    server_name tu.dominio.com;

    ssl_certificate     /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305;

    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    root  /usr/share/nginx/html;
    index index.html;
}
```

Y monta el directorio en `docker-compose.yml`:

```yaml
volumes:
  - ./nginx/certs:/etc/nginx/certs:ro
```
