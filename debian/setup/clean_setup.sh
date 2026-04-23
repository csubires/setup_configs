#!/usr/bin/env bash
# ---------------------------------------------
# Filename: clean_setup.sh
# Version: 2.0
# By: CSUBIRES <j3xuz_cobmetal88@hotmail.com>
# Created: 2024/08/12 08:14:10 by CSUBIRES
# Updated: 2024/12/01 00:00:00 by CSUBIRES
# Description: Advanced Linux cleanup and security hardening script
# ---------------------------------------------

source utils.sh

USER=user
LOG_FILE="/var/log/clean_setup.log"

# Logging function
function log_action()
{
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | sudo tee -a "$LOG_FILE" >/dev/null
}

# Help Panel
function helpPanel()
{
	clear
	lg_prt "wobv" "\n Usage:" "./clean_setup.sh" "<Option>"
	lg_prt "bw" "\t-i" "Show reclaimable space"
	lg_prt "bw" "\t-c" "Clean system"
	lg_prt "bw" "\t-m" "Optimize system performance"
	lg_prt "bw" "\t-s" "Security hardening"
	lg_prt "bw" "\t-d" "Deep cleanup (aggressive)"
	lg_prt "wc" "\n Examples:\n" "\t./clean_setup.sh -c"
	lg_prt "c" "\t./clean_setup.sh -m"
	lg_prt "c" "\t./clean_setup.sh -s"
	lg_prt "c" "\t./clean_setup.sh -d"
}

