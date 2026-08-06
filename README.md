# Hoyup .dotfiles

macOS-focused development environment managed with **Nix** ([nix-darwin](https://github.com/LnL7/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager)). Optional [GNU Stow](https://www.gnu.org/software/stow/) for lightweight symlink-only installs.

## Highlights

| Area | Stack |
|------|--------|
| Package / system | Nix flakes, nix-darwin, home-manager, Homebrew (casks/brews) |
| Shell | zsh + oh-my-zsh, fzf, zoxide, starship, carapace, television |
| Editor | Neovim (LazyVim), lazygit, delta |
| Terminal | Ghostty (primary), Kitty, WezTerm, Alacritty |
| Multiplexer | tmux (prefix `C-q`) + [sesh](https://github.com/joshmedeski/sesh) / [herdr](https://herdr.dev) |
| Window mgmt | AeroSpace + SketchyBar + Hammerspoon |
| AI tooling | Claude Code & Codex configs/hooks via home-manager |

## Requirements

- macOS (primary) or Linux/WSL (home-manager only)
- [Nix](https://nixos.org/download/) with flakes enabled
- Git
- (Optional) [GNU Stow](https://www.gnu.org/software/stow/) for non-Nix symlink installs
- (macOS) Homebrew is managed by nix-darwin once the flake is applied

## Quick start

### 1. Clone

```bash
git clone git@github.com:uuau99999/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Apply Nix environment

`env.nix` auto-detects `USER` / `HOME` / platform. **Always pass `--impure`.**

**macOS (nix-darwin + home-manager):**

```bash
sudo nix run --extra-experimental-features 'nix-command flakes' \
  nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
```

After the first successful switch you can use:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix/#dev --impure
```

**Linux / WSL (home-manager only):**

```bash
nix run home-manager -- switch --flake ~/.dotfiles/nix/#dev --impure
```

### 3. Optional: Stow-only configs

If you only want config file symlinks without Nix packages:

```bash
cd ~/.dotfiles
stow .
```

Most day-to-day configs are already deployed by home-manager (`home.file`); Stow is mainly a fallback.

### 4. tmux plugins

TPM and the Catppuccin theme are vendored via Nix. Remaining TPM plugins install on first run:

```bash
# Enter tmux, then:
# prefix + I   install plugins
# prefix + r   reload config
```

## Daily rebuild workflow

After editing anything under `nix/`, `.config/`, `.claude/`, `.codex/`, or `.hammerspoon/`:

```bash
# macOS
darwin-rebuild switch --flake ~/.dotfiles/nix/#dev --impure

# Linux/WSL
home-manager switch --flake ~/.dotfiles/nix/#dev --impure
```

## Repository layout

```
.dotfiles/
├── nix/                         # Flake entrypoint
│   ├── flake.nix                # homeConfigurations.dev + darwinConfigurations.dev
│   ├── env.nix                  # Auto-detect user / home / platform
│   ├── darwin.nix               # macOS system defaults + Homebrew
│   ├── home.nix                 # Shared packages & home.file
│   ├── home-darwin.nix          # macOS-only home modules
│   ├── apps/                    # Per-app home-manager modules
│   ├── programs/                # Custom derivations (hammerspoon, sketchybar)
│   └── assets/fonts/            # Private fonts (IoskeleyMono, etc.)
├── .config/
│   ├── nvim/                    # LazyVim config
│   ├── tmux/                    # tmux.conf + helper scripts
│   ├── herdr/                   # herdr config + workspace helpers
│   ├── sesh/                    # sesh session picker
│   ├── sketchybar/              # Status bar items/plugins/helper
│   ├── ghostty/ kitty/ wezterm/ alacritty/
│   ├── yazi/                    # File manager
│   └── starship.toml
├── .claude/                     # Claude Code (deployed to ~/.claude via HM)
│   ├── CLAUDE_GLOBAL.md         # → ~/.claude/CLAUDE.md
│   ├── CLAUDE.md                # Project-local instructions for this repo
│   ├── settings.json
│   ├── hooks/
│   └── skills/
├── .codex/                      # Codex CLI hooks
├── .hammerspoon/                # App hotkeys + input method switching
├── docs/                        # Plans / migration notes
├── AGENTS.md                    # Guidance for AI coding agents
└── README.md
```

## Key bindings (cheat sheet)

### AeroSpace

| Keys | Action |
|------|--------|
| `alt+h/j/k/l` | Focus window |
| `alt+shift+h/j/k/l` | Move window |
| `alt+1..9` | Switch workspace |
| `alt+shift+1..9` | Move node to workspace |
| `alt+tab` | Workspace back-and-forth |
| `alt+ctrl+f` | Fullscreen |
| `alt+shift+r` | Resize mode |

Apps auto-route to workspaces (e.g. Ghostty/Kitty → `I`, Chrome → `C`, Spotify → `S`, VS Code → `V`, WeCom → `W`).

### Hammerspoon app launchers

| Keys | App |
|------|-----|
| `alt+A` | Cursor |
| `alt+B` | Brave |
| `alt+C` | Chrome |
| `alt+I` | Ghostty |
| `alt+W` | 企业微信 |
| `alt+S` | Spotify |
| `alt+O` | Obsidian |
| `alt+Z` | Telegram |
| `alt+N` | Notes |
| `alt+E` | Simulator |

### tmux

| Keys | Action |
|------|--------|
| `C-q` | Prefix (not `C-b`) |
| `prefix + r` | Reload config |
| `prefix + f` | Sesh session picker (via television) |
| `prefix + l` | Last sesh session |
| `prefix + m` | Floax floating pane |
| `M-Up` / `M-Down` | Select pane vertically |

Shell shortcuts (outside tmux): `p` sessionizer · `f` tmux-fzf · `x` clear · `an`/`ap` herdr agent cycle · `tn`/`tp` herdr tab cycle.

### Shell aliases (selected)

```bash
v      # nvim
vt     # nvim $(tv files)
ll     # eza with icons
yy     # yazi (cd on exit)
c      # bat -p
t      # television (tv)
b      # npm run build
d      # nr dev
i      # ni
tma    # tmux attach
gup    # git pull --rebase
up     # docker compose up
s      # serie (git log TUI)
```

## Components in more detail

### Nix flow

1. `env.nix` reads `SUDO_USER` / `USER`, home path, and `builtins.currentSystem` (needs `--impure`).
2. `flake.nix` exposes:
   - `homeConfigurations.dev` — Linux/WSL
   - `darwinConfigurations.dev` — macOS (nix-darwin + home-manager)
3. `darwin.nix` — dock/finder defaults, Touch ID sudo, Homebrew casks/brews, binary caches (Tsinghua mirror + cache.nixos.org).
4. `home.nix` — shared CLI tools and imports under `nix/apps/`.
5. `home-darwin.nix` — AeroSpace, SketchyBar, Hammerspoon, fonts (yabai available but secondary).

### AI tooling

- **Claude Code**: `.claude/` → `~/.claude/` via `nix/apps/claude-code.nix`. Global instructions live in `CLAUDE_GLOBAL.md`; this repo’s own notes are in `.claude/CLAUDE.md`.
- **Codex**: hooks under `.codex/` via `nix/apps/codex.nix`.
- **herdr**: multi-agent terminal config + helper scripts under `.config/herdr/` (managed as read-only symlinks; edit in-repo then rebuild).

### Neovim

LazyVim-based setup under `.config/nvim/`. Deployed pieces: `init.lua`, `lua/`, `defaults/`, `stylua.toml`. `lazy-lock.json` / `lazyvim.json` are linked at shell init if missing.

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| `error: experimental Nix feature ... is disabled` | Pass `--extra-experimental-features 'nix-command flakes'`, or enable them in `/etc/nix/nix.conf`. |
| Wrong user/home when using `sudo` | Expected: `env.nix` uses `SUDO_USER`. Always keep `--impure`. |
| home-manager backup conflicts | Backups use extension `.backup` (set in `darwin.nix`). Move/remove `*.backup` files under `~` and rebuild. |
| GitHub rate limits during flake eval | Set a token: `--access-tokens github.com=YOUR_TOKEN` or `nix.conf` `access-tokens`. |
| Claude/Codex hooks not executable after edit | Ensure `executable = true` in the corresponding `nix/apps/*.nix` module, then rebuild. |
| herdr cannot write `config.toml` | Symlink is read-only by design. Edit `.config/herdr/config.toml` in this repo and rebuild. |
| SketchyBar missing | Installed via Homebrew (`FelixKratz/formulae/sketchybar`); AeroSpace starts it on login. |
| tmux plugins missing | Open tmux and run `prefix + I`. |

## Contributing / personalizing

1. Prefer adding new app modules under `nix/apps/` and importing them from `home.nix` or `home-darwin.nix`.
2. Keep machine-local overrides in `~/.zshrc.local` (sourced automatically).
3. Python CLI tools: declare in `nix/apps/uv-packages.nix` or `pipx-packages.nix`.
4. **Docs follow code**: after any structural, install, keybinding, or module change, update **README.md** and/or **AGENTS.md** in the same change. Agents must treat this as mandatory (see AGENTS.md → *Documentation sync*).

## License

Personal dotfiles — use at your own risk. Adapt freely for your own setup.
