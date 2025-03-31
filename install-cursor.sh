#!/usr/bin/env bash
# shellcheck disable=SC2128

set -e

CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
# ICON_URL="https://www.cursor.com/favicon.svg"
CURSOR_ICON_URL="https://registry.npmmirror.com/@lobehub/icons-static-png/1.42.0/files/dark/cursor.png"
CURSOR_DIR="$HOME/.local/share/applications/cursor"
CURSOR_FULL_PATH="$CURSOR_DIR/cursor.appImage"
CURSOR_DESKTOP_PATH="$HOME/.local/share/applications/cursor.desktop"

CURSOR_BIN_DIR="$HOME/.local/bin"
# symlink path
CURSOR_BIN_PATH="$CURSOR_BIN_DIR/cursor"

if [ "$0" = "$BASH_SOURCE" ]; then
  echo "Executed locally"
  EXECUTED_LOCALLY=true
else
  echo "Executed remotely"
  EXECUTED_LOCALLY=false
fi

# check if curor is installed
if command -v cursor &>/dev/null; then
  echo "cursor.sh is already installed at $(which cursor)"
  if [ "$EXECUTED_LOCALLY" = true ]; then
    read -rp "Do you want to reinstall cursor.sh? [y/N] " response
  else
    read -rp "Do you want to reinstall cursor.sh? [y/N] " response </dev/tty
  fi
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exit 0
  fi
fi

TMP_DIR="$PWD/.tmp$(date +%s)"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

trap 'rm -rf $TMP_DIR' EXIT

# download cursor
curl -O -J "$CURSOR_URL"
CURSOR_DOWNLOAD=$(find "$TMP_DIR" -type f -printf '%T+ %p\n' | sort -r | head -n1 | cut -d' ' -f2-)
chmod +x "$CURSOR_DOWNLOAD"

mkdir -p "$CURSOR_DIR"
mv "$CURSOR_DOWNLOAD" "$CURSOR_DIR/cursor.appImage"

curl -o "$TMP_DIR/cursor.png" "$CURSOR_ICON_URL"          # download icon
cp "$TMP_DIR/cursor.png" "$CURSOR_DIR/cursor.png"         # copy icon to cursor dir
sudo mv "$TMP_DIR/cursor.png" "/usr/local/bin/cursor.png" # move icon to /usr/local/bin

[ -f "$CURSOR_BIN_PATH" ] && rm -f "$CURSOR_BIN_PATH" #  rm symlink if it exists
ln -s "$CURSOR_FULL_PATH" "$CURSOR_BIN_PATH"          #  create symlink

# create desktop shortcut
cat >"$CURSOR_DESKTOP_PATH" <<EOF
[Desktop Entry]
Name=Cursor
Exec="$CURSOR_FULL_PATH"
Terminal=false
# Icon="$CURSOR_DIR/cursor.png"
Icon=/usr/local/bin/cursor.png
Type=Application
Categories=Utility;Development;
EOF

rm -rf "$TMP_DIR"
echo "Installed cursor to $CURSOR_FULL_PATH"
echo "  - created a symlink at $CURSOR_BIN_PATH"
echo "  - created a desktop shortcut at $CURSOR_DESKTOP_PATH"

# #!/bin/bash

# set -euo pipefail

# # Directory setup
# APP_DIR="${HOME}/Applications"
# ICON_DIR="${HOME}/.local/share/icons"
# DESKTOP_DIR="${HOME}/.local/share/applications"
# BIN_DIR="${HOME}/.local/bin"

# # File paths
# DOWNLOAD_URL="https://downloader.cursor.sh/linux/appImage/x64"
# ICON_DOWNLOAD_URL="https://www.cursor.com/brand/icon.svg"
# APPIMAGE_NAME="cursor.AppImage"
# APPIMAGE_PATH="${APP_DIR}/${APPIMAGE_NAME}"
# ICON_PATH="${ICON_DIR}/cursor-icon.png"
# DESKTOP_FILE_PATH="${DESKTOP_DIR}/cursor.desktop"
# LAUNCHER_SCRIPT="${BIN_DIR}/cursor"

# # Utility functions
# log() { printf '%s\n' "$*"; }
# error() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# # Create necessary directories
# mkdir -p "${APP_DIR}" "${ICON_DIR}" "${DESKTOP_DIR}" "${BIN_DIR}"

# # Download the latest Cursor AppImage
# log "Downloading the latest Cursor AppImage..."
# curl -L "${DOWNLOAD_URL}" -o "${APPIMAGE_PATH}" || error "Failed to download Cursor AppImage"
# chmod +x "${APPIMAGE_PATH}"
# log "Downloaded and made executable: ${APPIMAGE_PATH}"

# # Download the Cursor icon if it doesn't exist
# if [ ! -f "${ICON_PATH}" ]; then
#   curl -sSo "${ICON_PATH}" "${ICON_DOWNLOAD_URL}" || error "Failed to download icon"
#   log "Downloaded logo to: ${ICON_PATH}"
# fi

# # Create or update the .desktop file
# cat > "${DESKTOP_FILE_PATH}" << EOF
# [Desktop Entry]
# Name=Cursor
# Exec=${LAUNCHER_SCRIPT} %F
# Terminal=false
# Type=Application
# Icon=${ICON_PATH}
# StartupWMClass=Cursor
# X-AppImage-Version=latest
# Comment=Cursor is an AI-first coding environment.
# MimeType=x-scheme-handler/cursor;
# Categories=Utility;Development
# EOF
# chmod +x "${DESKTOP_FILE_PATH}"
# log "Updated .desktop file at: ${DESKTOP_FILE_PATH}"

# # Create the launcher script
# cat > "${LAUNCHER_SCRIPT}" << EOF
# #!/bin/bash
# nohup ${APPIMAGE_PATH} "\$@" > ~/.cursor_log 2>&1 &
# EOF
# chmod +x "${LAUNCHER_SCRIPT}"
# log "Created launcher script: ${LAUNCHER_SCRIPT}"

# # Update the desktop database
# update-desktop-database "${DESKTOP_DIR}" || log "Failed to update desktop database. You may need to restart your session."

# # Update icon cache
# gtk-update-icon-cache -f -t ~/.local/share/icons || log "Failed to update icon cache. You may need to restart your session."

# log "Cursor has been successfully installed and updated."
# log "To run Cursor, you can now:"
# log "1. Look for 'Cursor' in your application launcher"
# log "2. Run it from the terminal with: cursor"
# log "3. Run it directly with: ${APPIMAGE_PATH}"
# log "You can also open files or directories with Cursor by using: cursor <file_or_directory>"
# log "You may need to log out and log back in for all changes to take effect."
# log "If you encounter any issues, check the ~/.cursor_log file for error messages."
