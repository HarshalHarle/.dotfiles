# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load zsh plugins with turbo mode and compinit
zinit ice wait'0' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0' lucid
zinit light Aloxaf/fzf-tab

zinit ice wait'0' lucid atload"zicompinit; zicdreplay"
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting

# Add in snippets with turbo mode
zinit ice wait'0' lucid
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Ignore specific compdefs if needed
zi cdclear -q  # <- Forget completions provided by previous plugins

# Load completions
autoload -Uz compinit
compinit

# Replay compdefs provided by other plugins
zi cdreplay -q  # <- Execute compdefs provided by rest of plugins

#                   ---- fzf setup ----
# --- setup fzf theme ---
fg="#CDD6F4"
bg="#1E1E2E"
bg_highlight="#313244"
purple="#CBA6F7"
blue="#89B4FA"
cyan="#94E2D5"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}
source ~/bin/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

#        ---- fzf setup end ----

#                Aliases

alias sudo='sudo '
alias n='nvim'
alias code='code-insiders'
alias zed='zed-editor'
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'

# Listing and Viewing
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'

# File and Directory Operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias rmdir='rmdir --ignore-fail-on-non-empty'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'

# Process Management
alias psf='ps aux | grep'
alias psg='ps aux | grep -v grep | grep'

# Networking
alias myip='curl ifconfig.me'
alias openports='sudo lsof -i -P -n | grep LISTEN'

# Git
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias pull='git pull'
alias gs='git status'
alias gl='git log --oneline --decorate --all --graph'
alias gd='git diff'
alias gdc='git diff --cached'

# Docker
alias dockerps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Miscellaneous
alias cls='clear'
alias c='clear'
alias h='history'
alias reload='source ~/.zshrc'

# History file configuration
HISTFILE=~/.zsh_history       # Define the history file location
SAVEHIST=5000                # Maximum number of events in the history file
HISTSIZE=4999                # Maximum number of events in memory

# History options
setopt hist_ignore_space      # Ignore commands that start with a space
setopt hist_ignore_dups       # Ignore duplicate commands
setopt hist_find_no_dups      # Do not display duplicates during search
setopt share_history          # Share history among all sessions
setopt append_history         # Append new commands to the history file
setopt inc_append_history     # Incrementally append new commands to the history file
setopt extended_history       # Save timestamp and duration with each entry
setopt hist_verify            # Verify history expansions before executing
setopt hist_reduce_blanks     # Remove superfluous blanks before recording entry
setopt hist_expire_dups_first # Expire duplicate entries first when trimming the history

# History control patterns
histignore='ls:cd:cd -:pwd:exit:date:* --help'  # Ignore specific patterns
histignore='*sudo*'  # Ignore all sudo commands

# Aliases and key bindings for convenience
bindkey '^h' history-incremental-search-backward  # Ctrl+h to search history

# Keybindings
bindkey -e # emacs keybindings
bindkey '^[w' kill-region
bindkey '^p' up-line-or-beginning-search  # Ctrl+P to search up
bindkey '^n' down-line-or-beginning-search  # Ctrl+N to search down

# Custom history search functions (if desired)
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Paths
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"
export BAT_THEME="Catppuccin Mocha"
# Hyprland
#export WLR_NO_HARDWARE_CURSORS=1
#export __GLX_VENDOR_LIBRARY_NAME=nvidia
#export GBM_BACKEND=nvidia-drm

# Shell integrations
eval "$(fzf --zsh)"
eval $(thefuck --alias fk)
eval "$(zoxide init --cmd cd zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/ohmyposh.toml)"
