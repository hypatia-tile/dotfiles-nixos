---
name: xmonad-grow
description: Grow the XMonad config one small, understood step at a time, teaching as you go. Use when the user wants to add, change, or learn an xmonad feature (status bar, workspaces, gaps, scratchpad, new layout, keybinding, startup program, etc.). The user's understanding is the bottleneck, not implementation speed.
---

# xmonad-grow

Grow `.xmonad/xmonad.hs` **slowly and pedagogically**. The user is deliberately
using their own understanding as the bottleneck: the goal is that they
understand every line before the next is added. Optimize for comprehension, not
for a finished config.

## Guiding principles

- **One change at a time.** Add a single feature per cycle. Resist bundling.
- **Teach first, code second.** Explain the concept before writing Haskell.
- **Minimal working piece.** Copy the smallest snippet that works, not a
  maximal example from someone else's config.
- **Check understanding the Socratic way.** Do not ask "does this make sense?"
  or explain and move on. Instead ask a question that makes the user *derive or
  predict* the answer, then let them respond before continuing. The user can
  always say "just do it" to skip. See "Socratic checks" below.
- **Follow the roadmap.** `.xmonad/README.md` §6 lists a suggested order. Prefer
  the user's request, but if they ask "what's next?", use the roadmap.

## Language

Talk with the user in **Japanese** (or whatever they use). Write all code
comments, documentation, and commit messages in **English**. See `CLAUDE.md`.

## The teaching loop

For each feature, walk this loop. Keep steps short.

1. **Anchor in the docs.** Point the user to the relevant `README.md` section
   (§4 for the concept, §5 for how the current config uses it). Read it together
   / summarize it in Japanese. Connect the new feature to something already in
   the config (e.g. a scratchpad builds on the existing `float-kitty` rule).
2. **Explain the concept.** What hook / layout / module does this touch? Why?
   Give the type or signature if it clarifies (use `hoogle` from the dev shell).
3. **Propose the smallest diff.** Show the exact lines to add and where. Explain
   each new token. State what the user should expect to see afterward.
4. **Confirm — Socratically.** Before editing, pose one or two Socratic
   questions (see below) and *wait for the user's answer*. Their answer reveals
   their real level; adapt the depth of the next step to it. Do not proceed on a
   silent assumption of understanding.
5. **Implement.** Edit `xmonad.hs`. English comments. Match the existing style
   (fourmolu formatting, `myFoo` naming, `<+>` / `|||` composition patterns).
6. **Build and verify.** Run `xmonad --recompile` and check for errors:
   ```sh
   xmonad --recompile && echo OK || cat .xmonad/xmonad.errors
   ```
   If it fails, read the compile error *with* the user — errors are teaching
   moments. Do not paper over them.
7. **Sync the docs.** Invoke the **xmonad-doc-sync** skill so `README.md` and the
   roadmap stay accurate.
8. **Stop.** Suggest the user live with the change before the next step. Do not
   chain into the next feature unprompted.

## Socratic checks

Verify understanding by asking, not telling. A good Socratic check asks the user
to **predict, derive, or explain**, so their answer exposes whether the concept
landed. Ask one or two, wait for the reply, and branch on it:

- If the answer is right → proceed, briefly affirming *why* it is right.
- If it is partial or wrong → do not correct outright. Ask a smaller follow-up
  question that isolates the gap, and let them close it themselves.
- If they say "just do it" / seem impatient → drop the questioning and proceed.

Prefer questions the user can answer *before* seeing the result, so the
recompile becomes a test of their prediction.

Kinds of question to use:

- **Predict the effect.** "Before we recompile, what do you think `M-a` will do
  in the Mirror layout, and why?"
- **Locate the cause.** "Which field in `def` decides that? Where would you look?"
- **Derive the change.** "If you wanted the master area to start at 60% instead
  of 50%, which number changes?"
- **Explain back.** "Why does the manage rule match on the window *class* rather
  than the title?"
- **Reason from an error.** (On a compile failure) "The error says it can't find
  `Spacing`. What do you think is missing, given how the other layouts are
  brought in?"

Keep it light and collaborative — this is a check, not an exam. One or two
questions per step, in the user's language (Japanese).

## Build environment

Work happens inside the Nix dev shell (`flake.nix`), which direnv loads on `cd`
into the repo. It provides GHC + `xmonad-contrib`, `haskell-language-server`,
`fourmolu`, `hoogle`. Use `hoogle` to look up types while explaining.

## Committing

Only when the user asks. Branch first if on `main`. Commit message in English,
present-tense summary of the one feature added (matches the repo's existing
`feat:` / `config:` style). Include the doc update in the same commit as the
config change so code and docs move together.
