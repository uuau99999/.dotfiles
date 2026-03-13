#!/bin/bash
# ~/.claude/hooks/task-completion-notify.sh
# Send system notification when task completes

set -euo pipefail

# Check if jq is available
if ! command -v jq &> /dev/null; then
  # Silently exit if jq not available (don't block on notification)
  exit 0
fi

# Get notification message from input or use default
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Task completed"')
TITLE="Claude Code"

# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Darwin*)
      echo "macos"
      ;;
    Linux*)
      # Check if running in WSL
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

OS=$(detect_os)

# Send notification based on OS
send_notification() {
  local title=$1
  local message=$2

  case "$OS" in
    macos)
      osascript -e "display notification \"$message\" with title \"$title\""
      ;;
    linux)
      # Try notify-send (most common)
      if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
      # Fallback to zenity
      elif command -v zenity &> /dev/null; then
        zenity --info --title="$title" --text="$message" --timeout=5
      # Fallback to kdialog (KDE)
      elif command -v kdialog &> /dev/null; then
        kdialog --title "$title" --passivepopup "$message" 5
      else
        echo "No notification tool found on Linux"
        return 1
      fi
      ;;
    wsl)
      # WSL: use powershell.exe to send Windows toast notification
      if command -v powershell.exe &> /dev/null; then
        # Convert WSL path to Windows path for temp file
        TEMP_PS="/tmp/claude-notify-$$.ps1"
        cat > "$TEMP_PS" << 'PSEOF'
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipTitle = $args[0]
$notification.BalloonTipText = $args[1]
$notification.Visible = $true
$notification.ShowBalloonTip(5000)
Start-Sleep -Seconds 1
$notification.Dispose()
PSEOF
        WIN_PATH=$(wslpath -w "$TEMP_PS" 2>/dev/null || echo "$TEMP_PS")
        powershell.exe -ExecutionPolicy Bypass -File "$WIN_PATH" "$title" "$message" 2>/dev/null || true
        rm -f "$TEMP_PS"
      # Fallback to Linux notification tools if installed in WSL
      elif command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
      else
        echo "No notification tool found in WSL"
        return 1
      fi
      ;;
    windows)
      # Native Windows (Cygwin/MSYS/MinGW)
      TEMP_PS="/tmp/claude-notify-$$.ps1"
      cat > "$TEMP_PS" << 'PSEOF'
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipTitle = $args[0]
$notification.BalloonTipText = $args[1]
$notification.Visible = $true
$notification.ShowBalloonTip(5000)
Start-Sleep -Seconds 1
$notification.Dispose()
PSEOF
      powershell.exe -ExecutionPolicy Bypass -File "$TEMP_PS" "$title" "$message" 2>/dev/null || true
      rm -f "$TEMP_PS"
      ;;
    *)
      echo "Unsupported operating system: $OS"
      return 1
      ;;
  esac
}

# Send the notification
send_notification "$TITLE" "$MESSAGE"

# Always exit successfully (don't block on notification failure)
exit 0
