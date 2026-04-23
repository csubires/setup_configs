# Documentación de Archivos de Configuración

> Generado automáticamente el Tue Apr 21 04:27:02 PM CEST 2026

## vscode_keybindings

**Archivo:** `/home/user/.var/app/com.visualstudio.code/config/Code/User/keybindings.json`

### Contenido

``` bash
 
[
    {
        "key": "shift+space",
        "command": "removeSecondaryCursors",
        "when": "editorHasMultipleSelections && textInputFocus"
    },
    {
        "key": "escape",
        "command": "-removeSecondaryCursors",
        "when": "editorHasMultipleSelections && textInputFocus"
    },
    {
        "key": "ctrl+shift+j",
        "command": "editor.action.joinLines"
	},
	{
		"key": "ctrl+alt+s",
		"command": "workbench.action.files.saveFiles"
	},
	{
		"key": "ctrl+alt+m",
		"command": "workbench.action.quickOpen",
		"args": "**/Makefile",
		"when": "editorTextFocus"
	},
	{
		"key": "ctrl+shift+j",
		"command": "-workbench.action.search.toggleQueryDetails",
		"when": "inSearchEditor || searchViewletFocus"
	},
	{
		"key": "ctrl+shift+[BracketRight]",
		"command": "workbench.view.debug",
		"when": "viewContainer.workbench.view.debug.enabled"
	},
	{
		"key": "ctrl+shift+d",
		"command": "-workbench.view.debug",
		"when": "viewContainer.workbench.view.debug.enabled"
	},
	{
		"key": "ctrl+shift+d",
		"command": "editor.action.copyLinesDownAction",
		"when": "editorTextFocus && !editorReadonly"
	},
	{
		"key": "ctrl+shift+alt+p",
		"command": "workbench.action.terminal.sendSequence",
		"args": {"text": "~/scripts/format_python.sh ${file}\u000D"}
	},
	{
		"key": "ctrl+shift+alt+down",
		"command": "-editor.action.copyLinesDownAction",
		"when": "editorTextFocus && !editorReadonly"
	}
]
 
```

---

## kitty

**Archivo:** `/home/user/.config/kitty/kitty.conf`

### Contenido

``` bash
 
input_delay 0
repaint_delay 2
sync_to_monitor no
shell /bin/zsh
editor vim
font_family FiraMono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 22.0
cursor_shape block
cursor_blink_interval 0
scrollback_lines 500
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
scrollback_pager_history_size 10
wheel_scroll_multiplier 5.0
enable_audio_bell no
visual_bell_duration 0.0
remember_window_size yes
initial_window_width 1200
initial_window_height 800
window_border_width 1
window_margin_width 0
window_padding_width 4
shell_integration enabled
tab_bar_edge bottom
tab_bar_style powerline
tab_title_template "{index} {'/'.join(title.split(':')[-1].split('/')[-2:])}"
tab_bar_min_tabs 1
active_tab_title_template "{title[title.rfind('/')+1:]}"
disable_ligatures never
copy_on_select yes
strip_trailing_spaces smart
detect_urls yes
url_style double
open_url_with default
map ctrl+shift+c send_text all \x03
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
map shift+left neighboring_window left
map shift+right neighboring_window right
map shift+up neighboring_window up
map shift+down neighboring_window down
map alt+| launch --location=hsplit --cwd=current
map alt+minus launch --location=vsplit --cwd=current
enabled_layouts *
confirm_os_window_close 2
map ctrl+shift+q close_os_window
map alt+shift+left resize_window narrower
map alt+shift+right resize_window wider
map alt+shift+up resize_window taller
map alt+shift+down resize_window shorter
map ctrl+t new_tab_with_cwd
map alt+left previous_tab
map alt+right next_tab
map alt+q close_window
map alt+1 goto_tab 1
map alt+2 goto_tab 2
map alt+3 goto_tab 3
map alt+4 goto_tab 4
map alt+5 goto_tab 5
map alt+6 goto_tab 6
map alt+7 goto_tab 7
map alt+8 goto_tab 8
map alt+9 goto_tab 9
map alt+0 goto_tab 10
map ctrl+a send_text all \x01
map ctrl+e send_text all \x05
map ctrl+w send_text all \x17
map ctrl+u send_text all \x15
map alt+b send_text all \x1b\x62
map alt+f send_text all \x1b\x66
map ctrl+plus change_font_size all +1.0
map ctrl+minus change_font_size all -1.0
map ctrl+0 change_font_size all 0
map shift+space next_layout
map f1 copy_to_buffer a
map f2 paste_from_buffer a
mouse_enabled yes
allow_selection yes
mouse_map left click ungrabbed mouse_handle_click selection link prompt
mouse_map left doublepress ungrabbed mouse_handle_click selection word
mouse_map left triplepress ungrabbed mouse_handle_click selection line
hide_window_decorations yes
mouse_hide_wait 3.0
url_color #e4325e
url_style curly
select_by_word_characters @-./_~?&=%+#
adjust_line_height 0
adjust_column_width 0
adjust_baseline 0
cursor #e42626
cursor_text_color #000000
cursor_blink_interval -1
tab_powerline_style slanted
tab_bar_align center
active_tab_foreground #d3cba8
active_tab_background #b3224e
inactive_tab_foreground #9caa9d
inactive_tab_background #707a7a
active_border_color #e75816
inactive_border_color #5bd13e
allow_remote_control no
background            #2b2b2b
color0                #000000
color1                #da4839
color10               #83d082
color11               #ffff7b
color12               #9fcef0
color13               #ffffff
color14               #a0cef0
color15               #ffffff
color2                #509f50
color3                #ffd249
color4                #ffffff
color5                #cfcfff
color6                #6d9cbd
color7                #ffffff
color8                #685159
color9                #ff7b6a
cursor                #ffffff
foreground            #e5e1db
selection_background  #5a637e
selection_foreground  #2b2b2b
 
```

