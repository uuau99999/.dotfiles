# Herdr Neovim popup

Per-workspace Neovim launched from Herdr with `prefix+n`. The same chord hides the popup and leaves that workspace's Neovim running. The next `prefix+n` in the same workspace attaches to it.

This follows `herdr-yazi`: a `type = "popup"` command, Neovim inside a private tmux server, and the second chord handled inside that tmux because the popup consumes every key.

## Binding

In `.config/herdr/config.toml`:

- key: `prefix+n`
- type: `popup`
- command: `~/.config/herdr/herdr-nvim`
- width / height: `100%` / `100%`
- description: `toggle neovim`
- frame: `theme.custom.panel_bg = "reset"` so the hardcoded 1-cell border uses the terminal background

`prefix+shift+n` stays the built-in new-workspace binding. No other binding changes.

## Files

| Path | Role |
|------|------|
| `.config/herdr/herdr-nvim` | Popup command. Deployed with `executable = true`. |
| `.config/herdr/herdr-nvim.tmux.conf` | Config for the private tmux server. Does not source the user tmux config. |
| `nix/apps/herdr.nix` | `home.file` entries for both files. |
| `.config/herdr/config.toml` | `prefix+n` binding. |
| `AGENTS.md` | Herdr behavior note next to the Yazi bullet. |
| `README.md` | Herdr paragraph and key table, next to `prefix+y`. |

Shell alias `v` is unchanged. This command is Herdr-only.

## Workspace and session

One private tmux server, socket name `herdr-nvim` (`tmux -L herdr-nvim`). One session per Herdr workspace.

Resolve the workspace only from `herdr workspace list`:

```jq
(.result.workspaces // []) | map(select(.focused == true)) | .[0].workspace_id // empty
```

Use that focused workspace. Do not call `herdr pane current`, and do not read `HERDR_WORKSPACE_ID`. The popup command is not a plugin action, so an inherited workspace variable is not the focused workspace.

Session name: `nvim-` plus `workspace_id` with every character outside `[A-Za-z0-9_-]` replaced by `_`. Two ids that sanitize to the same string share one session. Herdr workspace ids are opaque; typical ids do not collide under that alphabet.

- Session already exists: `attach-session`. Do not change its directory and do not start a second Neovim.
- Session missing: `new-session -c "$cwd"` with command `exec nvim` and no file arguments.
- `$cwd` is `HERDR_ACTIVE_PANE_CWD` when that path is a directory, otherwise `"$HOME"`.
- Neovim exiting (`:qa` and any other full quit) ends the pane process, so tmux ends that session. The next `prefix+n` in that workspace starts a new Neovim in the then-focused pane's directory.

Other workspaces keep their own sessions on the same server. The popup can show only one client. Hiding it is required before switching workspace and opening the other Neovim.

## Hide chord

`herdr-nvim.tmux.conf` sets `prefix` to `C-q` and leaves the status bar off. It also sets `mouse off`, `escape-time 0`, `focus-events on`, `allow-passthrough on`, `window-size latest`, `default-terminal "tmux-256color"`, and RGB terminal features, matching `herdr-yazi.tmux.conf`.

- `bind n detach-client` — `prefix+n` inside the popup detaches this client only. Neovim keeps running.
- `bind C-q send-prefix` — pressing the prefix twice delivers `ctrl+q` to Neovim.

## Orphan sessions

A workspace that has been closed no longer has a focused id, but its Neovim session would otherwise stay on the server.

On each launch, after a successful `herdr workspace list` that contains the focused workspace:

1. Sanitize every non-empty `workspace_id` in that list. Skip blank ids.
2. List sessions on `herdr-nvim`. A missing server is not an error.
3. `kill-session` for each session named `nvim-<sanitized>` whose sanitized id is not in the live set.

The focused workspace is in the live set, so its session is not killed. If `workspace list` fails or yields no focused id, the command exits before any kill. An empty parsed id set never triggers a kill.

Killing an orphan session discards unsaved Neovim state for a workspace Herdr no longer lists.

## Failures

Check `tmux`, `nvim`, `herdr`, and `jq` first. A missing command prints `herdr-nvim: '<dep>' not found in PATH` to stderr and exits 127.

`herdr workspace list` failing, or no focused `workspace_id`, prints `herdr-nvim: no focused workspace` to stderr and exits 1. Do not attach to any existing session in that case.

The tmux config path is the file next to the script, then `~/.config/herdr/herdr-nvim.tmux.conf` when the script is invoked through the deployed symlink.

## Out of scope

- A Herdr plugin, a zoomed pane, or a per-workspace tmux socket.
- Passing a file or directory argument to Neovim. LazyVim startup in that cwd is the view.
- Changing Yazi, Floax, or the shell `v` alias.
- Running `darwin-rebuild` as part of the change. The user rebuilds to deploy.

## Verification

- `bash -n .config/herdr/herdr-nvim`
- After the user rebuilds: in workspace A, `prefix+n` starts Neovim; `prefix+n` again closes the popup and leaves the process; `prefix+n` restores the same buffers. In workspace B, `prefix+n` is a different Neovim. `:qa` in one workspace does not stop the other. Closing a workspace and pressing `prefix+n` elsewhere removes that closed workspace's session (`tmux -L herdr-nvim list-sessions`).
