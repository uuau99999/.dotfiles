# Neovim 0.12 Migration Plan

Date: 2026-06-03
Branch: `codex/nvim-0-12-migration-plan`

## Goal

Upgrade this dotfiles repository from Neovim 0.11.x to Neovim 0.12.x, then migrate the Neovim config toward 0.12-era best practices without mixing in unrelated editor rewrites.

The first implementation round should keep the existing LazyVim + lazy.nvim architecture. Neovim 0.12 includes newer native features such as `vim.pack` and stronger built-in completion, but changing plugin manager or completion engine in the same round would make regressions much harder to isolate.

## Current State

- Local `nvim --version` reports `NVIM v0.11.6`.
- The current flake resolves `programs.neovim` to `0.11.6`.
- `nix/apps/nvim.nix` only enables Neovim and does not pin a package:
  - `programs.neovim.enable = true`
  - no `programs.neovim.package`
- `nix/flake.nix` uses `github:NixOS/nixpkgs/nixpkgs-unstable`, but the locked nixpkgs revision still contains Neovim 0.11.6.
- `.config/nvim/lazy-lock.json` pins LazyVim and many important plugins, including `nvim-lspconfig`, `mason-lspconfig.nvim`, `noice.nvim`, `nvim-cmp`, `nvim-treesitter`, `gitsigns.nvim`, and `diffview.nvim`.
- There is an unrelated dirty file in the worktree: `docs/superpowers/plans/2026-03-13-claude-hooks-optimization.md`. Keep it out of this migration.

## Source Notes

Official release sources show Neovim 0.12.2 as a stable release. Neovim 0.12 brings useful LSP, UI message, diff, terminal, and default-setting changes. LazyVim currently requires Neovim `>= 0.11.2`, so the project is compatible with the 0.12 line, but the plugin lock must be refreshed alongside the binary upgrade.

Important upstream guidance:

- `require("lspconfig")` is now the legacy nvim-lspconfig framework and should be replaced with `vim.lsp.config()` and `vim.lsp.enable()`.
- `mason-lspconfig.nvim` now has `automatic_enable`, which can enable installed servers through `vim.lsp.enable()`.
- The old `mason-lspconfig.setup_handlers()` style should be removed during the migration.

## Hotspots In This Repo

1. Duplicate Volar setup

   `.config/nvim/init.lua` manually calls:

   ```lua
   local lspconfig = require("lspconfig")
   lspconfig.volar.setup({
     filetypes = { "vue" },
     init_options = {
       vue = {
         hybridMode = false,
       },
     },
   })
   ```

   `.config/nvim/lua/plugins/lsp.lua` also configures `volar`, currently with `hybridMode = true`. This conflict should be resolved in one place.

   Recommendation: remove the manual `init.lua` setup and keep all LSP configuration in `lua/plugins/lsp.lua` or native `lsp/*.lua` / `after/lsp/*.lua` files. If no Vue TypeScript plugin is wired into `vtsls`, prefer `hybridMode = false` for Volar to preserve Vue behavior.

2. Legacy bulk LSP setup

   `.config/nvim/lua/plugins/lsp.lua` has:

   ```lua
   masonLsp.setup_handlers({
     function(server_name)
       require("lspconfig")[server_name].setup({
         capabilities = capabilities,
         settings = servers[server_name],
         filetypes = (servers[server_name] or {}).filetypes,
       })
     end,
   })
   ```

   This is the largest 0.12 migration item. Replace it with native LSP config plus LazyVim's LSP flow. Mason should install servers; native LSP or LazyVim should enable/configure them.

3. SourceKit root detection depends on lspconfig util

   `.config/nvim/lua/plugins/lsp.lua` uses:

   ```lua
   local lspconfig = require("lspconfig")
   return lspconfig.util.root_pattern(...)
   ```

   Replace this with `vim.fs.root()` or a native `root_markers` style supported by Neovim 0.12 / nvim-lspconfig.

4. LSP restart keymap

   `.config/nvim/lua/config/keymaps.lua` calls `vim.cmd.LspRestart()`. Migrate this to the newer command form:

   ```lua
   nmap("<leader>lr", "<cmd>lsp restart<cr>", "Restart LSP")
   ```

