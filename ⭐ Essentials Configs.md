# Documentación de Archivos de Configuración

> Generado automáticamente el Sat Oct 18 08:16:30 PM CEST 2025

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
		"key": "backspace",
		"command": "workbench.action.search.toggleQueryDetails",
		"when": "inSearchEditor || searchViewletFocus"
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

## obsidian

**Archivo:** `/home/user/.var/app/md.obsidian.Obsidian/config/obsidian/Preferences`

### Contenido

``` bash
{"browser":{"enable_spellchecking":true},"migrated_user_scripts_toggle":true,"partition":{"per_host_zoom_levels":{"9013275520858537997":{}}},"spellcheck":{"dictionaries":["en-US","es","es-419","es-ES","es-US"],"dictionary":""}}```

---

## aliaszsh

**Archivo:** `/home/user/.aliasrc.zsh`

### Contenido

``` bash
1="cd -1"
2="cd -2"
3="cd -3"
4="cd -4"
5="cd -5"
6="cd -6"
7="cd -7"
8="cd -8"
9="cd -9"
_="sudo "
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
alias ll="ls -alF"
alias l="ls -CF"
alias grep="grep --color=auto"
alias ls="ls --color=auto"
alias la="ls --color=auto -la"
alias latr="ls --color=auto -latr"
alias vi="vim"
alias rezsh="source ~/.zshrc"
alias mrm="shred -zvu -n 5"
alias mss="ss -tupan"
alias mcat="batcat"
alias mnet="lsof -i"
alias mfile="lsof -u \$USER"
alias mzsh="vim ~/.zshrc"
alias malias="vim ~/.aliasrc.zsh"
alias mtmux="vim ~/.tmux.conf"
alias mvim="vim ~/.vimrc"
alias msession="tmux new -A -s my_session"
alias mgrep="grep -rniI --color=auto"
alias mfind="find . -iname"
alias mpass="openssl rand -base64"
alias mkpass="openssl rand -base64 32"
alias mdem="systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | head -n 20"
alias mmem="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%mem 2>/dev/null | head -n 15"
alias mcpu="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%cpu 2>/dev/null | head -n 15"
alias mtree="tree -C"
alias todep="/home/user/Documents/Scripts/todep/todep.sh"
alias syslog="/home/user/Documents/Scripts/syslog.sh"
cdfzf() { cd "\$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview=\'tree -C {} | head -100\')" }
fzfp() { fzf --preview=\'batcat --theme=gruvbox-dark --color=always {} 2>/dev/null\' }
fzfv() { vim \$(fzf --preview=\'batcat --theme=gruvbox-dark --color=always {} 2>/dev/null\') }
fzfh() { history | fzf }
fzfg() { grep -r . --line-number --color=always 2>/dev/null | fzf }
alias code="flatpak run com.visualstudio.code"
alias sublime="/opt/sublime_text/sublime_text"
alias rm="trash-put"
alias blame="systemd-analyze blame"
alias docker="podman"
alias docker-compose="podman-compose"
alias c="xclip -selection clipboard"
alias v="xclip -selection clipboard -o"
alias pc="xclip -selection primary"
alias pp="xclip -selection primary -o"
alias cpwd="pwd | xclip -selection clipboard"
alias glog=\'git log --graph -n 5 --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit 2>/dev/null\'
alias gbla=\'f(){ find . -name "*.$1" -exec sh -c \'\\'\'echo "{}:"; git blame "{}" 2>/dev/null | cut -d" " -f2 | sort | uniq -c | sort -nr\'\\'\' \; ; }; f\'
texto() { echo "\$*" | xclip -selection clipboard }
cdmk() { mkdir -p "\$1" && cd "\$1" }
cdmktmp() { local dir; dir=\$(mktemp -d) && cd "\$dir" }
mip() { echo "Public IP: \$(curl --max-time 3 --silent ipinfo.io/ip 2>/dev/null || echo \'Unable to fetch\')" }
meval() { eval "$(ssh-agent -s)" && ssh-add ~/.ssh/darkc_git_ed25519 && ssh-add -l }
ccmd() { fc -ln -1 | sed "s/^[[:space:]]*//" | xclip -selection clipboard }
msize() { du -hc . 2>/dev/null | tail -n 1 }
vimtmp() {
    local file="temp_\$(date +%s).txt"
    touch "\$file" && vim "\$file"
    echo "\$file" | xclip -selection clipboard
}
mhist() {
    local search_term="\$1"
    local line_count="\${2:-30}"
    if [ -n "\$search_term" ]; then
        history | grep -- "\$search_term" | awk \'!seen[\$0]++\' | tail -n "\$line_count" | tac | \
        awk \'{printf "\033[33m%3d\033[0m %s\n", NR, \$0}\'
    else
        history | awk \'!seen[\$0]++\' | tail -n "\$line_count" | tac | \
        awk \'{printf "\033[33m%3d\033[0m %s\n", NR, \$0}\'
    fi
}
alias francinette="/home/user/francinette/tester.sh"
alias paco="/home/user/francinette/tester.sh"
alias cursus="cd ~/Documents/GIT/cursus"
alias help42="cd ~/Documents/GIT/help"
alias cdgit="cd ~/Documents/GIT"
alias cdbox="cd ~/Documents/box"
alias cdscr="cd ~/Documents/Scripts"
alias cdpro="cd ~/Documents/Projects"
alias cdrep="cd ~/Documents/Repository"
alias cdvmw="cd /mnt/hgfs"
alias cdtmp="cd /tmp"
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
    PS1=\'${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \'
else
    PS1=\'${debian_chroot:+($debian_chroot)}\u@\h:\w\$ \'
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
    alias ls=\'ls --color=auto\'
    alias grep=\'grep --color=auto\'
    alias fgrep=\'fgrep --color=auto\'
    alias egrep=\'egrep --color=auto\'
fi
alias ll=\'ls -alF\'
alias l=\'ls -CF\'
alias grep=\'grep --color=auto\'
alias ls="ls --color=auto"
alias la="ls --color=auto -la"
alias latr="ls --color=auto -latr"
alias ..=\'cd ..\'
alias ...=\'cd ../..\'
alias ....=\'cd ../../..\'
alias cursus=\'cd ~/Documents/CAMPUS42/cursus\'
alias cd42=\'cd ~/Documents/CAMPUS42\'
alias cdext=\'cd /mnt/hgfs\'
alias cdbox=\'cd ~/Documents/box\'
alias cdscr=\'cd ~/Documents/Scripts\'
alias cdpro=\'cd ~/Documents/Projects\'
alias cdrep=\'cd ~/Documents/Repository\'
alias mi_ip=\'echo "Public IP: $(curl --max-time 3 --silent ipinfo.io/ip)"\'
alias rmsr=\'shred -zvu -n  5\'
alias netp="ss -tupan"
alias vi=vim
alias alert=\'notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e \'\\'\'s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//\'\\'\')"\'
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
inoremap <silent> \` \`\`<Left>
" Cierre inteligente
inoremap <expr> ) getline(\'.\')[col(\'.\')-1] == \')\' ? "\<Right>" : \')\'
inoremap <expr> ] getline(\'.\')[col(\'.\')-1] == \']\' ? "\<Right>" : \']\'
inoremap <expr> } getline(\'.\')[col(\'.\')-1] == \'}\' ? "\<Right>" : \'}\'
inoremap <expr> \` getline(\'.\')[col(\'.\')-1] == \'\`\' ? "\<Right>" : \'\`\'
" Para comillas - versión que SÍ funciona
inoremap <expr> \' SmartQuote("\'")
inoremap <expr> " SmartQuote(\'"\')
function! SmartQuote(quote)
    let line = getline(\'.\')
    let col_pos = col(\'.\') - 1
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
vnoremap \' "zc\'\'<Esc>"zp
vnoremap " "zc""<Esc>"zp
vnoremap \` "zc\`\`<Esc>"zp
" Para HTML/XML
inoremap < <><Left>
inoremap ><Space> ><Space>
inoremap ><CR> ><CR></<C-X><C-O><Esc>?<<CR>a
" MOREEEEEEE
" Buscar visualmente seleccionado
vnoremap // y/\V<C-R>=escape(@",\'/\\')<CR><CR>
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
vnoremap <A-j> :m \'>+1<CR>gv=gv
vnoremap <A-k> :m \'<-2<CR>gv=gv
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
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\
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
}
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
	"42header.username": "csubires",
	"42header.email": "csubires@student.42.fr",
	"cmake.showOptionsMovedNotification": false,
	"debug.onTaskErrors": "debugAnyway",
	"editor.bracketPairColorization.independentColorPoolPerBracketType": true,
	"editor.cursorBlinking": "phase",
	"editor.cursorStyle": "line-thin",
	"editor.detectIndentation": false,
	"editor.fontSize": 16,
	"editor.guides.bracketPairs": true,
	"editor.insertSpaces": false,
	"editor.linkedEditing": true,
	"editor.suggestFontSize": 16,
	"editor.tabSize": 4,
	"extensions.autoCheckUpdates": false,
	"extensions.autoUpdate": false,
	"extensions.ignoreRecommendations": true,
	"files.insertFinalNewline": true,
	"files.trimFinalNewlines": true,
	"files.trimTrailingWhitespace": true,
	"terminal.integrated.cursorStyle": "line",
	"window.zoomLevel": 0,
	"editor.guides.indentation": true,
	"update.mode": "none",
	"workbench.sideBar.location": "right",
	"workbench.colorTheme": "Monokai",
	"workbench.colorCustomizations": {
		"activityBar.background": "#6aa84f",
		"activityBar.foreground": "#cc0000",
		"activityBar.inactiveForeground": "#003605",
		"sideBar.background": "#105c96",
		"sideBar.foreground": "#ffffff",
		"editorGroupHeader.tabsBorder": "#fff",
		"editorGroupHeader.border": "#fff",
		"tab.activeBackground": "#c42e23",
		"tab.border": "#cc0000",
		"terminal.background": "#ffffff",
		"terminal.foreground": "#000000",
	},
	"folder-path-color.folders": [
		{ "path": "libft", "symbol": "00", "tooltip": "PROJECT42" },
		{ "path": "ft_printf", "symbol": "01", "tooltip": "PROJECT42" },
		{ "path": "get_next_line", "symbol": "02", "tooltip": "PROJECT42" },
		{ "path": "born2beroot", "symbol": "03", "tooltip": "PROJECT42" },
		{ "path": "minitalk", "symbol": "<<", "tooltip": "PROJECT42" },
	],
	"terminal.integrated.profiles.linux": {
		"zsh": {
			"path": "/usr/bin/flatpak-spawn",
			"args": ["--host", "--env=TERM=xterm-256color", "zsh"],
			"overrideName": true,
		}
	},
	"terminal.integrated.defaultProfile.linux": "zsh",
	"workbench.startupEditor": "none",
	"[jsonc]": {
		"editor.defaultFormatter": "esbenp.prettier-vscode"
	},
	"terminal.integrated.allowChords": false,
	"cmake.pinnedCommands": [
		"workbench.action.tasks.configureTaskRunner",
		"workbench.action.tasks.runTask"
	],
	"chat.commandCenter.enabled": false,
	"C_Cpp.default.cStandard": "c23",
	"C_Cpp.default.cppStandard": "c++23",
	"[cpp]": {
		"editor.wordBasedSuggestions": "off",
		"editor.semanticHighlighting.enabled": true,
		"editor.stickyScroll.defaultModel": "foldingProviderModel",
		"editor.suggest.insertMode": "replace"
	},
	"workbench.secondarySideBar.defaultVisibility": "hidden",
	"workbench.layoutControl.enabled": false,
	"json.schemas": []
}
```

