#!/bin/bash
set -e

echo "Bootstrapping EC2 CRM API + Docker + MicroK8s"

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y unzip curl ca-certificates apt-transport-https

# -----------------------------
# Docker
# -----------------------------
if ! command -v docker &> /dev/null; then
  echo "Installing Docker ..."
  sudo apt-get install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
else
  echo "Docker already installed."
fi

# -----------------------------
# Docker Compose v2
# -----------------------------
if ! docker compose version &> /dev/null; then
  echo "Installing Docker Compose V2..."
  DOCKER_COMPOSE_DIR=/usr/local/lib/docker/cli-plugins
  sudo mkdir -p "$DOCKER_COMPOSE_DIR"
  sudo curl -L \
    "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o "$DOCKER_COMPOSE_DIR/docker-compose"
  sudo chmod +x "$DOCKER_COMPOSE_DIR/docker-compose"
  echo "Docker Compose V2 installed."
else
  echo "Docker Compose already installed."
fi

# -----------------------------
# AWS CLI v2
# -----------------------------
if ! command -v aws &> /dev/null; then
  echo "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip -q awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
else
  echo "AWS CLI already installed."
fi

# -----------------------------
# Docker group access
# -----------------------------
if ! groups $USER | grep -q '\bdocker\b'; then
  echo "Adding $USER to docker group..."
  sudo usermod -aG docker $USER
  echo "Logout and login again to apply docker group changes."
fi

# -----------------------------
# MicroK8s
# -----------------------------
if ! command -v microk8s &> /dev/null; then
  echo "Installing MicroK8s..."
  sudo snap install microk8s --classic
else
  echo "MicroK8s already installed."
fi

# Add user to microk8s group
if ! groups $USER | grep -q '\bmicrok8s\b'; then
  echo "Adding $USER to microk8s group..."
  sudo usermod -aG microk8s $USER
fi

# Fix kube config permissions
sudo chown -f -R $USER ~/.kube || true

# Wait for MicroK8s to be ready
echo "Waiting for MicroK8s to be ready..."
sudo microk8s status --wait-ready

# Enable common addons (safe defaults)
echo "Enabling MicroK8s addons..."
sudo microk8s enable dns storage ingress

# enable metrics-server (useful for HPA)
sudo microk8s enable metrics-server

# Alias kubectl for convenience
if ! grep -q "alias kubectl=" ~/.bashrc; then
  echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
fi

echo "--------------------------------------"
echo "EC2 Bootstrap completed successfully."
echo "Re-login required for group changes."
echo "Use: microk8s kubectl get nodes"
echo "--------------------------------------"
