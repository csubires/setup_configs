# Documentación de Archivos de Configuración

> Generado automáticamente el Wed Oct 29 08:33:25 PM CET 2025

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

## omzsh

**Archivo:** `/home/user/.p10k.zsh`

### Contenido

``` bash
 
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'
() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    direnv                  # direnv status (https://direnv.net/)
    asdf                    # asdf version manager (https://github.com/asdf-vm/asdf)
    virtualenv              # python virtual environment (https://docs.python.org/3/library/venv.html)
    anaconda                # conda environment (https://conda.io/)
    pyenv                   # python environment (https://github.com/pyenv/pyenv)
    goenv                   # go environment (https://github.com/syndbg/goenv)
    nodenv                  # node.js version from nodenv (https://github.com/nodenv/nodenv)
    nvm                     # node.js version from nvm (https://github.com/nvm-sh/nvm)
    nodeenv                 # node.js environment (https://github.com/ekalinin/nodeenv)
    rbenv                   # ruby version from rbenv (https://github.com/rbenv/rbenv)
    rvm                     # ruby version from rvm (https://rvm.io)
    fvm                     # flutter version management (https://github.com/leoafarias/fvm)
    luaenv                  # lua version from luaenv (https://github.com/cehoffman/luaenv)
    jenv                    # java version from jenv (https://github.com/jenv/jenv)
    plenv                   # perl version from plenv (https://github.com/tokuhirom/plenv)
    perlbrew                # perl version from perlbrew (https://github.com/gugod/App-perlbrew)
    phpenv                  # php version from phpenv (https://github.com/phpenv/phpenv)
    scalaenv                # scala version from scalaenv (https://github.com/scalaenv/scalaenv)
    haskell_stack           # haskell version from stack (https://haskellstack.org/)
    kubecontext             # current kubernetes context (https://kubernetes.io/)
    terraform               # terraform workspace (https://www.terraform.io)
    aws                     # aws profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
    aws_eb_env              # aws elastic beanstalk environment (https://aws.amazon.com/elasticbeanstalk/)
    azure                   # azure account name (https://docs.microsoft.com/en-us/cli/azure)
    gcloud                  # google cloud cli account and project (https://cloud.google.com/)
    google_app_cred         # google application credentials (https://cloud.google.com/docs/authentication/production)
    toolbox                 # toolbox name (https://github.com/containers/toolbox)
    context                 # user@hostname
    nordvpn                 # nordvpn connection status, linux only (https://nordvpn.com/)
    ranger                  # ranger shell (https://github.com/ranger/ranger)
    yazi                    # yazi shell (https://github.com/sxyazi/yazi)
    nnn                     # nnn shell (https://github.com/jarun/nnn)
    lf                      # lf shell (https://github.com/gokcehan/lf)
    xplr                    # xplr shell (https://github.com/sayanarijit/xplr)
    vim_shell               # vim shell indicator (:sh)
    midnight_commander      # midnight commander shell (https://midnight-commander.org/)
    nix_shell               # nix shell (https://nixos.org/nixos/nix-pills/developing-with-nix-shell.html)
    chezmoi_shell           # chezmoi shell (https://www.chezmoi.io/)
    todo                    # todo items (https://github.com/todotxt/todo.txt-cli)
    timewarrior             # timewarrior tracking status (https://timewarrior.net/)
    taskwarrior             # taskwarrior task count (https://taskwarrior.org/)
    per_directory_history   # Oh My Zsh per-directory-history local/global indicator
  )
  typeset -g POWERLEVEL9K_MODE=compatible
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_RULER_CHAR='─'        # reasonable alternative: '·'
  typeset -g POWERLEVEL9K_RULER_FOREGROUND=242
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=242
    typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-versions
    .shorten_folder_marker
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_LOCK_ICON='∅'
  typeset -g POWERLEVEL9K_DIR_CLASSES=()
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    if (( $1 )); then
      local       meta='%f'     # default foreground
      local      clean='%76F'   # green foreground
      local   modified='%178F'  # yellow foreground
      local  untracked='%39F'   # blue foreground
      local conflicted='%196F'  # red foreground
    else
      local       meta='%244F'  # grey foreground
      local      clean='%244F'  # grey foreground
      local   modified='%244F'  # grey foreground
      local  untracked='%244F'  # grey foreground
      local conflicted='%244F'  # grey foreground
    fi
    local res
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"  # <-- this line
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi
    if [[ -n $VCS_STATUS_TAG
          && -z $VCS_STATUS_LOCAL_BRANCH  # <-- this line
        ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"  # <-- this line
      res+="${meta}#${clean}${tag//\%/%%}"
    fi
    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&  # <-- this line
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi
    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi
    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    elif [[ -n $VCS_STATUS_REMOTE_BRANCH ]]; then
    fi
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=76
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=244
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='х'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='х'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='х'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='≡'
  typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=178
  typeset -g POWERLEVEL9K_ASDF_FOREGROUND=66
  typeset -g POWERLEVEL9K_ASDF_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_ASDF_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_ASDF_SHOW_ON_UPGLOB=
  typeset -g POWERLEVEL9K_ASDF_RUBY_FOREGROUND=168
  typeset -g POWERLEVEL9K_ASDF_PYTHON_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_GOLANG_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_NODEJS_FOREGROUND=70
  typeset -g POWERLEVEL9K_ASDF_RUST_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_FOREGROUND=134
  typeset -g POWERLEVEL9K_ASDF_FLUTTER_FOREGROUND=38
  typeset -g POWERLEVEL9K_ASDF_LUA_FOREGROUND=32
  typeset -g POWERLEVEL9K_ASDF_JAVA_FOREGROUND=32
  typeset -g POWERLEVEL9K_ASDF_PERL_FOREGROUND=67
  typeset -g POWERLEVEL9K_ASDF_ERLANG_FOREGROUND=125
  typeset -g POWERLEVEL9K_ASDF_ELIXIR_FOREGROUND=129
  typeset -g POWERLEVEL9K_ASDF_POSTGRES_FOREGROUND=31
  typeset -g POWERLEVEL9K_ASDF_PHP_FOREGROUND=99
  typeset -g POWERLEVEL9K_ASDF_HASKELL_FOREGROUND=172
  typeset -g POWERLEVEL9K_ASDF_JULIA_FOREGROUND=70
  typeset -g POWERLEVEL9K_NORDVPN_FOREGROUND=39
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_NORDVPN_VISUAL_IDENTIFIER_EXPANSION='nord'
  typeset -g POWERLEVEL9K_RANGER_FOREGROUND=178
  typeset -g POWERLEVEL9K_RANGER_VISUAL_IDENTIFIER_EXPANSION='▲'
  typeset -g POWERLEVEL9K_YAZI_FOREGROUND=178
  typeset -g POWERLEVEL9K_YAZI_VISUAL_IDENTIFIER_EXPANSION='▲'
  typeset -g POWERLEVEL9K_NNN_FOREGROUND=72
  typeset -g POWERLEVEL9K_LF_FOREGROUND=72
  typeset -g POWERLEVEL9K_XPLR_FOREGROUND=72
  typeset -g POWERLEVEL9K_VIM_SHELL_FOREGROUND=34
  typeset -g POWERLEVEL9K_MIDNIGHT_COMMANDER_FOREGROUND=178
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=74
  typeset -g POWERLEVEL9K_CHEZMOI_SHELL_FOREGROUND=33
  typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=35
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=220
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=160
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
  typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=66
  typeset -g POWERLEVEL9K_SWAP_FOREGROUND=96
  typeset -g POWERLEVEL9K_LOAD_WHICH=5
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=66
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=178
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=166
  typeset -g POWERLEVEL9K_TODO_FOREGROUND=110
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL=true
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED=false
  typeset -g POWERLEVEL9K_TIMEWARRIOR_FOREGROUND=110
  typeset -g POWERLEVEL9K_TIMEWARRIOR_CONTENT_EXPANSION='${P9K_CONTENT:0:24}${${P9K_CONTENT:24}:+…}'
  typeset -g POWERLEVEL9K_TASKWARRIOR_FOREGROUND=74
  typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_LOCAL_FOREGROUND=135
  typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_GLOBAL_FOREGROUND=130
  typeset -g POWERLEVEL9K_CPU_ARCH_FOREGROUND=172
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=178
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=37
  typeset -g POWERLEVEL9K_ANACONDA_CONTENT_EXPANSION='${${${${CONDA_PROMPT_MODIFIER#\(}% }%\)}:-${CONDA_PREFIX:t}}'
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='${P9K_CONTENT}${${P9K_CONTENT:#$P9K_PYENV_PYTHON_VERSION(|/*)}:+ $P9K_PYENV_PYTHON_VERSION}'
  typeset -g POWERLEVEL9K_GOENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_GOENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_GOENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_NODENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_NODENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_NVM_FOREGROUND=70
  typeset -g POWERLEVEL9K_NVM_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_NVM_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION=false
  typeset -g POWERLEVEL9K_NODEENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_DOTNET_VERSION_FOREGROUND=134
  typeset -g POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PHP_VERSION_FOREGROUND=99
  typeset -g POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_LARAVEL_VERSION_FOREGROUND=161
  typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=32
  typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_JAVA_VERSION_FULL=false
  typeset -g POWERLEVEL9K_PACKAGE_FOREGROUND=117
  typeset -g POWERLEVEL9K_RBENV_FOREGROUND=168
  typeset -g POWERLEVEL9K_RBENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_RBENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_RVM_FOREGROUND=168
  typeset -g POWERLEVEL9K_RVM_SHOW_GEMSET=false
  typeset -g POWERLEVEL9K_RVM_SHOW_PREFIX=false
  typeset -g POWERLEVEL9K_FVM_FOREGROUND=38
  typeset -g POWERLEVEL9K_LUAENV_FOREGROUND=32
  typeset -g POWERLEVEL9K_LUAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_LUAENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_JENV_FOREGROUND=32
  typeset -g POWERLEVEL9K_JENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_JENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PLENV_FOREGROUND=67
  typeset -g POWERLEVEL9K_PLENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PLENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PERLBREW_FOREGROUND=67
  typeset -g POWERLEVEL9K_PERLBREW_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PERLBREW_SHOW_PREFIX=false
  typeset -g POWERLEVEL9K_PHPENV_FOREGROUND=99
  typeset -g POWERLEVEL9K_PHPENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PHPENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_SCALAENV_FOREGROUND=160
  typeset -g POWERLEVEL9K_SCALAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_SCALAENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_HASKELL_STACK_FOREGROUND=172
  typeset -g POWERLEVEL9K_HASKELL_STACK_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_HASKELL_STACK_ALWAYS_SHOW=true
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent|kubecolor|cmctl|sparkctl'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=134
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION='○'
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
      '*'         OTHER)
  typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND=38
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_FOREGROUND=38
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AWS_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=208
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'
  typeset -g POWERLEVEL9K_AWS_EB_ENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_AWS_EB_ENV_VISUAL_IDENTIFIER_EXPANSION='eb'
  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AZURE_CLASSES=(
      '*'         OTHER)
  typeset -g POWERLEVEL9K_AZURE_OTHER_FOREGROUND=32
  typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gcs|gsutil'
  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=32
  typeset -g POWERLEVEL9K_GCLOUD_PARTIAL_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_COMPLETE_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_NAME//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_REFRESH_PROJECT_NAME_SECONDS=60
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_SHOW_ON_COMMAND='terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES=(
      '*'             DEFAULT)
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_FOREGROUND=32
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_CONTENT_EXPANSION='${P9K_GOOGLE_APP_CRED_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_TOOLBOX_FOREGROUND=178
  typeset -g POWERLEVEL9K_TOOLBOX_CONTENT_EXPANSION='${P9K_TOOLBOX_NAME:#fedora-toolbox-*}'
  typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND=94
  typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=81
  typeset -g POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'
  typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false
  typeset -g POWERLEVEL9K_IP_FOREGROUND=38
  typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='$P9K_IP_IP${P9K_IP_RX_RATE:+ %70F⇣$P9K_IP_RX_RATE}${P9K_IP_TX_RATE:+ %215F⇡$P9K_IP_TX_RATE}'
  typeset -g POWERLEVEL9K_IP_INTERFACE='[ew].*'
  typeset -g POWERLEVEL9K_PROXY_FOREGROUND=68
  typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
  typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=160
  typeset -g POWERLEVEL9K_BATTERY_{CHARGING,CHARGED}_FOREGROUND=70
  typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=178
  typeset -g POWERLEVEL9K_BATTERY_STAGES=('%K{232}▁' '%K{232}▂' '%K{232}▃' '%K{232}▄' '%K{232}▅' '%K{232}▆' '%K{232}▇' '%K{232}█')
  typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false
  typeset -g POWERLEVEL9K_WIFI_FOREGROUND=68
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
  function prompt_example() {
    p10k segment -f 208 -i '⭐' -t 'hello, %n'
  }
  function instant_prompt_example() {
    prompt_example
  }
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
 
```

