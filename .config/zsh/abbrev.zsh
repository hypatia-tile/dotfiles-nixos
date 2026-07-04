typeset -A ABBR

ABBR=(
  gs 'git status'
  ga 'git add'
  gc 'git commit'
  gd 'git diff'
  gds 'git diff --staged'
  gp 'git push'
  gl 'git log --oneline --graph --decorate'
)

expand-abbr() {
  local word="${LBUFFER##* }"

  if [[ -n "${ABBR[$word]}" ]]; then
    LBUFFER="${LBUFFER%$word}${ABBR[$word]}"
  fi

  zle self-insert
}

zle -N expand-abbr
bindkey ' ' expand-abbr