---

## obsidian

**Archivo:** `/home/user/.var/app/md.obsidian.Obsidian/config/obsidian/Preferences`

### Contenido

``` bash
 
{"browser":{"enable_spellchecking":true},"migrated_user_scripts_toggle":true,"partition":{"per_host_zoom_levels":{"9013275520858537997":{}}},"spellcheck":{"dictionaries":["en-US","es","es-419","es-ES","es-US"],"dictionary":""}} 
```

---

## aliaszsh

**Archivo:** `/home/user/.aliasrc.zsh`

### Contenido

``` bash
 
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
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls --color=auto -la"
alias lc="ls -d */ | xargs realpath"
alias grep="grep --color=auto"
alias latr="ls --color=auto -latr"
alias rezsh="source ~/.zshrc"
alias fd="/usr/bin/fdfind"
alias vi="vim"
alias rczsh="vim ~/.zshrc"
alias rcali="vim ~/.aliasrc.zsh"
alias rcvim="vim ~/.vimrc"
alias rckit="vim ~/.config/kitty/kitty.conf"
alias rcnft="sudo vim /etc/nftables.conf"
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
alias rmtr="trash-put"
alias blame="systemd-analyze blame"
alias code="flatpak run com.visualstudio.code"
alias sublime="/opt/sublime_text/sublime_text"
alias c="xclip -selection clipboard"
alias v="xclip -selection clipboard -o"
alias pc="xclip -selection primary"
alias pp="xclip -selection primary -o"
alias cpwd="pwd | xclip -selection clipboard"
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
alias todepall="/home/user/Documents/Scripts/todep/todep_portable.sh"
alias todep="/home/user/Documents/Scripts/todep/todep.sh"
alias syslog="/home/user/Documents/Scripts/syslog.sh"
alias formatcpp="/home/user/Documents/Scripts/format_cpp.sh"
alias formatpython="/home/user/Documents/Scripts/format_py.sh"
alias runkitty="/home/user/Documents/Scripts/run_kitty.sh"
alias help="/home/user/Documents/Scripts/alias_help.sh"
myip() { echo "Public IP: $(curl --max-time 3 --silent ipinfo.io/ip 2>/dev/null || echo 'Unable to fetch')" }
texto() { echo "$*" | xclip -selection clipboard }
meval() { eval "$(ssh-agent -s)" && ssh-add ~/.ssh/darkc_git_ed25519 && ssh-add -l }
msize() { du -hc . 2>/dev/null | tail -n 1 }
cdmk() { mkdir -p "$1" && cd "$1" }
cdmktmp() { local dir; dir=$(mktemp -d) && cd "$dir" }
msto() { sudo systemctl restart "$1" }
mres() { sudo systemctl stop "$1" }
md2pdf(){ pandoc "$1" -o "${1%.*}.pdf" --template=eisvogel }
vimtmp() {
    local file="temp_$(date +%s).txt"
    touch "$file" && vim "$file"
    echo "$file" | xclip -selection clipboard
}
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
cdfzf() {
    local dir
    dir=$(find . -type d | fzf --height 40% --reverse --preview 'tree -C {} | head -100') && cd "$dir"
}
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
backupf() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi
  cp -a "$1" "$1.bak.$(date +%F_%T)"
}
fzfpv() {
    find . -type f 2>/dev/null | fzf --preview="bat --style=numbers --color=always {} 2>/dev/null || head -100 {} 2>/dev/null || echo 'Cannot preview: {}'" \
        --preview-window=right:60%:wrap
}
fzfvi() {
    local file
    file=$(find . -type f 2>/dev/null | fzf )
    if [[ -n "$file" ]]; then
        vim "$file"
    fi
}
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
secrm() {
    for f in "$@"; do
        if [ ! -e "$f" ]; then
            echo "No existe: $f"
            continue
        fi
        read -p "¿Seguro de borrar de forma segura '$f'? [s/N] " conf
        if [[ "$conf" =~ ^[Ss]$ ]]; then
            echo "Borrando: $f"
            if [ -d "$f" ]; then
                find "$f" -type f -exec shred -u -v -z {} \; && rm -r "$f"
            else
                shred -u -v -z "$f"
            fi
        else
            echo "Omitido: $f"
        fi
    done
}
alias cursus="cd ~/Documents/GIT/cursus"
alias help42="cd ~/Documents/GIT/help"
alias cdgit="cd ~/Documents/GIT"
alias cdbox="cd ~/Documents/box"
alias cdscr="cd ~/Documents/Scripts"
alias cdpro="cd ~/Documents/Projects"
alias cdrep="cd ~/Documents/Repository"
alias cdext="cd /mnt/hgfs"
alias cdtmp="cd /tmp"
alias cdocs="cd ~/Documents"
 
```

