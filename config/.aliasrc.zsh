# if [ -f ~/.aliasrc.zsh ]; then
    #source ~/.aliasrc.zsh
#fi

# ---- SYSTEM DEFAULT ----
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

alias _="sudo "
alias 1="cd .."
alias 2="cd ../.."
alias 3="cd ../../.."
alias 4="cd ../../../.."
alias 5="cd ../../../../.."
alias 6="cd ../../../../../.."
alias 7="cd ../../../../../../.."
alias 8="cd ../../../../../../../.."
alias 9="cd ../../../../../../../../.."

# --- SYSTEM ALIASES ---
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls --color=auto -la"
alias lc="ls -d */ | xargs realpath"
alias grep="grep --color=auto"
alias latr="ls --color=auto -latr"
alias rezsh="source ~/.zshrc"
alias fd="/usr/bin/fdfind"

# --- VIM ---
alias vi="vim"
alias rczsh="vim ~/.zshrc"
alias rcali="vim ~/.aliasrc.zsh"
alias rcvim="vim ~/.vimrc"
alias rckit="vim ~/.config/kitty/kitty.conf"
alias rcnft="sudo vim /etc/nftables.conf"

# --- UTILITIES ---
alias .bat="batcat"
alias .net="ss -tupan"
alias .cnx="lsof -i"
alias .fop="lsof -u \$USER"
alias .grep="grep -rniI --color=auto"
alias .find="find . -iname"
alias .pwd="openssl rand -base64"
alias .kpwd="openssl rand -base64 32"
alias .demo="systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | head -n 20"
alias .memo="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%mem 2>/dev/null | head -n 15"
alias .cpup="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%cpu 2>/dev/null | head -n 15"
alias .tree="tree -C"

# --- APPLICATIONS ---
alias rmtr="trash-put"
alias blame="systemd-analyze blame"
alias code="flatpak run com.visualstudio.code"
alias sublime="/opt/sublime_text/sublime_text"

# --- CLIPBOARD ---
alias c="xclip -selection clipboard"
alias v="xclip -selection clipboard -o"
alias pc="xclip -selection primary"
alias pp="xclip -selection primary -o"
alias cpwd="pwd | xclip -selection clipboard"

# --- GIT ---
alias glog='git log --oneline --graph --decorate --all -n 15'
alias glogd='git log --graph --pretty=format:"%C(yellow)%h%Creset -%C(red)%d%Creset %s %C(green)(%cr)%Creset %C(blue)<%an>%Creset" --abbrev-commit -10'
alias gstats='git shortlog -sn --all'
gblame() {
    local extension="$1"
    if [[ -z "$extension" ]]; then
        echo "Use: gbla <extension>"
        return 1
    fi
    find . -name "*.$extension" -exec sh -c 'echo "{}:"; git blame "{}" 2>/dev/null | cut -d" " -f2 | sort | uniq -c | sort -nr' \;
}

# --- EXTERNAL FUNCTIONS ---
alias todep="/home/user/Documents/Scripts/todep/todep.sh"
alias syslog="/home/user/Documents/Scripts/syslog.sh"
alias formatcpp="/home/user/Documents/Scripts/format_cpp.sh"
alias formatpython="/home/user/Documents/Scripts/format_py.sh"
alias runkitty="/home/user/Documents/Scripts/run_kitty.sh"

# --- INTERNAL FUNCTIONS ---
myip() { echo "Public IP: $(curl --max-time 3 --silent ipinfo.io/ip 2>/dev/null || echo 'Unable to fetch')" }
texto() { echo "$*" | xclip -selection clipboard }
meval() { eval "$(ssh-agent -s)" && ssh-add ~/.ssh/darkc_git_ed25519 && ssh-add -l }
msize() { du -hc . 2>/dev/null | tail -n 1 }
cdmk() { mkdir -p "$1" && cd "$1" }
cdmktmp() { local dir; dir=$(mktemp -d) && cd "$dir" }
msto() { sudo systemctl restart "$1" }
mres() { sudo systemctl stop "$1" }
md2pdf(){ pandoc "$1" -o "${1%.*}.pdf" --template=eisvogel }