---

## kitty

**Archivo:** `/home/user/.config/kitty/kitty.conf`

### Contenido

``` bash
 
shell /bin/zsh
editor vim
include Broadcast.conf
font_family FiraCode Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 12.0
cursor_shape block
cursor_blink_interval 0
scrollback_lines 10000
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
scrollback_pager_history_size 100
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
tab_title_template "{index} {title.split(':',1)[-1]}"
tab_bar_min_tabs 1
active_tab_title_template "{title[title.rfind('/')+1:]}"
repaint_delay 10
input_delay 1
sync_to_monitor yes
disable_ligatures never
copy_on_select yes
strip_trailing_spaces smart
detect_urls yes
url_style double
open_url_with default
map ctrl+shift+c send_text all \x03
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
map alt+left neighboring_window left
map alt+right neighboring_window right
map alt+up neighboring_window up
map alt+down neighboring_window down
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
map ctrl+shift+left previous_tab
map ctrl+shift+right next_tab
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
map ctrl+space next_layout
hide_window_decorations yes
mouse_hide_wait 3.0
url_color #e4325e
url_style curly
text_composition_strategy 1.0 1
select_by_word_characters @-./_~?&=%+#
adjust_line_height 0
adjust_column_width 0
adjust_baseline 0
cursor #e42626
cursor_text_color #000000
cursor_blink_interval -1
mouse_map left click ungrabbed mouse_handle_click selection link prompt
mouse_map left doublepress ungrabbed mouse_handle_click selection word
mouse_map left triplepress ungrabbed mouse_handle_click selection line
tab_powerline_style slanted
tab_bar_align center
active_tab_foreground #d3cba8
active_tab_background #b3224e
inactive_tab_foreground #9caa9d
inactive_tab_background #707a7a
active_border_color #e75816
inactive_border_color #5bd13e
allow_remote_control yes
map f1 copy_to_buffer a
map f2 paste_from_buffer a
debug_config no
debug_font_fallback no
 
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
alias cdtmp="cd /tmp"
alias cdocs="cd ~/Documents"
alias ls="ls --color=auto"
alias ll="ls -alF"
alias la="ls --color=auto -la"
alias lc="ls -d */ | xargs realpath"
alias grep="grep --color=auto"
alias latr="ls --color=auto -latr"
alias rezsh="source ~/.zshrc"
alias vi="vim"
alias rczsh="vim ~/.zshrc"
alias rcali="vim ~/.aliasrc.zsh"
alias rcmux="vim ~/.tmux.conf"
alias rcvim="vim ~/.vimrc"
alias rckit="vim ~/.config/kitty/kitty.conf"
alias rcnft="sudo vim /etc/nftables.conf"
alias mnet="ss -tupan"
alias mcat="batcat"
alias mcnx="lsof -i"
alias mfop="lsof -u \$USER"
alias msess="tmux new -A -s my_session"
alias mgrep="grep -rniI --color=auto"
alias mfind="find . -iname"
alias mpass="openssl rand -base64"
alias mkpwd="openssl rand -base64 32"
alias mserv="systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | head -n 20"
alias mmemo="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%mem 2>/dev/null | head -n 15"
alias mcpup="ps -u \$USER -o pid,ppid,%cpu,%mem,cmd --sort=-%cpu 2>/dev/null | head -n 15"
alias mtree="tree -C"
alias rmtr="trash-put"
alias blame="systemd-analyze blame"
alias docker="podman"
alias docker-compose="podman-compose"
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
gbla() {
    local extension="$1"
    if [[ -z "$extension" ]]; then
        echo "Use: gbla <extension>"
        return 1
    fi
    find . -name "*.$extension" -exec sh -c 'echo "{}:"; git blame "{}" 2>/dev/null | cut -d" " -f2 | sort | uniq -c | sort -nr' \;
}
alias todep="/home/user/Documents/Scripts/todep/todep.sh"
alias syslog="/home/user/Documents/Scripts/syslog.sh"
alias formatcpp="/home/user/Documents/Scripts/format_cpp.sh"
alias formatpython="/home/user/Documents/Scripts/format_py.sh"
alias runkitty="/home/user/Documents/Scripts/run_kitty.sh"
myip() { echo "Public IP: $(curl --max-time 3 --silent ipinfo.io/ip 2>/dev/null || echo 'Unable to fetch')" }
texto() { echo "$*" | xclip -selection clipboard }
meval() { eval "$(ssh-agent -s)" && ssh-add ~/.ssh/darkc_git_ed25519 && ssh-add -l }
msize() { du -hc . 2>/dev/null | tail -n 1 }
cdmk() { mkdir -p "$1" && cd "$1" }
cdmktmp() { local dir; dir=$(mktemp -d) && cd "$dir" }
msto() { sudo systemctl restart "$1" }
mres() { sudo systemctl stop "$1" }
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
alias francinette="/home/user/francinette/tester.sh"
alias paco="/home/user/francinette/tester.sh"
alias cursus="cd ~/Documents/GIT/cursus"
alias help42="cd ~/Documents/GIT/help"
alias cdgit="cd ~/Documents/GIT"
alias cdbox="cd ~/Documents/box"
alias cdscr="cd ~/Documents/Scripts"
alias cdpro="cd ~/Documents/Projects"
alias cdrep="cd ~/Documents/Repository"
alias cdsha="cd /mnt/hgfs"
 
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
}
 
```