---

## bash

**Archivo:** `/home/user/.bashrc`

### Contenido

``` bash
 
case $- in
    *i*) ;;
      *) return;;
esac
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias ll='ls -alF'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ls="ls --color=auto"
alias la="ls --color=auto -la"
alias latr="ls --color=auto -latr"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cursus='cd ~/Documents/CAMPUS42/cursus'
alias cd42='cd ~/Documents/CAMPUS42'
alias cdext='cd /mnt/hgfs'
alias cdbox='cd ~/Documents/box'
alias cdscr='cd ~/Documents/Scripts'
alias cdpro='cd ~/Documents/Projects'
alias cdrep='cd ~/Documents/Repository'
alias mi_ip='echo "Public IP: $(curl --max-time 3 --silent ipinfo.io/ip)"'
alias rmsr='shred -zvu -n  5'
alias netp="ss -tupan"
alias vi=vim
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export PATH=$PATH:/usr/local/go/bin
. "$HOME/.cargo/env"
 
```

---

## sublime_keymap

**Archivo:** `/home/user/.config/sublime-text/Packages/User/Default (Linux).sublime-keymap`

### Contenido

``` bash
 
[
	{ "keys": ["alt+up"], "command": "swap_line_up" },
	{ "keys": ["alt+down"], "command": "swap_line_down" },
	{ "keys": ["alt+shift+i"], "command": "split_selection_into_lines" },
	{ "keys": ["shift+space"], "command": "single_selection", "context":
		[
			{ "key": "num_selections", "operator": "not_equal", "operand": 1 }
		]
	},
	{ "keys": ["ctrl+shift+up"], "command": "select_lines", "args": {"forward": false} },
	{ "keys": ["ctrl+shift+down"], "command": "select_lines", "args": {"forward": true} },
	{ "keys": ["ctrl+shift+l"], "command": "find_all_under" },
	{ "keys": ["ctrl+w+k"], "command": "close_all" },
]
 
```

