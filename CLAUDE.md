# CLAUDE.md

Guidance for working in this NixOS dotfiles repository.

## Language convention

- **Conversation** with the user may be in **Japanese**.
- **Everything written into the repository is in English**: documentation,
  code comments, commit messages, PR titles/descriptions, and branch names.

## XMonad workflow

The XMonad config lives in `.xmonad/` and is documented in
`.xmonad/README.md` (a teaching guide meant to grow with the user's
understanding). Two project skills support this:

- **xmonad-grow** — use when adding, changing, or learning an xmonad feature.
  Grows the config one small, understood step at a time, teaching as it goes.
  The user's understanding is the intended bottleneck; do not rush ahead.
- **xmonad-doc-sync** — use after every edit to `.xmonad/xmonad.hs` to keep
  `.xmonad/README.md` (walkthrough tables, concepts, roadmap) accurate.

When you change `.xmonad/xmonad.hs`, always run **xmonad-doc-sync** afterward so
the documentation never drifts from the config.

## Build environment

`flake.nix` provides a Nix dev shell (GHC + `xmonad-contrib`,
`haskell-language-server`, `fourmolu`, `hoogle`, `fast-tags`), loaded
automatically by direnv (`.envrc`) on `cd` into the repo. Format Haskell with
`fourmolu`. Recompile XMonad with `xmonad --recompile`; on failure read
`.xmonad/xmonad.errors`.