# System space information
function infoSize()
{
	clear
    lg_prt "y" "\n\t[+] Total and free system space\n"
    df -h
	lg_prt "y" "\n\t[+] Memory\n"
	free -h
	lg_prt "y" "\n\t[+] Application cache size\n"
	du -sh /var/cache/apt
	lg_prt "y" "\n\t[+] Thumbnail cache size\n"
	du -sh /home/$USER/.cache/thumbnails
	lg_prt "y" "\n\t[+] Size of \"/var\" directory\n"
	du -sch /var/*
	lg_prt "y" "\n\t[+] Size of \"/tmp\" directory\n"
	du -sch /tmp
	lg_prt "y" "\n\t[+] Size of \"/var/log\" directory\n"
	du -h /var/log/
	lg_prt "y" "\n\t[+] User home directory size \"/home/$USER\"\n"
	du -bsh /home/$USER/
	lg_prt "y" "\n\t[+] Journalctl disk usage\n"
	journalctl --disk-usage
	lg_prt "y" "\n\t[+] System kernels list\n"
	dpkg --list 'linux-image*' | grep linux-image
	lg_prt "g" "[✔] Task completed\n"
}

# Prompt for user confirmation
function askConfirmation()
{
    local message="$1"
    local response
    read -p "$message (y/N): " -n 1 -r response
    echo ""
    [[ $response =~ ^[Yy]$ ]]
}

# Deep cleanup function
function deepCleanup()
{
    clear
    lg_prt "y" "\n\t[▲] Starting DEEP Linux cleanup (AGGRESSIVE)\n"
    lg_prt "r" "\t[!] WARNING: This operation is aggressive and may remove important data!\n"

    if ! askConfirmation "Continue with deep cleanup?"; then
        lg_prt "y" "\t[!] Deep cleanup cancelled"
        return
    fi

    # 1. Clean all package caches aggressively
    lg_prt "y" "\t[+] Cleaning package caches aggressively..."
    sudo apt clean
    sudo apt autoclean
    sudo apt autoremove --purge -y
    sudo rm -rf /var/lib/apt/lists/*
    sudo mkdir -p /var/lib/apt/lists/partial
    sudo rm -rf /var/cache/apt/archives/old/*
    sudo rm -rf /var/cache/debconf/*
    log_action "Deep package cache cleanup completed"

    # 2. Remove orphaned packages
    if askConfirmation "Remove orphaned packages?"; then
        lg_prt "y" "\t[+] Removing orphaned packages..."
        sudo deborphan | xargs sudo apt remove --purge -y
        log_action "Orphaned packages removed"
    fi

    # 3. Clean all cache directories
    lg_prt "y" "\t[+] Cleaning system caches..."
    sudo rm -rf /var/cache/apt/archives/*
    sudo rm -rf /var/cache/debconf/*
    sudo rm -rf /var/cache/fontconfig/*
    sudo rm -rf /var/cache/man/*
    log_action "System caches cleaned"

    # 4. Clean thumbnail and user caches
    lg_prt "y" "\t[+] Cleaning user caches..."
    rm -rf /home/$USER/.cache/thumbnails/* 2>/dev/null
    rm -rf /home/$USER/.cache/* 2>/dev/null
    rm -rf /home/$USER/.thumbnails/* 2>/dev/null
    rm -rf /home/$USER/.local/share/Trash/* 2>/dev/null
    rm -rf /home/$USER/.local/share/recently-used.xbel 2>/dev/null
    log_action "User caches cleaned"

    # 5. Clean temporary files aggressively
    lg_prt "y" "\t[+] Cleaning temporary files..."
    sudo find /tmp -type f -atime +1 -delete 2>/dev/null
    sudo find /var/tmp -type f -atime +1 -delete 2>/dev/null
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
    log_action "Temporary files cleaned"

    # 6. Clean old logs aggressively
    lg_prt "y" "\t[+] Cleaning old logs..."
    sudo find /var/log -name "*.gz" -delete 2>/dev/null
    sudo find /var/log -name "*.old" -delete 2>/dev/null
    sudo find /var/log -name "*.1" -delete 2>/dev/null
    sudo find /var/log -name "*.log.*" -delete 2>/dev/null
    sudo journalctl --vacuum-time=1d
    sudo journalctl --vacuum-size=1M
    log_action "Old logs cleaned"

    # 7. Remove old kernels automatically
    if askConfirmation "Remove old kernels automatically?"; then
        lg_prt "y" "\t[+] Removing old kernels..."
        current_kernel=$(uname -r | sed 's/-generic//g')
        old_kernels=$(dpkg -l | grep 'linux-image' | grep -v "$current_kernel" | grep -v 'ii' | awk '{print $2}')

        if [ -n "$old_kernels" ]; then
            sudo apt remove --purge $old_kernels -y
            sudo update-grub
            log_action "Old kernels removed: $old_kernels"
        else
            lg_prt "y" "\t[!] No old kernels found"
        fi
    fi

    # 8. Clean browser caches
    if askConfirmation "Clean browser caches?"; then
        lg_prt "y" "\t[+] Cleaning browser caches..."
        rm -rf /home/$USER/.mozilla/firefox/*/Cache/* 2>/dev/null
        rm -rf /home/$USER/.config/google-chrome/*/Cache/* 2>/dev/null
        rm -rf /home/$USER/.config/chromium/*/Cache/* 2>/dev/null
        log_action "Browser caches cleaned"
    fi

    lg_prt "g" "\n\t[✔] Deep cleanup completed\n"
}

function cleanLinux()
{
    clear
    lg_prt "y" "\n\t[▲] Starting Linux cleanup\n"

    # 1. Clean package cache
    if askConfirmation "1.) Remove packages from application cache?"; then
        lg_prt "y" "\t[+] Cleaning package cache..."
        sudo apt clean
        sudo apt autoclean
        sudo apt autoremove --purge -y
        log_action "Package cache cleaned"
        lg_prt "g" "\t[✔] Package cache cleaned"
    fi

    # 2. Clean thumbnail cache
    if askConfirmation "2.) Remove thumbnail cache?"; then
        lg_prt "y" "\t[+] Cleaning thumbnail cache..."
        rm -rf /home/$USER/.cache/thumbnails/ 2>/dev/null && lg_prt "g" "\t[✔] Thumbnail cache cleaned" || lg_prt "r" "\t[✖] No thumbnail cache found"
        log_action "Thumbnail cache cleaned"
    fi

    # 3. Clean journalctl logs
    if askConfirmation "3.) Remove \"journalctl\" logs?"; then
        lg_prt "y" "\t[+] Cleaning journalctl logs..."
        sudo journalctl --vacuum-time=7d
        sudo journalctl --vacuum-size=5M
        log_action "Journalctl logs cleaned"
        lg_prt "g" "\t[✔] Journalctl logs cleaned"
    fi

    # 4. Clean system logs
    if askConfirmation "4.) Remove all system logs?"; then
        lg_prt "y" "\t[+] Cleaning system logs..."
        sudo find /var/log -name "*.log" -type f -delete 2>/dev/null && lg_prt "g" "\t[✔] System logs cleaned" || lg_prt "r" "\t[✖] Unable to clean system logs"
        log_action "System logs cleaned"
    fi

    # 5. Old kernels
    if askConfirmation "5.) Remove old kernels?"; then
        lg_prt "y" "\n\t[▲] It's better to do this manually!\n"
        lg_prt "y" "\tList kernels:  dpkg --list 'linux-image*' | grep linux-image"
        lg_prt "y" "\tRemove kernel: sudo apt remove linux-image-VERSION"
        lg_prt "y" "\tPurge kernel:  sudo apt purge linux-image-x.x.x.x-generic"
        lg_prt "y" "\tsudo dpkg --purge \$(dpkg -l | grep '^rc' | awk '{print \$2}')"
    fi

    # 6. Clean temporary files
    if askConfirmation "6.) Clean temporary files?"; then
        lg_prt "y" "\t[+] Cleaning temporary files..."
        sudo find /tmp -type f -atime +7 -delete 2>/dev/null && lg_prt "g" "\t[✔] Old temporary files cleaned" || lg_prt "r" "\t[✖] Unable to clean temporary files"
        log_action "Temporary files cleaned"
    fi

    # 7. Clean user cache
    if askConfirmation "7.) Clean user cache?"; then
        lg_prt "y" "\t[+] Cleaning user cache..."
        rm -rf /home/$USER/.cache/* 2>/dev/null && lg_prt "g" "\t[✔] User cache cleaned" || lg_prt "r" "\t[✖] Unable to clean user cache"
        log_action "User cache cleaned"
    fi
}

# Security hardening function
function securityHardening()
{
    clear
    lg_prt "y" "\n\t[▲] Starting Linux security hardening\n"

    # 1. Update system
    if askConfirmation "1.) Update system packages?"; then
        lg_prt "y" "\t[+] Updating system..."
        sudo apt update && sudo apt upgrade -y
        log_action "System updated"
        lg_prt "g" "\t[✔] System updated"
    fi

    # 2. Configure firewall
    if askConfirmation "2.) Configure UFW firewall?"; then
        lg_prt "y" "\t[+] Configuring firewall..."
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw --force enable
        log_action "Firewall configured"
        lg_prt "g" "\t[✔] Firewall configured"
    fi

    # 3. Secure shared memory
    if askConfirmation "3.) Secure shared memory?"; then
        lg_prt "y" "\t[+] Securing shared memory..."
        if ! grep -q "tmpfs.*/dev/shm" /etc/fstab; then
            echo "tmpfs     /dev/shm     tmpfs     defaults,noexec,nosuid     0     0" | sudo tee -a /etc/fstab
        fi
        log_action "Shared memory secured"
        lg_prt "g" "\t[✔] Shared memory secured"
    fi

    # 4. Disable root login via SSH
    if askConfirmation "4.) Disable root SSH login?"; then
        lg_prt "y" "\t[+] Disabling root SSH login..."
        sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
        sudo systemctl restart ssh
        log_action "Root SSH login disabled"
        lg_prt "g" "\t[✔] Root SSH login disabled"
    fi

    # 5. Enable fail2ban
    if askConfirmation "5.) Install and configure fail2ban?"; then
        lg_prt "y" "\t[+] Installing fail2ban..."
        sudo apt install fail2ban -y
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        log_action "Fail2ban installed and configured"
        lg_prt "g" "\t[✔] Fail2ban installed and configured"
    fi

    # 6. Harden sysctl settings
    if askConfirmation "6.) Apply kernel security settings?"; then
        lg_prt "y" "\t[+] Applying kernel security settings..."

        # Create security sysctl configuration
        sudo tee /etc/sysctl.d/99-security.conf > /dev/null << 'EOF'
# Network security
net.ipv4.ip_forward=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0

# Memory protection
kernel.dmesg_restrict=1
kernel.kptr_restrict=2
kernel.yama.ptrace_scope=1

# Executable protection
fs.suid_dumpable=0
EOF

        sudo sysctl -p /etc/sysctl.d/99-security.conf
        log_action "Kernel security settings applied"
        lg_prt "g" "\t[✔] Kernel security settings applied"
    fi

    # 7. Remove unnecessary services
    if askConfirmation "7.) Remove unnecessary services?"; then
        lg_prt "y" "\t[+] Removing unnecessary services..."
        sudo systemctl stop bluetooth 2>/dev/null
        sudo systemctl disable bluetooth 2>/dev/null
        sudo apt remove --purge telnet rsh-client rsh-redone-client -y 2>/dev/null
        log_action "Unnecessary services removed"
        lg_prt "g" "\t[✔] Unnecessary services removed"
    fi

    lg_prt "g" "\n\t[✔] Security hardening completed\n"
}