---

## vim

**Archivo:** `/home/user/.vimrc`

### Contenido

``` bash
 
autocmd VimEnter * startinsert
autocmd BufNewFile,BufRead * startinsert
filetype on
syntax on
set number
set cursorline
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1
set mouse=a
set ruler
set clipboard=unnamed
set nobackup
set nowritebackup
set noswapfile
set autoindent
set smarttab
set nowrap
set shiftwidth=4
set tabstop=4
set softtabstop=4
set scrolloff=8
set showmatch
set wildmenu
set nohlsearch
set hlsearch
:colorscheme sorbet
" Pares básicos (solo los que NO tienen conflicto)
inoremap <silent> ( ()<Left>
inoremap <silent> [ []<Left>
inoremap <silent> { {}<Left>
inoremap <silent> ` ``<Left>
" Cierre inteligente
inoremap <expr> ) getline('.')[col('.')-1] == ')' ? "\<Right>" : ')'
inoremap <expr> ] getline('.')[col('.')-1] == ']' ? "\<Right>" : ']'
inoremap <expr> } getline('.')[col('.')-1] == '}' ? "\<Right>" : '}'
inoremap <expr> ` getline('.')[col('.')-1] == '`' ? "\<Right>" : '`'
" Para comillas - versión que SÍ funciona
inoremap <expr> ' SmartQuote("'")
inoremap <expr> " SmartQuote('"')
function! SmartQuote(quote)
    let line = getline('.')
    let col_pos = col('.') - 1
    " Si el siguiente carácter es la misma comilla, saltar sobre ella
    if line[col_pos] == a:quote
        return "\<Right>"
    endif
    " Si no, insertar par de comillas
    return a:quote . a:quote . "\<Left>"
endfunction
" Auto-cierre con Enter para bloques
inoremap {<CR> {<CR>}<Esc>O
inoremap [<CR> [<CR>]<Esc>O
inoremap (<CR> (<CR>)<Esc>O
" Envolver selección con pares
vnoremap ( "zc()<Esc>"zp
vnoremap [ "zc[]<Esc>"zp
vnoremap { "zc{}<Esc>"zp
vnoremap ' "zc''<Esc>"zp
vnoremap " "zc""<Esc>"zp
vnoremap ` "zc``<Esc>"zp
" Para HTML/XML
inoremap < <><Left>
inoremap ><Space> ><Space>
inoremap ><CR> ><CR></<C-X><C-O><Esc>?<<CR>a
" MOREEEEEEE
" Buscar visualmente seleccionado
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
" Reemplazar en todo el proyecto
nnoremap <Leader>r :%s///g<Left><Left><Left>
" Buscar archivos rápidamente
nnoremap <Leader>f :find<Space>
" Deshacer/Rehacer más fácil
nnoremap U <C-r>
" Duplicar línea (como Ctrl+D en otros editores)
nnoremap <C-d> yyp
" Mover líneas arriba/abajo
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
" Línea de estado informativa
set laststatus=2
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
" Explorador de archivos con netrw mejorado
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
" Abrir explorador actual
nnoremap <Leader>e :Lexplore<CR>
" Resaltar línea actual
set cursorline
" Navegar por líneas largas visualmente
nnoremap j gj
nnoremap k gk
" Buscar y centrar pantalla
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
" Guardar con Ctrl+s (como en otros editores)
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
" Salir fácil
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :wq<CR>
" Toggle números
nnoremap <Leader>n :set number!<CR>
" Limpiar búsqueda
nnoremap <silent> <Leader>/ :nohlsearch<CR>
 
```

---

## sublimetext

**Archivo:** `/home/user/.config/sublime-text/Packages/User/Preferences.sublime-settings`

### Contenido

``` bash
 
{
    "font_size": 11,
    "ignored_packages":
    [
        "Vintage"
    ],
    "trim_automatic_white_space": false,
    "update_check": false,
    "theme": "auto",
    "color_scheme": "Mariana.sublime-color-scheme",
    "font_face": "FiraMono Nerd Font",
}
 