5. `init.lua` is doing too much

   `init.lua` currently bootstraps LazyVim, loads Telescope extensions, customizes Telescope, configures Volar, and sets colorscheme. Best practice for this repository is to keep `init.lua` as a tiny bootstrap and move runtime config into plugin specs or `lua/config/*`.

## Recommended Migration Phases

### Phase 0: Baseline

Record the current state before changing config:

```bash
git status --short --branch
nvim --version
nix eval --raw --impure ./nix#darwinConfigurations.dev.pkgs.neovim.version
```

Interactive baseline checks:

```vim
:Lazy
:checkhealth
:checkhealth vim.lsp
:messages
```

Open representative files before migration:

- Vue file: confirm Volar behavior and code actions.
- TypeScript file: confirm `vtsls`.
- Swift file: confirm `sourcekit`.
- Go file: confirm `gopls`.
- A git diff: confirm Gitsigns/Diffview.
- A terminal buffer: confirm terminal behavior.

### Phase 1: Upgrade Neovim Package

There are two valid Nix strategies.

Preferred for a controlled migration:

- Add a dedicated Neovim package input, for example `nixpkgs-nvim`, pinned to a nixpkgs revision whose `neovim.version` is `0.12.2`.
- Pass the derived `nvimPkgs` through `specialArgs`.
- Set `programs.neovim.package = nvimPkgs.neovim-unwrapped` in `nix/apps/nvim.nix`.
- Keep the main dotfiles `nixpkgs` lock unchanged until the editor migration is proven.

Why `neovim-unwrapped`: home-manager wraps Neovim itself, and the wrapped `nvimPkgs.neovim` package fails inside home-manager's wrapper path because the expected unwrapped package attributes are missing.

Simpler but wider blast radius:

- Update the existing `nixpkgs` lock.
- Re-evaluate Neovim and inspect all system package drift.
- Use this only if a broader dotfiles package refresh is acceptable.

Validation after the package change:

```bash
nix eval --raw --impure ./nix#darwinConfigurations.dev.config.home-manager.users.hoyupye.programs.neovim.finalPackage.version
nix build --impure ./nix#darwinConfigurations.dev.system
```

Then switch only after the build succeeds:

```bash
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
nvim --version
```

### Phase 2: Refresh Lazy Plugins

Do this after Neovim 0.12 is active.

Recommended interactive flow:

```vim
:Lazy sync
:Lazy health
:checkhealth
:checkhealth vim.lsp
```

Pay special attention to these locked plugins:

- `LazyVim`
- `lazy.nvim`
- `nvim-lspconfig`
- `mason.nvim`
- `mason-lspconfig.nvim`
- `noice.nvim`
- `nui.nvim`
- `nvim-notify`
- `nvim-cmp` and cmp sources
- `nvim-treesitter`
- `gitsigns.nvim`
- `diffview.nvim`

Commit `.config/nvim/lazy-lock.json` only after the editor starts cleanly and the LSP checks pass.

### Phase 3: Migrate LSP Configuration

Target state:

- No direct `require("lspconfig").server.setup(...)`.
- No `masonLsp.setup_handlers(...)`.
- Mason installs tools and servers.
- LazyVim/native LSP owns enabling and configuring servers.
- Server customizations live in one place.

Implementation shape:

1. Remove manual Volar setup from `.config/nvim/init.lua`.
2. Keep `volar`, `vtsls`, `sourcekit`, and `gopls` settings under `.config/nvim/lua/plugins/lsp.lua`, unless moving to `lsp/*.lua` / `after/lsp/*.lua` proves cleaner.
3. Convert custom server settings to `vim.lsp.config("<server>", { ... })` where direct native config is needed.
4. Let `vim.lsp.enable("<server>")`, LazyVim, or Mason's `automatic_enable` enable servers, but do not double-enable.
5. Change `sourcekit` root detection away from `lspconfig.util.root_pattern`.
6. Re-check that only one client attaches per buffer.

Suggested Mason posture:

- If LazyVim is enabling servers, set Mason LSP config to install-only behavior where possible, e.g. `automatic_enable = false`.
- If using Mason's `automatic_enable = true`, make sure all `vim.lsp.config()` customizations run before Mason enables the servers.

### Phase 4: Move Non-Bootstrap Config Out Of init.lua

Keep `init.lua` close to:

```lua
require("config.lazy")
```

Then migrate:

