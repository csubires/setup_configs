# ============================================
# OPTIMIZED .zshrc with Starship
# Fast, modern, and actively maintained
# ============================================

# ============================================
# History Configuration
# ============================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Better history handling
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# ============================================
# ZSH Options
# ============================================
# Disable correction (can be annoying)
unsetopt correct_all

# Better glob matching
setopt NO_NOMATCH

# Disable auto title
DISABLE_AUTO_TITLE="true"

# ============================================
# Completion System (minimal)
# ============================================
autoload -Uz compinit

# Only regenerate compdump once a day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ============================================
# Plugins (minimal for speed)
# ============================================
# Path to oh-my-zsh plugins (if you want to keep them)
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# zsh-autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

fi

# zsh-syntax-highlighting
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi


# ============================================
# PATH
# ============================================
export PATH=$HOME/.brew/bin:$PATH
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/.local/bin:$PATH"

# ============================================
# NVM Lazy Loading (only loads when needed)
# ============================================
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    
    # Lazy load functions - nvm only initializes when you call it
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

# ============================================
# Aliases
# ============================================
if [ -f ~/.aliasrc.zsh ]; then
    source ~/.aliasrc.zsh
fi

# ============================================
# Optional: Vi mode
# ============================================
# Uncomment if you use vi mode
# bindkey -v

# ============================
# Key handling (robust)
# ============================

bindkey -e

export KEYTIMEOUT=20

# Backspace compatibility
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Ctrl + arrows
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Ctrl + Backspace
#bindkey '^[[3;5~' kill-word
bindkey '^[^?' backward-kill-word

# ============================================
# Starship Prompt (super fast!)
# ============================================
eval "$(starship init zsh)"