```

---

## starship

**Archivo:** `/home/user/.config/starship.toml`

### Contenido

``` bash
 
command_timeout = 500
format = '$directory$git_branch$character'
right_format = """$hostname$username"""
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"
[directory]
truncation_length = 3
truncate_to_repo = true
truncation_symbol = "…/"
style = "bold cyan"
read_only = " 🔒"
read_only_style = "red"
format = "[$path]($style)[$read_only]($read_only_style)"
[directory.substitutions]
[git_branch]
symbol = " "
format = "[$symbol$branch]($style)@"
style = "bold purple"
truncation_length = 20
truncation_symbol = "…"
[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold red"
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"
[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold green"
detect_files = ["package.json"]
detect_folders = ["node_modules"]
not_capable_style = ""
disabled = true
[python]
symbol = " "
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
style = "yellow bold"
detect_extensions = ["py"]
detect_files = [".python-version", "Pipfile", "requirements.txt", "pyproject.toml"]
[rust]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold red"
detect_extensions = ["rs"]
detect_files = ["Cargo.toml"]
[golang]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold cyan"
detect_extensions = ["go"]
detect_files = ["go.mod", "go.sum"]
[docker_context]
symbol = " "
format = "[$symbol$context]($style) "
style = "blue bold"
only_with_files = true
detect_files = ["docker-compose.yml", "docker-compose.yaml", "Dockerfile"]
[time]
disabled = true  # Cambia a false para activar
time_format = "%T"
format = "[$time]($style) "
style = "bold white"
[username]
disabled = false
show_always = false  # Solo muestra en SSH
format = "[$user]($style) in "
style_user = "bold yellow"
style_root = "bold red"
[hostname]
disabled = false
ssh_only = true
format = "[$hostname]($style) in "
style = "bold dimmed green"
[aws]
disabled = true
[gcloud]
disabled = true
[kubernetes]
disabled = true
[terraform]
disabled = true
[helm]
disabled = true
[ruby]
disabled = true
[java]
disabled = true
[php]
disabled = true
[lua]
disabled = true
[perl]
disabled = true
[package]
disabled = true
 
```

---

## nano

**Archivo:** `/home/user/.nanorc`

### Contenido

``` bash
 
include /usr/share/nano/default.nanorc
include /usr/share/nano/*.nanorc
set tabsize 4
set tabstospaces
set autoindent
set trimblanks
set linenumbers
set softwrap
set multibuffer
set mouse
set positionlog
set historylog
set nowrap
set casesensitive
 
```

---

## vscode_main

**Archivo:** `/home/user/.var/app/com.visualstudio.code/config/Code/User/settings.json`

### Contenido

``` bash
 
{
	"telemetry.telemetryLevel": "off",
	"redhat.telemetry.enabled": false,
	"update.showReleaseNotes": false,
	"workbench.enableExperiments": false,
	"workbench.settings.enableNaturalLanguageSearch": false,
	"editor.parameterHints.enabled": false,
	"editor.hover.enabled": "off",
	"workbench.startupEditor": "none",
	"security.workspace.trust.enabled": false,
	"workbench.onlineServicesOpenOffice": false,
	"gitlens.telemetry.enabled": false,
	"github.copilot.enable": {
		"*": false
	},
	"42header.email": "csubires@student.42.fr",
	"42header.username": "csubires",
	"editor.formatOnSave": false,
	"editor.bracketPairColorization.independentColorPoolPerBracketType": true,
	"editor.cursorBlinking": "phase",
	"editor.cursorStyle": "line-thin",
	"editor.detectIndentation": false,
	"editor.guides.bracketPairs": true,
	"editor.guides.indentation": true,
	"editor.linkedEditing": true,
	"editor.renderWhitespace": "all",
	"editor.tabSize": 4,
	"editor.insertSpaces": false,
	"files.insertFinalNewline": true,
	"files.trimFinalNewlines": true,
	"files.trimTrailingWhitespace": true,
	"editor.trimAutoWhitespace": true,
	"terminal.integrated.cursorStyle": "line",
	"git.enabled": false,
	"extensions.ignoreRecommendations": true,
	"update.mode": "none",
	"extensions.autoCheckUpdates": false,
	"extensions.autoUpdate": false,
	"python.linting.enabled": true,
	"python.linting.pylintEnabled": false,
	"python.linting.flake8Enabled": true,
	"python.linting.lintOnSave": true,
	"python.formatting.provider": "autopep8",
	"python.linting.flake8Args": [
		"--max-line-length=88",
		"--ignore=W191,E501,F405,E203,W503"
	],
	"workbench.sideBar.location": "right",
	"workbench.colorTheme": "Monokai",
	"workbench.colorCustomizations": {
		"activityBar.background": "#c6d3c1",
		"activityBar.foreground": "#af970c",
		"activityBar.inactiveForeground": "#15581c",
		"sideBar.background": "#01355c",
		"sideBar.foreground": "#ffffff",
		"editorGroupHeader.tabsBorder": "#fff",
		"editorGroupHeader.border": "#68c01f",
		"tab.activeBackground": "#c42e23",
		"tab.border": "#68c01f",
		"terminal.background": "#0b1f30",
		"terminal.foreground": "#bb0633",
		"terminalCursor.background": "#c42e23",
		"terminal.border": "#c42e23",
		"terminal.tab.activeBorder": "#72971c",
		"terminal.selectionForeground": "#6aa84f",
	},
	"folder-path-color.folders": [
		{ "path": "libft", "symbol": "00", "tooltip": "PROJECT42" },
		{ "path": "ft_printf", "symbol": "01", "tooltip": "PROJECT42" },
		{ "path": "get_next_line", "symbol": "02", "tooltip": "PROJECT42" },
		{ "path": "born2beroot", "color": "green", "symbol": "03", "tooltip": "PROJECT42" },
		{ "path": "minitalk", "symbol": "04", "tooltip": "PROJECT42" },
		{ "path": "fdf", "symbol": "05", "tooltip": "PROJECT42" },
		{ "path": "push_swap", "symbol": "06", "tooltip": "PROJECT42" },
		{ "path": "philosophers", "symbol": "07", "tooltip": "PROJECT42" },
		{ "path": "minishell", "color": "yellow", "symbol": "08", "tooltip": "PROJECT42" },
		{ "path": "cpp", "symbol": "09", "tooltip": "PROJECT42" },
		{ "path": "netpractice", "color": "green", "symbol": "10", "tooltip": "PROJECT42" },
		{ "path": "cub3d", "color": "yellow", "symbol": "11", "tooltip": "PROJECT42" },
		{ "path": "inception", "color": "green", "symbol": "13", "tooltip": "PROJECT42" },
		{ "path": "webserv", "color": "yellow", "symbol": "12", "tooltip": "PROJECT42" },
		{ "path": "ft_transcendence", "color": "red", "symbol": "⭐", "tooltip": "PROJECT42" },
		{ "path": "42_Collaborative_resume", "color": "red", "symbol": "⭐", "tooltip": "PROJECT42" },
	],
	"[python]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": true,
		"editor.rulers": [79, 99],
		"editor.wordWrapColumn": 99
	},
	"[c]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80]
	},
	"[cpp]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80]
	},
	"files.associations": {
		"*.bash": "shellscript",
		"*.bats": "shellscript",
		"*.inc": "shellscript",
		"*.zsh": "shellscript"
	},
	"editor.bracketPairColorization.enabled": true,
	"editor.folding": true,
	"editor.foldingImportsByDefault": true,
	"editor.language.bash.suggest.completeFunctionCalls": true,
	"[shellscript]": {
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80, 120],
		"editor.wordWrapColumn": 120,
		"editor.formatOnSave": false,
		"editor.autoIndent": "full",
		"editor.tokenColorCustomizations": {
			"textMateRules": [
				{
					"scope": "entity.name.function.shell",
					"settings": { "foreground": "#569CD6" }
				},
				{
					"scope": "variable.other.normal.shell",
					"settings": { "foreground": "#9CDCFE" }
				},
				{
					"scope": "string.quoted.double.shell",
					"settings": { "foreground": "#CE9178" }
				}
			]
		}
	},
	"python.analysis.autoIndent": false,
	"workbench.secondarySideBar.defaultVisibility": "hidden",
	"flake8.enabled": false,
	"editor.fontFamily": "'FiraMono Nerd Font', monospace",
	/*
	"terminal.integrated.profiles.linux": {
		"bash": {
			"path": "/usr/bin/flatpak-spawn",
			"icon": "terminal-bash",
			"args": [
				"--host",
				"--env=TERM=xterm-256color",
				"bash"
			]
		},
		"zsh": {
			"path": "/usr/bin/flatpak-spawn",
			"args": [
				"--host",
				"--env=TERM=xterm-256color",
				"zsh"
			]
		},
	},
	"terminal.integrated.defaultProfile.linux": "zsh",
	*/
}
 
```

---

## zsh

**Archivo:** `/home/user/.zshrc`

### Contenido

``` bash
 
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
unsetopt correct_all
setopt NO_NOMATCH
DISABLE_AUTO_TITLE="true"
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
export PATH=$HOME/.brew/bin:$PATH
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/.local/bin:$PATH"
export GITEA_PASS=D0ckercontain3R#hOy
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    nvm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm "$@"
    }
    node() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        node "$@"
    }
    npm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        npm "$@"
    }
    npx() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        npx "$@"
    }