---

## zsh

**Archivo:** `/home/user/.zshrc`

### Contenido

``` bash
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle \':omz:update\' mode disabled  # disable automatic updates
ENABLE_CORRECTION="true"
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	tmux
	vi-mode
)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
if [ -f ~/.aliasrc.zsh ]; then
    source ~/.aliasrc.zsh
fi
source $ZSH/oh-my-zsh.sh
export PATH=$HOME/.brew/bin:$PATH
```

---

## vscode_git

**Archivo:** `/home/user/Documents/GIT/cursus/.vscode/settings.json`

### Contenido

``` bash
{
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
	"workbench.sideBar.location": "right",
	"workbench.colorTheme": "Monokai",
	"workbench.colorCustomizations": {
		"activityBar.background": "#c6d3c1",
		"activityBar.foreground": "#af970c",
		"activityBar.inactiveForeground": "#15581c",
		"sideBar.background": "#105c96",
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
		{ "path": "born2beroot", "symbol": "03", "tooltip": "PROJECT42" },
		{ "path": "minitalk", "symbol": "04", "tooltip": "PROJECT42" },
		{ "path": "fdf", "symbol": "05", "tooltip": "PROJECT42" },
		{ "path": "push_swap", "symbol": "06", "tooltip": "PROJECT42" },
		{ "path": "philosophers", "symbol": "07", "tooltip": "PROJECT42" },
		{ "path": "minishell", "symbol": "08", "tooltip": "PROJECT42" },
		{ "path": "cpp", "symbol": "09", "tooltip": "PROJECT42" },
		{ "path": "netpractice", "symbol": "10", "tooltip": "PROJECT42" },
		{ "path": "cub3d", "symbol": "11", "tooltip": "PROJECT42" },
		{ "path": "inception", "symbol": "13", "tooltip": "PROJECT42" },
		{ "path": "webserv", "symbol": "12", "tooltip": "PROJECT42" },
		{ "path": "ft_transcendence", "symbol": "⭐", "tooltip": "PROJECT42" },
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

## tmux

**Archivo:** `/home/user/.tmux.conf`

### Contenido

``` bash
set -g default-terminal screen-256color
set -g @plugin \'tmux-plugins/tpm\'
set -g @plugin \'tmux-plugins/tmux-sensible\'
set -g @plugin \'tmux-plugins/tmux-yank\'
unbind C-b
set-option -g prefix C-x
bind-key C-x send-prefix
bind | split-window -h
bind - split-window -v
unbind \'"\'
unbind %
bind r source-file ~/.tmux.conf
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
set -g mouse on
set-window-option -g mode-keys vi
set-option -g allow-rename off
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none
setw -g clock-mode-colour gray
setw -g mode-style \'fg=red bg=white\'
set -g pane-border-style \'fg=blue\'
set -g pane-active-border-style \'fg=yellow\'
set -g status-position bottom
set -g status-justify left
set -g status-style \'fg=red\'
set -g status-left \'\'
set -g status-left-length 10
setw -g window-status-current-style \'fg=black bg=red\'
setw -g window-status-current-format \' #I #W #F \'
setw -g window-status-style \'fg=red bg=black\'
setw -g window-status-format \' #I #[fg=white]#W #[fg=yellow]#F \'
setw -g window-status-bell-style \'fg=yellow bg=red bold\'
set -g message-style \'fg=yellow bg=red\'
set -g status-style "fg=#ffffff bg=#1e1e2e"
set -g window-status-current-style "fg=#1e1e2e bg=#89b4fa"
set -g window-status-style "fg=#cdd6f4 bg=#313244"
set -g buffer-limit 20
set -g @yank_with_xclip true
set -g @yank_action \'copy-pipe\'
set -g @yank_selection_mouse \'clipboard\'
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \'xclip -in -selection clipboard\'
run \'~/.tmux/plugins/tpm/tpm\'
```

---