# --- FUNCTIONS LARGE ---
# Create and insert vim in /tmp
vimtmp() {
    local file="temp_$(date +%s).txt"
    touch "$file" && vim "$file"
    echo "$file" | xclip -selection clipboard
}
# Show last history by grep
mhist() {
    local search_term="$1"
    local line_count="${2:-30}"
    if [[ -n "$search_term" ]]; then
        history | grep -- "$search_term" | tail -n "$line_count" | tac |
        awk '{printf "  \033[33m%5d\033[0m %s\n", $1, substr($0, index($0,$2))}'
    else
        history | tail -n "$line_count" | tac |
        awk '{printf "  \033[33m%5d\033[0m %s\n", $1, substr($0, index($0,$2))}'
    fi
}
# copy de last command to clipboard or execute and copy the result in cb
ccmd() {
    if [[ $# -eq 0 ]]; then
        local last_cmd
        last_cmd=$(fc -ln -1 | sed "s/^[[:space:]]*//")
        echo "$last_cmd" | xclip -selection clipboard
    else
        local output
        output=$("$@" 2>&1)
        echo "$output" | xclip -selection clipboard
    fi
}
# fzf with cd
cdfzf() {
    local dir
    dir=$(find . -type d | fzf --height 40% --reverse --preview 'tree -C {} | head -100') && cd "$dir"
}
# Show history with select fzf or not
fzfhi() {
    local search_term="$1"
    local command
    if [[ -n "$search_term" ]]; then
        command=$(history | grep -i "$search_term" | fzf --tac --no-sort --height 40% | sed 's/^ *[0-9]* *//')
    else
        command=$(history | fzf --tac --no-sort --height 40% | sed 's/^ *[0-9]* *//')
    fi
    if [[ -n "$command" ]]; then
        eval "$command"
    else
        echo "Not found"
    fi
}
# Backup of files
backupf() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi
  cp -a "$1" "$1.bak.$(date +%F_%T)"
}
# Use fzf with bat to previsualize
fzfpv() {
    find . -type f 2>/dev/null | fzf --preview="bat --style=numbers --color=always {} 2>/dev/null || head -100 {} 2>/dev/null || echo 'Cannot preview: {}'" \
        --preview-window=right:60%:wrap
}
# Use fzf for open files with vim
fzfvi() {
    local file
    file=$(find . -type f 2>/dev/null | fzf )
    if [[ -n "$file" ]]; then
        vim "$file"
    fi
}
# fzf for search word in text files and select
fzfgr() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        echo "Use: fzfg <str>"
        return 1
    fi
    grep -r -n --color=never "$search_term" . 2>/dev/null | fzf \
        --ansi \
        --delimiter : \
        --preview="bat --color=always --highlight-line {2} --line-number {1} 2>/dev/null" \
        --preview-window=right:60%:wrap
}
# fzf for search files with x string and select
fzfname() {
    local search_term="$1"
    if [[ -z "$search_term" ]]; then
        echo "Use: fzfg <str>"
        return 1
    fi
    find . -type f -name "*$search_term*" 2>/dev/null | fzf \
        --preview="bat --color=always --style=numbers {} 2>/dev/null || head -100 {} 2>/dev/null" \
        --preview-window=right:60%:wrap
}

# --- 42 SPECIFIC ---
#alias francinette="/home/user/francinette/tester.sh"
#alias paco="/home/user/francinette/tester.sh"
alias cursus="cd ~/Documents/GIT/cursus"
alias help42="cd ~/Documents/GIT/help"

# ---- USER CONSTAN ----
# export PYTHONPATH="$HOME/Documents/Projects/modules/modules:$PYTHONPATH"
# export USER="csubires"
# export MAIL="csubires@student.42.fr"

# --- NAVIGATION ---
alias cdgit="cd ~/Documents/GIT"
alias cdbox="cd ~/Documents/box"
alias cdscr="cd ~/Documents/Scripts"
alias cdpro="cd ~/Documents/Projects"
alias cdrep="cd ~/Documents/Repository"
alias cdsha="cd /mnt/hgfs"
alias cdtmp="cd /tmp"
alias cdocs="cd ~/Documents"