---

## kittytheme

**Archivo:** `/home/user/.config/kitty/Broadcast.conf`

### Contenido

``` bash
 
background            #2b2b2b
foreground            #e5e1db
cursor                #ffffff
selection_background  #5a637e
color0                #000000
color8                #685159
color1                #da4839
color9                #ff7b6a
color2                #509f50
color10               #83d082
color3                #ffd249
color11               #ffff7b
color4                #6d9cbd
color12               #9fcef0
color5                #cfcfff
color13               #ffffff
color6                #6d9cbd
color14               #a0cef0
color7                #ffffff
color15               #ffffff
selection_foreground #2b2b2b
 
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
	"editor.hover.enabled": false,
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
 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode disabled  # disable automatic updates
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
	"telemetry.telemetryLevel": "off",
	"redhat.telemetry.enabled": false,
	"update.showReleaseNotes": false,
	"workbench.enableExperiments": false,
	"workbench.settings.enableNaturalLanguageSearch": false,
	"editor.parameterHints.enabled": false,
	"editor.hover.enabled": false,
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
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
unbind C-b
set-option -g prefix C-x
bind-key C-x send-prefix
bind | split-window -h
bind - split-window -v
unbind '"'
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
setw -g mode-style 'fg=red bg=white'
set -g pane-border-style 'fg=blue'
set -g pane-active-border-style 'fg=yellow'
set -g status-position bottom
set -g status-justify left
set -g status-style 'fg=red'
set -g status-left ''
set -g status-left-length 10
setw -g window-status-current-style 'fg=black bg=red'
setw -g window-status-current-format ' #I #W #F '
setw -g window-status-style 'fg=red bg=black'
setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '
setw -g window-status-bell-style 'fg=yellow bg=red bold'
set -g message-style 'fg=yellow bg=red'
set -g status-style "fg=#ffffff bg=#1e1e2e"
set -g window-status-current-style "fg=#1e1e2e bg=#89b4fa"
set -g window-status-style "fg=#cdd6f4 bg=#313244"
set -g buffer-limit 20
set -g @yank_with_xclip true
set -g @yank_action 'copy-pipe'
set -g @yank_selection_mouse 'clipboard'
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
run '~/.tmux/plugins/tpm/tpm'
 
```

---


> sudo apt install vim nano zsh tmux git curl wget tree bat xclip podman podman-compose trash-cli openssl fd-find fzf
> sudo apt install zsh-autosuggestions zsh-syntax-highlighting
> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
> source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
> git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
> echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
> p10k configure
