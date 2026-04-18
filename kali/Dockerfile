FROM kalilinux/kali-rolling
kali-linux-large
kali-linux-everything
RUN apt install -y kali-linux-large

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    openssh-server \
    john \
    sublist3r \
    metasploit-framework \
    wfuzz \
    nikto \
    nmap \
    netcat-traditional \
    hydra \
    tcpdump \
    hping3 \
    dsniff \
    mysql-client \
    git \
    curl \
    vim \
    python3 \
    python3-pip \
    && apt clean
VPN container

amass
ffuf
feroxbuster
dirsearch
sqlmap
impacket
responder
bettercap
gobuster
enum4linux
crackmapexec
net-tools
tree
curl
batcat
wget
htop
keymap es
kitty .... etc



# Crear usuario
RUN useradd -m pentester

# Configurar SSH
RUN mkdir /var/run/sshd
RUN mkdir -p /home/pentester/.ssh
COPY authorized_keys /home/pentester/.ssh/authorized_keys

RUN chown -R pentester:penter /home/pentester/.ssh
RUN chmod 700 /home/pentester/.ssh
RUN chmod 600 /home/pentester/.ssh/authorized_keys

# Copiar configuración segura SSH
COPY sshd_config /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]