# System hardening/optimization
function hardLinux()
{
    clear
    lg_prt "y" "\n\t[▲] Starting Linux system optimization\n"

    # 1. Optimize swappiness
    if askConfirmation "1.) Optimize swappiness (reduce swap usage)?"; then
        lg_prt "y" "\t[+] Setting swappiness to 10..."
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf >/dev/null
        sudo sysctl vm.swappiness=10
        log_action "Swappiness optimized to 10"
        lg_prt "g" "\t[✔] Swappiness optimized"
    fi

    # 2. Enable filesystem optimization
    if askConfirmation "2.) Enable filesystem cache optimization?"; then
        lg_prt "y" "\t[+] Optimizing filesystem cache..."
        echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf >/dev/null
        sudo sysctl vm.vfs_cache_pressure=50
        log_action "Filesystem cache optimized"
        lg_prt "g" "\t[✔] Filesystem cache optimized"
    fi

    # 3. Disable unnecessary services (be careful with this)
    if askConfirmation "3.) Review and potentially disable rsyslog?"; then
        lg_prt "y" "\t[+] Current rsyslog status:"
        systemctl is-active rsyslog || echo "rsyslog not active"
        if askConfirmation "    Really disable rsyslog? (This may affect logging)"; then
            sudo systemctl stop rsyslog
            sudo systemctl disable rsyslog
            log_action "rsyslog disabled"
            lg_prt "g" "\t[✔] rsyslog disabled"
        fi
    fi

    # 4. Optimize I/O scheduler
    if askConfirmation "4.) Optimize I/O scheduler for SSDs?"; then
        lg_prt "y" "\t[+] Setting I/O scheduler to mq-deadline for SSDs..."
        echo 'ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-iosched.rules >/dev/null
        log_action "I/O scheduler optimized for SSDs"
        lg_prt "g" "\t[✔] I/O scheduler optimized"
    fi
}

