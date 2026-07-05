repos() {
  local repo
  repo="$(ghq list | fzf)" || return
  cd "$(ghq root)/$repo"
}

create_repo_mit() {
  local repo_name="hypatia-tile/$1"
  gh repo create "${repo_name}" --add-readme --license=MIT --private \
    && ghq get -p "${repo_name}"
}

