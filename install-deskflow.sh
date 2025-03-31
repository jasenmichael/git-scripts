#!/usr/bin/env bash

URL=https://github.com/deskflow/deskflow/releases/download/v1.21.0/deskflow-1.21.0-linux-x86_64.flatpak

echo "Installing Deskflow"



# Install dependencies
  sudo apt install cmake build-essential ninja-build \
              xorg-dev libx11-dev libxtst-dev libssl-dev \
              libglib2.0-dev libgdk-pixbuf-2.0-dev libnotify-dev \
              libxkbfile-dev qt6-base-dev qt6-tools-dev \
              libgtk-3-dev libgtest-dev libgmock-dev libpugixml-dev \
              libei-dev libportal-dev libtomlplusplus-dev libcli11-dev -y > /dev/null 2>&1

# Download the flatpak file
curl -L $URL -o deskflow.flatpak

# Install the flatpak file
if [ -t 0 ]; then
    # Running locally
    flatpak install deskflow.flatpak
    
else
    # Running via curl
    flatpak install deskflow.flatpak < /dev/tty
fi

rm deskflow.flatpak

echo "Deskflow installed"

