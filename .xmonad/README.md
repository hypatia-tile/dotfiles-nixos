# XMonad Configuration Guide

This document explains the XMonad configuration in `xmonad.hs` from first
principles. It is written to grow together with your understanding: read a
section, change one thing, recompile, and observe. The config is intentionally
small so that every line can be understood before the next is added.

## Table of contents

1. [What XMonad is](#1-what-xmonad-is)
2. [The configuration model](#2-the-configuration-model)
3. [The build environment (Nix)](#3-the-build-environment-nix)
4. [Core architecture](#4-core-architecture)
   - [`main` and `def`](#41-main-and-def)
   - [The hook pipeline](#42-the-hook-pipeline)
   - [Layouts](#43-layouts)
   - [`StackSet`: the window model](#44-stackset-the-window-model)
5. [Walkthrough of the current config](#5-walkthrough-of-the-current-config)
6. [A growth roadmap](#6-a-growth-roadmap)
7. [Reference links](#7-reference-links)

---

## 1. What XMonad is

XMonad is a **tiling window manager** written and configured in Haskell.
"Tiling" means windows are automatically arranged to fill the screen without
overlapping, instead of being freely dragged and stacked like on a typical
desktop. "Configured in Haskell" means your configuration file, `xmonad.hs`, is
a real Haskell program: it is compiled into the window manager itself.

The practical consequences:

- Your config is type-checked. A mistake is often a compile error, not a
  silent runtime surprise.
- You have the full language available. Helper functions, lists, and
  abstractions are all normal Haskell.
- To learn the config, you are also (a little) learning Haskell. That is the
  intended bottleneck — take it slowly.

## 2. The configuration model

XMonad does **not** read a settings file at runtime. Instead:

1. You edit `~/.xmonad/xmonad.hs`.
2. `xmonad --recompile` compiles it into an executable
   (`xmonad-x86_64-linux` in this directory).
3. `xmonad --restart` swaps the running window manager for the new binary,
   **keeping your windows in place**.

In this config both steps are bound to a single key (see `M-S-r` below). If
compilation fails, the error is written to `xmonad.errors` and the old binary
keeps running — you are never left without a window manager.

> **Tip:** After any change, recompile and read `xmonad.errors` if nothing
> seems to happen. A green (silent) recompile means success.

## 3. The build environment (Nix)

This repository uses Nix to provide the exact GHC (Haskell compiler) and
libraries XMonad needs, so the config is reproducible.

- `flake.nix` defines a dev shell containing GHC with the `xmonad` and
  `xmonad-contrib` packages, plus tooling: `haskell-language-server` (IDE
  features), `fourmolu` (formatter), `hoogle` (type search), and `fast-tags`.
- `.envrc` contains `use flake`, so [direnv](https://direnv.net/) loads this
  shell automatically when you `cd` into the directory.

Practically, to hack on the config with editor support:

```sh
cd ~/.xmonad        # direnv activates the flake shell
haskell-language-server-wrapper   # or just open your editor
```

`hoogle` is especially useful while learning: you can search for a type or
function name to find what is available in `xmonad-contrib`.

## 4. Core architecture

Everything in `xmonad.hs` is customizing four things: the base config record,
the hook pipeline, the layouts, and the key bindings. Understanding these four
concepts is enough to read and extend almost any XMonad config.

### 4.1 `main` and `def`

```haskell
main :: IO ()
main = xmonad $ def { ... } `additionalKeysP` [ ... ]
```

- `def` is the **default configuration record** — a big bundle of settings with
  sensible defaults.
- The `{ field = value, ... }` syntax is Haskell **record update**: it copies
  `def` and overrides only the named fields. Everything you do not mention keeps
  its default.
- `xmonad` takes that final config and runs the window manager.
- Because it is just a record, extending the config = adding another
  `field = value` line, or wrapping a field's value with a helper.

### 4.2 The hook pipeline

A **hook** is a function XMonad calls at a particular moment. The main ones:

| Field         | When it runs                    | Typical use                         |
|---------------|---------------------------------|-------------------------------------|
| `manageHook`  | when a new window appears       | float dialogs, send apps to workspaces |
| `layoutHook`  | when the screen needs arranging | choose/compose layouts              |
| `logHook`     | after any state change          | feed a status bar                   |
| `handleEventHook` | on X11 events               | react to fullscreen, docks, etc.    |
| `startupHook` | once, when XMonad starts        | launch background programs          |

Hooks compose. `manageHook` is a `ManageHook`, and several rules are combined
with `composeAll [...]`. Two configs are combined with `<+>` (a monoid append):

```haskell
manageHook = myManageHook <+> manageHook def
```

This says "apply my rules, then also apply the default rules." This pattern —
*your customization `<+>` the default* — recurs throughout XMonad and is the key
to extending without discarding built-in behavior.

### 4.3 Layouts

A **layout** decides how the visible windows are positioned. The `layoutHook`
holds one or more layouts combined with `|||` ("or"), and `M-<Space>` (a default
binding) cycles between them.

```haskell
layoutHook = ResizableTall 1 (3/100) (1/2) []
         ||| Mirror (ResizableTall 1 (3/100) (1/2) [])
```

`ResizableTall n delta ratio slaves` is a master/stack layout:

- `n` = number of windows in the master area (`1`).
- `delta` = fraction to grow/shrink on resize (`3/100` = 3%).
- `ratio` = fraction of the screen the master area occupies (`1/2`).
- `slaves` = per-window size overrides (`[]` = none).

`Mirror` rotates a layout 90°, turning the vertical master/stack split into a
horizontal (top/bottom) one. Layouts respond to **messages** (see `M-a`/`M-z`
below), which is how resizing works.

### 4.4 `StackSet`: the window model

`XMonad.StackSet` (imported as `W`) is the pure data structure describing all
workspaces, screens, and the focused window. You rarely build one by hand, but
several operations reference it:

- `W.RationalRect x y w h` — a rectangle in **screen fractions** (0.0–1.0),
  used to place floating windows.
- `W.float w rect` — make window `w` float at `rect`.
- `W.sink w` — return a floating window to the tiled layout.

`windows :: (WindowSet -> WindowSet) -> X ()` applies such a pure transformation
to the live state. That is why the float/sink key bindings look like
`windows $ W.sink w`.

## 5. Walkthrough of the current config

### Floating rectangle

```haskell
myFloatingRect :: W.RationalRect
myFloatingRect = W.RationalRect 0.08 0.08 0.84 0.84
```

A named rectangle: start 8% from the left/top, span 84% of the width/height —
i.e. a centered window with an 8% margin all around. Named once, reused by the
manage rules below.

### Manage hook

```haskell
myManageHook =
  composeAll
    [ isDialog                          --> doFloat
    , className =? "float-kitty" --> doRectFloat myFloatingRect
    , className =? "float-nvim"  --> doRectFloat myFloatingRect
    ]
```

Each rule is `query --> action`:

- `isDialog --> doFloat` — any window that identifies as a dialog floats at its
  requested size.
- `className =? "float-kitty" --> doRectFloat myFloatingRect` — windows whose X11
  class is `float-kitty` float at our centered rectangle. This is why the key
  bindings launch terminals with `--class float-kitty`: the class is a label the
  manage hook matches on.

To discover a window's class for a new rule, run `xprop` and click the window;
read the `WM_CLASS` field.

### `main`

```haskell
def
  { modMask     = mod4Mask          -- Super/Windows key is the prefix
  , terminal    = "kitty"
  , borderWidth = 2
  , manageHook  = myManageHook <+> manageHook def
  , layoutHook  = ResizableTall ... ||| Mirror (ResizableTall ...)
  }
```

`modMask = mod4Mask` sets the **mod key** to Super (the Windows key). In key
notation, `M-` means this key. Choosing Super avoids clashing with application
shortcuts that use Alt.

### Key bindings

Bound with `additionalKeysP` (the "P" = *pretty* Emacs-style strings, provided
by `XMonad.Util.EZConfig`). `M-` = mod (Super), `S-` = Shift, `C-` = Control.

| Binding        | Action                                                        |
|----------------|---------------------------------------------------------------|
| `M-<Return>`   | launch `kitty`                                                |
| `M-S-<Return>` | launch a floating `kitty` (class `float-kitty`)               |
| `M-n`          | launch a floating `nvim` in kitty                             |
| `M-p`          | `dmenu_run` (application launcher)                            |
| `M-S-r`        | recompile **and** restart XMonad                              |
| `M-S-q`        | quit XMonad (`exitSuccess`)                                   |
| `M-f`          | float the focused window at a 60% centered rectangle          |
| `M-t`          | sink the focused window back into tiling                      |
| `M-a`          | `MirrorExpand` — grow the master area (works in Mirror layout)|
| `M-z`          | `MirrorShrink` — shrink it                                    |

These are *additional* to XMonad's defaults, which you still have — e.g.
`M-S-c` (close window), `M-j`/`M-k` (focus next/previous), `M-<Space>` (cycle
layout), `M-1`..`M-9` (switch workspace), `M-S-1`..`M-S-9` (move window to
workspace). `M-a`/`M-z` send *messages* to the current layout, which is why they
resize.

## 6. A growth roadmap

Suggested order for extending the config, easiest and most rewarding first.
Add **one** item, recompile, live with it for a while, then continue.

1. **A status bar.** Add `xmobar` via `XMonad.Hooks.DynamicLog` and a `logHook`
   so you can see workspaces, layout, and window title. This teaches the
   `logHook` and `handleEventHook`/docks concepts.
2. **Named workspaces.** Set `workspaces = ["web","dev","chat",...]` and let the
   manage hook send specific apps to specific workspaces with `doShift`.
3. **Gaps / spacing.** `XMonad.Layout.Spacing` adds gaps between windows.
   A small, visual change that makes the layout section concrete.
4. **A scratchpad.** `XMonad.Util.NamedScratchpad` turns your floating terminal
   idea into a proper toggleable drop-down. This builds directly on the
   `float-kitty` pattern you already have.
5. **More layouts.** Add `Full`, `ThreeColMid`, or `Grid` to the `|||` chain and
   cycle with `M-<Space>`.
6. **`startupHook`.** Launch a wallpaper setter, compositor, etc. at startup.

For each step: find the module on Hackage, read its short example, and copy the
smallest working piece. Use `hoogle` (from the dev shell) to check types.

## 7. Reference links

- XMonad site & tour: <https://xmonad.org/>
- `xmonad-contrib` (all the `XMonad.*` modules) on Hackage:
  <https://hackage.haskell.org/package/xmonad-contrib>
- Config archive / examples:
  <https://wiki.haskell.org/Xmonad/Config_archive>
- `EZConfig` key-string syntax:
  <https://hackage.haskell.org/package/xmonad-contrib/docs/XMonad-Util-EZConfig.html>
- `StackSet` API:
  <https://hackage.haskell.org/package/xmonad/docs/XMonad-StackSet.html>