fi
if [ -f ~/.aliasrc.zsh ]; then
    source ~/.aliasrc.zsh
fi
bindkey -e
export KEYTIMEOUT=20
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[^?' backward-kill-word
eval "$(starship init zsh)"
 
```

---

## vscode_git

**Archivo:** `/home/user/Documents/GIT/42_commoncore/.vscode/settings.json`

### Contenido

``` bash
 
{
	"telemetry.telemetryLevel": "off",
	"redhat.telemetry.enabled": false,
	"update.showReleaseNotes": false,
	"workbench.enableExperiments": false,
	"workbench.settings.enableNaturalLanguageSearch": false,
	"editor.parameterHints.enabled": false,
	"editor.hover.enabled": "off",
	"workbench.startupEditor": "none",
	"security.workspace.trust.enabled": false,
	"workbench.onlineServicesOpenOffice": false,
	"gitlens.telemetry.enabled": false,
	"github.copilot.enable": {
		"*": false
	},
	"42header.email": "csubires@student.42.fr",
	"42header.username": "csubires",
	"editor.formatOnSave": false,
	"editor.bracketPairColorization.independentColorPoolPerBracketType": true,
	"editor.cursorBlinking": "phase",
	"editor.cursorStyle": "line-thin",
	"editor.detectIndentation": false,
	"editor.guides.bracketPairs": true,
	"editor.guides.indentation": true,
	"editor.linkedEditing": true,
	"editor.renderWhitespace": "all",
	"editor.tabSize": 4,
	"editor.insertSpaces": false,
	"files.insertFinalNewline": true,
	"files.trimFinalNewlines": true,
	"files.trimTrailingWhitespace": true,
	"editor.trimAutoWhitespace": true,
	"terminal.integrated.cursorStyle": "line",
	"git.enabled": false,
	"extensions.ignoreRecommendations": true,
	"update.mode": "none",
	"extensions.autoCheckUpdates": false,
	"extensions.autoUpdate": false,
	"python.linting.enabled": true,
	"python.linting.pylintEnabled": false,
	"python.linting.flake8Enabled": true,
	"python.linting.lintOnSave": true,
	"python.formatting.provider": "autopep8",
	"python.linting.flake8Args": [
		"--max-line-length=88",
		"--ignore=W191,E501,F405,E203,W503"
	],
	"workbench.sideBar.location": "right",
	"workbench.colorTheme": "Monokai",
	"workbench.colorCustomizations": {
		"activityBar.background": "#c6d3c1",
		"activityBar.foreground": "#af970c",
		"activityBar.inactiveForeground": "#15581c",
		"sideBar.background": "#01355c",
		"sideBar.foreground": "#ffffff",
		"editorGroupHeader.tabsBorder": "#fff",
		"editorGroupHeader.border": "#68c01f",
		"tab.activeBackground": "#c42e23",
		"tab.border": "#68c01f",
		"terminal.background": "#0b1f30",
		"terminal.foreground": "#bb0633",
		"terminalCursor.background": "#c42e23",
		"terminal.border": "#c42e23",
		"terminal.tab.activeBorder": "#72971c",
		"terminal.selectionForeground": "#6aa84f",
	},
	"folder-path-color.folders": [
		{ "path": "00-libft", "symbol": "00", "tooltip": "COMMONCORE42" },
		{ "path": "01-ft_printf", "symbol": "01", "tooltip": "COMMONCORE42" },
		{ "path": "02-get_next_line", "symbol": "02", "tooltip": "COMMONCORE42" },
		{ "path": "03-born2beroot", "color": "green", "symbol": "03", "tooltip": "COMMONCORE42" },
		{ "path": "04-minitalk", "symbol": "04", "tooltip": "COMMONCORE42" },
		{ "path": "05-fdf", "symbol": "05", "tooltip": "COMMONCORE42" },
		{ "path": "06-push_swap", "symbol": "06", "tooltip": "COMMONCORE42" },
		{ "path": "07-philosophers", "symbol": "07", "tooltip": "COMMONCORE42" },
		{ "path": "08-minishell", "color": "yellow", "symbol": "08", "tooltip": "COMMONCORE42" },
		{ "path": "09-cpp", "symbol": "09", "tooltip": "COMMONCORE42" },
		{ "path": "10-netpractice", "color": "green", "symbol": "10", "tooltip": "COMMONCORE42" },
		{ "path": "11-cub3d", "color": "yellow", "symbol": "11", "tooltip": "COMMONCORE42" },
		{ "path": "12-inception", "color": "green", "symbol": "12", "tooltip": "COMMONCORE42" },
		{ "path": "13-webserv", "color": "yellow", "symbol": "13", "tooltip": "COMMONCORE42" },
		{ "path": "14-ft_transcendence", "color": "red", "symbol": "14", "tooltip": "COMMONCORE42" },
		{ "path": "15-42_Collaborative_resume", "color": "red", "symbol": "15", "tooltip": "COMMONCORE42" },
	],
	"[python]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": true,
		"editor.rulers": [79, 99],
		"editor.wordWrapColumn": 99
	},
	"[c]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80]
	},
	"[cpp]": {
		"editor.formatOnSave": false,
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80]
	},
	"files.associations": {
		"*.bash": "shellscript",
		"*.bats": "shellscript",
		"*.inc": "shellscript",
		"*.zsh": "shellscript"
	},
	"editor.bracketPairColorization.enabled": true,
	"editor.folding": true,
	"editor.foldingImportsByDefault": true,
	"editor.language.bash.suggest.completeFunctionCalls": true,
	"[shellscript]": {
		"editor.tabSize": 4,
		"editor.insertSpaces": false,
		"editor.detectIndentation": false,
		"editor.rulers": [80, 120],
		"editor.wordWrapColumn": 120,
		"editor.formatOnSave": false,
		"editor.autoIndent": "full",
		"editor.tokenColorCustomizations": {
			"textMateRules": [
				{
					"scope": "entity.name.function.shell",
					"settings": { "foreground": "#569CD6" }
				},
				{
					"scope": "variable.other.normal.shell",
					"settings": { "foreground": "#9CDCFE" }
				},
				{
					"scope": "string.quoted.double.shell",
					"settings": { "foreground": "#CE9178" }
				}
			]
		}
	},
	/*
	"terminal.integrated.profiles.linux": {
		"bash": {
			"path": "/usr/bin/flatpak-spawn",
			"icon": "terminal-bash",
			"args": [
				"--host",
				"--env=TERM=xterm-256color",
				"bash"
			]
		},
		"zsh": {
			"path": "/usr/bin/flatpak-spawn",
			"args": [
				"--host",
				"--env=TERM=xterm-256color",
				"zsh"
			]
		},
	},
	"terminal.integrated.defaultProfile.linux": "zsh",
	*/
}
 
```

---


> sudo apt install vim nano zsh git curl wget tree bat xclip trash-cli openssl fd-find fzf kitty
> sudo apt install zsh-autosuggestions zsh-syntax-highlighting
> curl -sS https://starship.rs/install.sh | sh
> source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
