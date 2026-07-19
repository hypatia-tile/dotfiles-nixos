---
name: xmonad-doc-sync
description: Keep .xmonad/README.md in sync with .xmonad/xmonad.hs. Use this whenever xmonad.hs is edited (keybindings, manage rules, layouts, def fields, or roadmap items), or when the user asks to update / check the xmonad documentation.
---

# xmonad-doc-sync

Keep the XMonad guide (`.xmonad/README.md`) faithful to the actual config
(`.xmonad/xmonad.hs`). The README is a teaching document, so it must never
describe behavior that no longer exists or omit behavior that now does.

**Run this skill after every change to `xmonad.hs`.** It is cheap; a stale
teaching doc is expensive because it silently teaches the wrong thing.

## Language

Conversation with the user may be in Japanese, but the README and any code
comments are written in **English**. See `CLAUDE.md`.

## Mapping: config → doc

Each region of `xmonad.hs` maps to a region of `README.md`. When the left
changes, update the right:

| `xmonad.hs`                                   | `README.md` section                    |
|-----------------------------------------------|----------------------------------------|
| `additionalKeysP [ ... ]` list                | §5 "Key bindings" table                |
| `myManageHook` / `composeAll [ ... ]` rules   | §5 "Manage hook"                       |
| `myFloatingRect` value                        | §5 "Floating rectangle"                |
| `layoutHook = ...`                            | §4.3 "Layouts" + §5 `main`             |
| `def { ... }` fields (modMask, terminal, etc.)| §5 `main`                              |
| new import of an `XMonad.*` module            | §4.2 hook table and/or §6 roadmap      |
| a feature completed from the roadmap          | §6 "A growth roadmap" (mark it done)   |

## Procedure

1. Read the current `xmonad.hs` and `README.md`.
2. Diff intent, not text: for each mapped region above, ask "does the doc still
   describe what the code does?"
3. Update the affected README sections. Keep the existing structure, tone, and
   Markdown table formatting.
4. When a roadmap item (§6) is now implemented, mark it done (e.g. prefix with
   `~~...~~ (done)` or move it to a short "Implemented" note) so the roadmap
   keeps reflecting what is left to learn.
5. If a new concept was introduced (a new hook, a new `XMonad.*` module), add a
   short explanation in the relevant §4 subsection — the doc explains *concepts*,
   not just lists settings.
6. Verify no dead references remain (e.g. a keybinding table row for a binding
   that was removed).

## Checklist before finishing

- [ ] Every keybinding in `additionalKeysP` has exactly one table row, and vice
      versa.
- [ ] Every `manage` rule is described, and no described rule is gone.
- [ ] Layout description matches the actual `layoutHook`.
- [ ] Newly used modules/concepts are explained, not just mentioned.
- [ ] Roadmap reflects what is done vs. still to do.
- [ ] All prose is in English.
