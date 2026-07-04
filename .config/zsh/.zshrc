# Created by newuser for 5.9

# History
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

# Completion
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"

# Prompt
eval "$(starship init zsh)"

# Direnv
eval "$(direnv hook zsh)"

# Abbreviations
source "$ZDOTDIR/abbrev.zsh"

# Utility functions
source "$ZDOTDIR/functions.zsh"

export TERMINAL=kitty
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export LESS='-R'

