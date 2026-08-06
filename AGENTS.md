# AGENTS.md

Guidance for AI coding agents working in this repository.

## Overview

This is a **macOS-focused** dotfiles repo managed primarily with **Nix** (nix-darwin + home-manager). Configs live in-repo under `.config/`, `.claude/`, `.codex/`, `.hammerspoon/`, and are deployed as symlinks via `home.file`. GNU Stow remains an optional lightweight alternative.

**Always respond to the user in Chinese** (see `.claude/CLAUDE_GLOBAL.md`). Code comments, commit messages, and these docs stay in English unless the user asks otherwise.

## Critical rules

1. **Never apply `darwin-rebuild` / `home-manager switch` without the user asking** — rebuilds change the live machine.
2. After changing files under `.claude/`, `.codex/`, `nix/`, or managed `.config/*`, remind the user to rebuild for deployment.
3. Hooks deployed via home-manager must set `executable = true` in the nix module.
4. **Documentation must track code** — after any project change, check whether **AGENTS.md** and/or **README.md** need updates before calling the work done. See [Documentation sync (mandatory)](#documentation-sync-mandatory).
5. Prefer editing source files in this repo; do not edit the live `~/.config/...` targets when they are HM-managed symlinks.

## Install / rebuild commands

```bash
# Clone
git clone git@github.com:uuau99999/.dotfiles.git ~/.dotfiles

# macOS (first time or full system switch)
sudo nix run --extra-experimental-features 'nix-command flakes' \
  nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure

# macOS (after first install)
darwin-rebuild switch --flake ~/.dotfiles/nix/#dev --impure

# Linux / WSL
nix run home-manager -- switch --flake ~/.dotfiles/nix/#dev --impure
# or, once home-manager is on PATH:
home-manager switch --flake ~/.dotfiles/nix/#dev --impure

# Optional symlink-only (no packages)
cd ~/.dotfiles && stow .
```

`--impure` is **required**: `env.nix` reads environment variables and `builtins.currentSystem`.

## Repository architecture

```
.dotfiles/
├── nix/
│   ├── flake.nix              # homeConfigurations.dev + darwinConfigurations.dev
│   ├── env.nix                # user / home / platform auto-detect
│   ├── darwin.nix             # system defaults, Homebrew, nix caches
│   ├── home.nix               # shared packages + imports
│   ├── home-darwin.nix        # macOS-only app modules
│   ├── apps/                  # zsh, nvim, tmux, git, claude-code, codex,
│   │                          # herdr, sesh, aerospace, hammerspoon,
│   │                          # sketchybar, fonts, uv/pipx-packages, ...
│   ├── programs/              # custom package wrappers
│   └── assets/fonts/
├── .config/                   # Source of truth for app configs
│   ├── nvim/                  # LazyVim
│   ├── tmux/
│   ├── herdr/
│   ├── sesh/
│   ├── sketchybar/
│   ├── ghostty/ kitty/ wezterm/ alacritty/
│   ├── yazi/
│   └── starship.toml
├── .claude/                   # Deployed to ~/.claude via claude-code.nix
│   ├── CLAUDE_GLOBAL.md       # → ~/.claude/CLAUDE.md (global agent rules)
│   ├── CLAUDE.md              # Project-local rules for this repo only
│   ├── settings.json
│   ├── hooks/
│   └── skills/
├── .codex/                    # Deployed to ~/.codex via codex.nix
├── .hammerspoon/
├── docs/
├── AGENTS.md
└── README.md
```

## Nix configuration flow

1. **`env.nix`**
   - User: `SUDO_USER` if set, else `USER`
   - Home: `/Users/<user>` on Darwin, `/home/<user>` on WSL, `/root` otherwise
   - Platform: `builtins.currentSystem`
2. **`flake.nix`**
   - `homeConfigurations.dev` → Linux/WSL
   - `darwinConfigurations.dev` → macOS (darwin.nix + home-manager user modules)
3. **`darwin.nix`** — dock/finder, hide menu bar, Touch ID for sudo, Homebrew casks/brews, substituters
4. **`home.nix`** — CLI packages (`eza`, `bat`, `fd`, `ripgrep`, `fnm`, `go`, `uv`, `pipx`, `television`, …) and shared `home.file`
5. **`home-darwin.nix`** — AeroSpace, SketchyBar, Hammerspoon, fonts; yabai module present, skhd commented out

### Where configs are managed

| Concern | Module / path |
|---------|----------------|
| Shell | `nix/apps/zsh.nix` |
| Neovim package + files | `nix/apps/nvim.nix` → `.config/nvim/` |
| tmux + helper scripts | `nix/apps/tmux.nix` → `.config/tmux/` |
| Git + delta | `nix/apps/git.nix` |
| Claude Code | `nix/apps/claude-code.nix` → `.claude/` |
| Codex hooks | `nix/apps/codex.nix` → `.codex/` |
| herdr | `nix/apps/herdr.nix` → `.config/herdr/` |
| sesh | `nix/apps/sesh.nix` → `.config/sesh/` |
| AeroSpace TOML | `nix/apps/aerospace.nix` (inline) |
| Hammerspoon | `nix/apps/hammerspoon.nix` → `.hammerspoon/` |
| SketchyBar | `nix/apps/sketchybar.nix` → `.config/sketchybar/` |
| Terminals (ghostty/kitty/wezterm) | `home.nix` `home.file` |
| Python CLIs | `uv-packages.nix` / `pipx-packages.nix` |

## App behavior notes for agents

### tmux

- Prefix: **`C-q`**
- Theme: Tokyo Night (TPM) + Catppuccin status modules (Catppuccin tree is Nix-vendored under `~/.config/tmux/plugins/`)
- Plugins via TPM: tpm, tokyo-night-tmux, tmux-floax, tmux-cpu, tmux-nerd-font-window-name
- Session picker: `prefix + f` → `tv sesh` popup; `prefix + l` → last sesh
- Helper scripts: `tmux-sessionizer`, `tmux-fzf`, `tmux-clear`, `tmux-cht.sh`, `tmux-tldr`, `tmux-lastsession`, `tmux-preview`
- Shell aliases: `p` / `f` / `x` wrap sessionizer / fzf / clear

### herdr

- Config + scripts live in `.config/herdr/`
- Deployed as **read-only** symlinks — herdr cannot write `config.toml` at runtime
- Aliases: `an`/`ap` cycle agent panes; `tn`/`tp` cycle tabs
- `herdr-cycle-agent.sh`: if any other agent is `blocked` (needs input/approval), jump to the nearest one in direction; otherwise normal next/prev. Current focus is excluded so a sole blocked agent does not trap the cycle. No local seen file — herdr’s own status model covers that.
- Workspace fzf/clear previews use `herdr pane read --source visible` on a representative pane
- Edit in-repo, then rebuild

### Neovim (LazyVim)

- Source: `.config/nvim/`
- Deployed: `init.lua`, `lua/`, `defaults/`, `stylua.toml`
- `lazy-lock.json` / `lazyvim.json` linked from shell init if missing (not HM-managed, so Lazy can update locks)
- Vue/TS-oriented plugins; avante, harpoon, yazi, neogit, etc. under `lua/plugins/`

### AeroSpace

- Config generated inline in `nix/apps/aerospace.nix`
- Vim-style focus/move: `alt+h/j/k/l`, `alt+shift+h/j/k/l`
- Workspaces `1–9`; app routing (Ghostty/Kitty→I, Chrome→C, Spotify→S, VSCode→V, WeCom→W, …)
- Starts SketchyBar on startup; notifies SketchyBar on workspace change

### Hammerspoon

- `alt+A` Cursor, `alt+B` Brave, `alt+C` Chrome, `alt+I` Ghostty, `alt+W` WeCom, `alt+S` Spotify, `alt+O` Obsidian, `alt+Z` Telegram, …
- Auto input method switching (`input-source.lua`)
- Auto-resize on app launch via Raycast `alt+m`

### Shell aliases (from `zsh.nix`)

```bash
v / vt     # nvim / nvim $(tv files)
ll         # eza long listing
yy         # yazi with cd-on-exit
c / ct     # bat / bat $(tv files)
t          # television
b / d / i  # npm run build / nr dev / ni
tma        # tmux attach
gup        # git pull --rebase
up / down  # docker compose
s          # serie
an ap tn tp  # herdr navigation
```

Local overrides: `~/.zshrc.local` is sourced if present.

### Claude Code conventions

| File | Role |
|------|------|
| `.claude/CLAUDE_GLOBAL.md` | Global rules deployed to `~/.claude/CLAUDE.md` |
| `.claude/CLAUDE.md` | **This repo only** — project structure notes |
| `.claude/settings.json` | Global Claude settings |
| `.claude/hooks/` | permission-guard, post-edit-lint-smart |
| `.claude/skills/` | bash-helper, create-skill, git-commit |

After any `.claude/` change: user must run `darwin-rebuild switch` (or equivalent) to deploy.

### Codex

Hooks under `.codex/hooks/` + `hooks.json`, deployed by `codex.nix`. Keep scripts executable in the nix module.

## Documentation sync (mandatory)

Docs lagging behind code is a recurring failure mode in this repo. **Treat documentation as part of the change, not a follow-up.**

### Process (every PR / every multi-file edit)

1. Finish the code/config change.
2. Re-read the diff mentally against **AGENTS.md** and **README.md**.
3. Update whichever docs are affected (often both when structure or install flow changes).
4. Only then mark the task complete or commit.
5. If you deliberately skip a doc update (pure typo, comment-only, lockfile-only), state that explicitly in the reply to the user.

### When docs **must** be updated

Update **AGENTS.md** and/or **README.md** if the change does any of the following:

| Change type | Typical doc target |
|-------------|--------------------|
| New/removed directory or top-level layout | Both (architecture tree) |
| New/removed `nix/apps/*` module or import path | Both (module table / layout) |
| Install, rebuild, or `stow` commands change | Both (install sections) |
| Homebrew casks/brews, packages, or platform split (darwin vs linux) | README highlights + AGENTS module notes |
| Keybindings, aliases, workspace routing, prefixes | README cheat sheet + AGENTS app notes |
| Claude / Codex / herdr / sesh / tmux behavior or deploy path | AGENTS app notes; README if user-facing |
| New troubleshooting mode or breaking deploy constraint | README troubleshooting + AGENTS critical rules |
| New skill/hook that agents should know about | AGENTS (and README only if users run it manually) |

### When docs can usually stay unchanged

- Pure content tweaks inside an existing config that do not change public behavior (e.g. theme color, one-off plugin option)
- `lazy-lock.json` / font asset binary updates with no workflow change
- Comment-only or formatting-only edits
- `docs/` plan notes that are not the live install path

When unsure: **update the docs**. Outdated docs cost more than a short extra edit.

### Ownership split

| File | Audience | Keep accurate for |
|------|----------|-------------------|
| **README.md** | Humans | Install, rebuild, layout overview, keybindings, troubleshooting |
| **AGENTS.md** | AI agents | Critical rules, module map, edit patterns, deploy constraints, verification |
| **`.claude/CLAUDE.md`** | Claude in this repo | Project-local structure notes if agent conventions change |
| **`.claude/CLAUDE_GLOBAL.md`** | Claude globally | Only if global workflow rules change (deployed via HM) |

Do not leave AGENTS.md describing modules or paths that no longer exist. Do not leave README install commands that would fail on a clean machine.

## Editing patterns

### Add a new home-manager app module

1. Create `nix/apps/<name>.nix`
2. Import from `home.nix` (cross-platform) or `home-darwin.nix` (macOS-only)
3. Prefer `home.file."path".source = ../../.config/...` for real files in-repo
4. **Sync docs**: architecture tree + module table in AGENTS.md; layout/highlights in README.md if user-visible

### Change Homebrew packages

Edit `homebrew.casks` / `homebrew.brews` in `darwin.nix`, then update README package notes if the cask/brew is part of the documented stack.

### Change system defaults

Edit `system.defaults` in `darwin.nix`.

### Do **not**

- Commit `.claude/settings.local.json` (gitignored)
- Hand-edit live HM symlinks under `~` for managed files
- Remove `--impure` from documented commands
- Assume Linux has AeroSpace / SketchyBar / Hammerspoon modules applied (they are darwin-only)
- Ship structural/workflow changes without checking AGENTS.md / README.md

## Verification checklist

When changing configs:

1. Nix evaluates: `nix flake check ~/.dotfiles/nix --impure` (if applicable) or dry-run rebuild when the user requests it
2. Shell syntax: careful with nested quotes in `zsh.nix` `initContent` / `envExtra`
3. tmux: config reloads with `prefix + r`
4. Hammerspoon: reloads on `.lua` save via pathwatcher
5. Hooks: confirm `executable = true` and that paths match `settings.json` / `hooks.json`
6. **Docs**: re-check AGENTS.md and README.md against the change (see [Documentation sync](#documentation-sync-mandatory)); update or explicitly skip with reason

## Related docs

- [README.md](./README.md) — human-oriented install & overview
- [.claude/CLAUDE.md](./.claude/CLAUDE.md) — project-local Claude instructions
- [.claude/CLAUDE_GLOBAL.md](./.claude/CLAUDE_GLOBAL.md) — global agent language/workflow rules
- [docs/](./docs/) — migration plans and superpowers notes