# Check if sudo is available
function checkSudo()
{
    if ! sudo -n true 2>/dev/null; then
        lg_prt "y" "[!] This script requires sudo privileges"
        sudo -v || { lg_prt "r" "[✖] Unable to obtain sudo privileges"; exit 1; }
    fi
}

# Create backup before cleanup
function createBackup()
{
    if askConfirmation "Create backup of important files before proceeding?"; then
        lg_prt "y" "\t[+] Creating backup..."
        backup_dir="/home/$USER/backup_cleanup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"

        # Backup important directories
        sudo cp -r /etc/apt/sources.list* "$backup_dir/" 2>/dev/null
        sudo cp -r /etc/ssh/sshd_config "$backup_dir/" 2>/dev/null
        cp -r /home/$USER/.bashrc "$backup_dir/" 2>/dev/null

        lg_prt "g" "\t[✔] Backup created at: $backup_dir"
        log_action "Backup created at: $backup_dir"
    fi
}

# Main execution
function main()
{
    checkSudo
    createBackup

    if [[ ${#} -eq 0 ]]; then
        helpPanel
        exit 0
    fi

    lg_prt "gy" "Path: $(pwd)," "Option: $1"

    case "$1" in
        -i|--info)
            infoSize
            ;;
        -c|--clean)
            cleanLinux
            ;;
        -m|--optimize)
            hardLinux
            ;;
        -s|--security)
            securityHardening
            ;;
        -d|--deep-clean)
            deepCleanup
            ;;
        *)
            helpPanel
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
