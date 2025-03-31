#!/usr/bin/env bash

set -e

if command -v curl 2>/dev/null; then
  sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
elif command -v wget 2>/dev/null; then
  sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)
else
  echo "curl or wget not found"
  exit 1
fi

if ! command -v nordvpn &>/dev/null; then
  echo "Failed to install nordvpn"
  exit 1
fi

sudo usermod -aG nordvpn "$USER" >/dev/null

echo "Installed nordvpn!"
echo "Run: nordvpn login"
echo "then nordvpn connect"

nordvpn --version