- Telescope extension loading and setup into `.config/nvim/lua/plugins/editor.lua` or a dedicated Telescope plugin file.
- Colorscheme command into `.config/nvim/lua/plugins/colorscheme.lua` or LazyVim colorscheme config.
- LSP setup into the LSP migration from Phase 3.

This makes the config easier to reason about and closer to LazyVim starter conventions.

### Phase 5: Adopt 0.12 Features Conservatively

Do now:

- Use `:lsp restart` keymap form.
- Rely on improved `:checkhealth vim.lsp`.
- Keep 0.12 default `diffopt` behavior unless it conflicts with custom diff plugins.

Do not do in the first migration:

- Do not replace lazy.nvim with `vim.pack`.
- Do not replace `nvim-cmp` or Supermaven with native completion yet.
- Keep `lazyvim.plugins.extras.coding.nvim-cmp` enabled so LazyVim disables `blink.cmp` during this first migration.
- Do not enable experimental UI features such as `ui2` until Noice behavior is verified.

Later optional work:

- Evaluate native completion or `blink.cmp` after LazyVim updates settle.
- Decide whether `nvim-cmp` cmdline completion is still needed.
- Revisit Noice routes once 0.12 message behavior is stable in daily use.

## Applied Migration

Implemented on branch `codex/nvim-0-12-migration-plan`:

- Added a dedicated `nixpkgs-nvim` flake input so the Neovim upgrade is isolated from the rest of the dotfiles package set.
- Set home-manager's Neovim package to `nvimPkgs.neovim-unwrapped`; the evaluated wrapped `finalPackage.version` is `0.12.2`.
- Reduced `.config/nvim/init.lua` to the LazyVim bootstrap only.
- Moved Telescope setup and extension loading into `lua/plugins/editor.lua`.
- Moved the colorscheme command into `lua/plugins/colorscheme.lua`.
- Migrated LSP configuration away from `require("lspconfig").setup()` and `mason-lspconfig.setup_handlers()`.
- Replaced the old Volar name with `vue_ls`, disabled `tsserver`/`ts_ls`/`volar`, and configured `vtsls` with the Vue TypeScript plugin.
- Replaced SourceKit root detection based on `lspconfig.util` with `vim.fs.root()` plus Xcode project/workspace glob fallback.
- Updated renamed plugin specs for `mason-org/*`, `nvim-mini/*`, and Codeberg `leap.nvim`.
- Enabled LazyVim's `nvim-cmp` extra to keep the first migration on the existing completion engine and disable `blink.cmp`.
- Disabled lazy.nvim rocks support because no current plugin needs luarocks and this setup manages tools through Nix/Mason.
- Kept `nvim-treesitter` on LazyVim's main-branch config path and changed the local Treesitter file to extend `opts` only.
- Added Nix-managed `luacheck`, `nvimPkgs.tree-sitter`, and an `sg` wrapper around `ast-grep` so headless validation and Telescope's `ast_grep` extension have stable PATH tools.

## Validation Plan

Automated or command-line:

```bash
nix eval --raw --impure ./nix#darwinConfigurations.dev.config.home-manager.users.hoyupye.programs.neovim.package.version
nix eval --raw --impure ./nix#darwinConfigurations.dev.config.home-manager.users.hoyupye.programs.neovim.finalPackage.version
nix build --impure ./nix#darwinConfigurations.dev.system

nix build -o /private/tmp/nvim-0.12-result --impure ./nix#darwinConfigurations.dev.config.home-manager.users.hoyupye.programs.neovim.finalPackage
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+lua print("clean-start")' '+qa'

XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+Lazy! sync' '+qa'
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth lazy' '+qa'
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth vim.lsp' '+qa'
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth mason-lspconfig' '+qa'
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth nvim-treesitter' '+qa'
XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth telescope' '+qa'
```

After the Nix switch:

```bash
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
nvim --version
nvim --headless '+lua print("post-switch-clean-start")' '+qa'
```

Before switching, simulate the post-switch PATH from the built home-manager path:

```bash
HOME_PATH="$(nix eval --raw --impure ./nix#darwinConfigurations.dev.config.home-manager.users.hoyupye.home.path)"
PATH="$HOME_PATH/bin:$HOME/.local/share/nvim/mason/bin:$PATH" \
  XDG_CONFIG_HOME=/Users/hoyupye/.dotfiles/.config \
  /private/tmp/nvim-0.12-result/bin/nvim --headless '+checkhealth' '+qa'
```

