{...}: {
  home.file = {
    ".config/aerospace/aerospace.toml".text = ''
# Place a copy of this config to ~/.aerospace.toml
# After that, you can edit ~/.aerospace.toml to your liking

# It's not necessary to copy all keys to your config.
# If the key is missing in your config, "default-config.toml" will serve as a fallback

# You can use it to add commands that run after login to macOS user session.
# 'start-at-login' needs to be 'true' for 'after-login-command' to work
# Available commands: https://nikitabobko.github.io/AeroSpace/commands
after-login-command = []

# You can use it to add commands that run after AeroSpace startup.
# 'after-startup-command' is run after 'after-login-command'
# Available commands : https://nikitabobko.github.io/AeroSpace/commands
after-startup-command = []

# Start AeroSpace at login
start-at-login = true

# Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

# See: https://nikitabobko.github.io/AeroSpace/guide#layouts
# The 'accordion-padding' specifies the size of accordion padding
# You can set 0 to disable the padding feature
accordion-padding = 30

# Possible values: tiles|accordion
default-root-container-layout = 'tiles'

# Possible values: horizontal|vertical|auto
# 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
#               tall monitor (anything higher than wide) gets vertical orientation
default-root-container-orientation = 'auto'

# Possible values: (qwerty|dvorak)
# See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
key-mapping.preset = 'qwerty'

# Mouse follows focus when focused monitor changes
# Drop it from your config, if you don't like this behavior
# See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
# See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
on-focus-changed = "move-mouse window-lazy-center"

# Gaps between windows (inner-*) and between monitor edges (outer-*).
# Possible values:
# - Constant:     gaps.outer.top = 8
# - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
#                 In this example, 24 is a default value when there is no match.
#                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
#                 See: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
[gaps]
inner.horizontal = 16
inner.vertical =   16
outer.left =       16
outer.bottom =     16
outer.top =        48
outer.right =      16

# 'main' binding mode declaration
# See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
# 'main' binding mode must be always presented
[mode.main.binding]

# All possible keys:
# - Letters.        a, b, c, ..., z
# - Numbers.        0, 1, 2, ..., 9
# - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
# - F-keys.         f1, f2, ..., f20
# - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
#                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
# - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
#                   keypadMinus, keypadMultiply, keypadPlus
# - Arrows.         left, down, up, right

# All possible modifiers: cmd, alt, ctrl, shift

# All possible commands: https://nikitabobko.github.io/AeroSpace/commands

# You can uncomment this line to open up terminal with alt + enter shortcut
# See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
# alt-enter = 'exec-and-forget open -n /System/Applications/Utilities/Terminal.app'

# See: https://nikitabobko.github.io/AeroSpace/commands#layout
alt-slash = 'layout tiles horizontal vertical'
alt-comma = 'layout accordion horizontal vertical'

# See: https://nikitabobko.github.io/AeroSpace/commands#focus
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

# See: https://nikitabobko.github.io/AeroSpace/commands#move
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'


# See: https://nikitabobko.github.io/AeroSpace/commands#workspace
alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'
alt-5 = 'workspace 5'
alt-6 = 'workspace 6'
alt-7 = 'workspace 7'
alt-8 = 'workspace 8'
alt-9 = 'workspace 9'
alt-a = 'workspace A'
alt-i = 'workspace I'
alt-s = 'workspace S'
alt-c = 'workspace C'
alt-w = 'workspace W'
alt-q = 'workspace Q'
alt-v = 'workspace V'
alt-d = 'workspace D'
alt-n = 'workspace N'

# See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'
alt-shift-5 = 'move-node-to-workspace 5'
alt-shift-6 = 'move-node-to-workspace 6'
alt-shift-7 = 'move-node-to-workspace 7'
alt-shift-8 = 'move-node-to-workspace 8'
alt-shift-9 = 'move-node-to-workspace 9'
alt-shift-a = 'move-node-to-workspace A'
alt-shift-i = 'move-node-to-workspace I'
alt-shift-s = 'move-node-to-workspace S'
alt-shift-c = 'move-node-to-workspace C'
alt-shift-w = 'move-node-to-workspace W'
alt-shift-q = 'move-node-to-workspace Q'
alt-shift-v = 'move-node-to-workspace V'
alt-shift-d = 'move-node-to-workspace D'
alt-shift-n = 'move-node-to-workspace N'

alt-ctrl-shift-f = 'fullscreen'
alt-ctrl-f = 'layout floating tiling'

# See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
alt-tab = 'workspace-back-and-forth'
# See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

# See: https://nikitabobko.github.io/AeroSpace/commands#mode
alt-shift-semicolon = 'mode service'

alt-shift-r = 'mode resize'

[mode.resize.binding]
h = 'resize width -50'
j = 'resize height +50'
k = 'resize height -50'
l = 'resize width +50'
b = 'balance-sizes'


# See: https://nikitabobko.github.io/AeroSpace/commands#resize
minus = 'resize smart -50'
equal = 'resize smart +50'

enter = 'mode main'
esc = 'mode main'

# 'service' binding mode declaration.
# See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
[mode.service.binding]
esc = ['reload-config', 'mode main']
r = ['flatten-workspace-tree', 'mode main'] # reset layout
#s = ['layout sticky tiling', 'mode main'] # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
backspace = ['close-all-windows-but-current', 'mode main']

alt-shift-h = ['join-with left', 'mode main']
alt-shift-j = ['join-with down', 'mode main']
alt-shift-k = ['join-with up', 'mode main']
alt-shift-l = ['join-with right', 'mode main']

# float windows

[[on-window-detected]]
if.app-name-regex-substring = '音乐'
run = 'layout floating'

[[on-window-detected]]
if.app-name-regex-substring = 'finder'
run = 'layout floating'

[[on-window-detected]]
if.app-name-regex-substring = 'preview'
run = 'layout floating'

[[on-window-detected]]
if.app-name-regex-substring = 'quicktime'
run = 'layout floating'

[[on-window-detected]]
if.app-name-regex-substring = 'Monitor'
run = 'layout floating'

[[on-window-detected]]
if.app-name-regex-substring = 'meeting'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'net.kovidgoyal.kitty'
run = "move-node-to-workspace I"

[[on-window-detected]]
if.app-id = 'com.tencent.WeWorkMac'
run = 'move-node-to-workspace W'

[[on-window-detected]]
if.app-id = 'com.google.Chrome'
run = "move-node-to-workspace C"

[[on-window-detected]]
if.app-id = 'com.spotify.client'
run = "move-node-to-workspace S"

[[on-window-detected]]
if.app-id = 'com.microsoft.VSCode'
run = "move-node-to-workspace V"

[[on-window-detected]]
if.app-id = 'company.thebrowser.Browser'
run = "move-node-to-workspace A"

    '';
  };
}