repos() {
  local repo
  repo="$(ghq list | fzf)" || return
  cd "$(ghq root)/$repo"
}