Expected command-line results:

- `programs.neovim.package.version` and `programs.neovim.finalPackage.version` both report `0.12.2`.
- `nix build --impure ./nix#darwinConfigurations.dev.system` succeeds.
- Headless startup exits cleanly.
- `:checkhealth vim.lsp` lists `vue_ls`, `vtsls`, `sourcekit`, and `gopls`.
- `vtsls.settings.vtsls.tsserver.globalPlugins[1].location` points at the Mason `@vue/language-server` package directory.
- There are no warnings for obsolete `javascript.jsx` or `typescript.tsx` filetypes.
- Any Mason installer output should finish before the final health pass; if headless Neovim exits while async installs are still running, rerun the Mason install/check command with enough wait time.
- `checkhealth lazy` reports `luarocks disabled`.
- `checkhealth nvim-treesitter` finds `tree-sitter-cli >= 0.26.1`.
- `checkhealth telescope` reports `ast_grep` healthy through the `sg` wrapper.

Current validation results from this branch:

- `programs.neovim.package.version`: `0.12.2`.
- `programs.neovim.finalPackage.version`: `0.12.2`.
- `nix build -o /private/tmp/dotfiles-system-validate --impure ./nix#darwinConfigurations.dev.system`: passed.
- Clean headless startup: passed, with `nvim-cmp=true` and `blink.cmp=false`.
- `checkhealth lazy`: passed.
- `checkhealth nvim-treesitter`: passed with `tree-sitter-cli 0.26.8` from the built home-manager path.
- `checkhealth telescope`: passed; `sg` resolves to `ast-grep 0.41.1`.
- `checkhealth vim.lsp`: passed for configured server registration; expected configs include `vue_ls`, `vtsls`, `sourcekit`, and `gopls`.

Remaining health notes:

- `checkhealth` still reports a `snacks.nvim` healthcheck exception in the transparent-theme/headless health path. Clean startup and the targeted LazyVim, LSP, Telescope, and Treesitter checks pass; verify Snacks dashboard/picker interactively after the switch.
- `checkhealth vim.lsp` warns about unknown filetypes from upstream defaults such as `gotmpl`, `objective-c`, `objective-cpp`, and Tailwind's broad template list. These are not the removed obsolete `javascript.jsx` / `typescript.tsx` entries.
- Full health also includes optional-provider warnings for Mercurial, fzf media preview tools, logger.nvim, node/perl/python Neovim providers, and neoconf's settings-file completion hints.

Interactive:

- `:Lazy` shows no plugin errors.
- `:checkhealth vim.lsp` shows expected enabled configs.
- `:lsp` / `:LspInfo` shows expected clients and no duplicate Volar clients.
- Vue file attaches Volar once and supports diagnostics, hover, rename, organize imports, and fix-all.
- TypeScript file attaches `vtsls`.
- Swift file attaches `sourcekit`.
- Go file attaches `gopls`.
- `nvim-cmp` completion works in insert mode.
- `/`, `?`, and `:` cmdline completion still work.
- Noice command line, hover, signature help, notifications, and `:messages` behave normally.
- Gitsigns hunk preview and Diffview still work.
- Terminal buffers no longer get polluted by process-exit text.

## Rollback Plan

Rollback package only:

- Revert the Nix package change or dedicated `nixpkgs-nvim` input.
- Run nix-darwin switch again.
- Confirm `nvim --version` is back to 0.11.6.

Rollback plugins only:

- Restore `.config/nvim/lazy-lock.json` from Git.
- Run `:Lazy restore`.

Rollback config only:

- Revert the LSP/config commits while keeping the package upgrade if plugins and Neovim 0.12 are otherwise healthy.

Suggested commit boundaries:

1. `nix: upgrade neovim to 0.12`
2. `nvim: refresh lazy lock for neovim 0.12`
3. `nvim: migrate lsp config to native api`
4. `nvim: move bootstrap-only config out of init`

## References

- https://github.com/neovim/neovim-releases/releases
- https://github.com/neovim/neovim/blob/v0.12.2/runtime/doc/news.txt
- https://github.com/neovim/nvim-lspconfig
- https://github.com/mason-org/mason-lspconfig.nvim
- https://www.lazyvim.org/
