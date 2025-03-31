#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

if [ "$1" != "--reinstall" ]; then
  # exit if docker is already installed
  if [[ $(which docker) && $(docker --version) ]]; then
    echo "Docker already installed"
    echo "Use --reinstall to reinstall"
    exit 1
  fi
  echo "Installing Docker..."
else
  echo "Reinstalling Docker..."
fi

sleep 2

# https://docs.docker.com/engine/install/ubuntu/

is_ubuntu() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release

    if [[ "$ID_LIKE" == *"ubuntu"* || -z "${UBUNTU_CODENAME:-}" ]]; then
      return 0
    fi
  fi

  return 1
}

OS=$(is_ubuntu && echo "ubuntu" || echo "debian")

remove_docker_packages() {
  # remove old docker packages
  echo "## Removing old docker packages..."
  sudo apt-get remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc -y &>/dev/null || true
  # remove newer docker packages
  echo "## Removing newer docker packages..."
  sudo apt-get remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &>/dev/null || true
}

remove_docker_keys() {
  # remove any old keys
  echo "## Removing old keys..."
  sudo rm -f /etc/apt/keyrings/docker.asc &>/dev/null
  sudo rm -f /etc/apt/keyrings/docker.gpg &>/dev/null
  sudo rm -f /etc/apt/sources.list.d/docker.list &>/dev/null
}

install_docker_keys() {
  # Add Docker's official GPG key:
  echo "## Adding Docker's official GPG key..."
  sudo apt-get update -y
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL "https://download.docker.com/linux/$OS/gpg" -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
}

add_docker_repository() {
  # Add the repository to Apt sources:
  if is_ubuntu; then
    echo "## Adding Docker repository for Ubuntu..."
    # echo \
    #   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    # $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    #   sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  else
    echo "## Adding Docker repository for Debian..."
    # echo \
    #   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    # $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    #   sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  fi

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update
}

install_docker_packages() {
  echo "## Installing Docker packages..."
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

post_install() {
  echo "## Docker post installation..."
  sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
  sudo groupadd docker &>/dev/null || true
  sudo usermod -aG docker "$USER" &>/dev/null || true
  mkdir -p "$HOME/.docker" &>/dev/null || true
  sudo chown "$USER":"$USER" "$HOME/.docker" -R &>/dev/null || true
  sudo chmod g+rwx "$HOME/.docker" -R &>/dev/null || true
  echo "Added $USER to the docker group"
}

confirm_docker_installation() {
  #  check if docker installed
  if [[ $(which docker) && $(docker --version) ]]; then
    echo "## Docker installed successfully"
  else
    echo "## Docker installation failed"
    exit 1
  fi
}

# do it
remove_docker_packages &&
  remove_docker_keys &&
  install_docker_keys &&
  add_docker_repository &&
  install_docker_packages &&
  post_install &&
  confirm_docker_installation

echo "" &&
  docker --version &&
  docker compose version
