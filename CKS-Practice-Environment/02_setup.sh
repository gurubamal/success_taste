#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Remove swap entries from /etc/fstab
sudo sed -i '/swap/d' /etc/fstab
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove swap entries from /etc/fstab."
fi

# Ensure sysctl parameters are set
if ! grep -q "net.bridge.bridge-nf-call-ip6tables" /etc/sysctl.d/kubernetes.conf; then
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set sysctl parameters."
  fi
fi

# Ensure modules are loaded
if ! grep -q "br_netfilter" /etc/modules-load.d/containerd.conf; then
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
  if [ $? -ne 0 ]; then
    echo "Error: Failed to load kernel modules."
  fi
fi

# Load required kernel modules
sudo modprobe overlay
if [ $? -ne 0 ]; then
  echo "Error: Failed to load overlay module."
fi

sudo modprobe br_netfilter
if [ $? -ne 0 ]; then
  echo "Error: Failed to load br_netfilter module."
fi

sudo sysctl --system
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply sysctl parameters."
fi

# Install necessary packages
sudo apt install curl apt-transport-https -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to install curl and apt-transport-https."
fi

# Add Kubernetes apt repository key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes apt repository key."
fi

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes repository to sources list."
fi

# Update and install Kubernetes packages
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt install wget curl vim git kubelet kubeadm kubectl -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Kubernetes packages."
fi

sudo apt-mark hold kubelet kubeadm kubectl
if [ $? -ne 0 ]; then
  echo "Error: Failed to hold Kubernetes packages."
fi

# Add Docker repository and install Docker
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
if [ $? -ne 0 ]; then
  echo "Error: Failed to install required packages for Docker."
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker GPG key."
fi

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker repository."
fi

sudo apt update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list after adding Docker repository."
fi

sudo apt install -y containerd.io docker-ce docker-ce-cli
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Docker."
fi

# Create Docker configuration directory
sudo mkdir -p /etc/systemd/system/docker.service.d
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/systemd/system/docker.service.d directory."
fi

# Create Docker daemon configuration file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/docker/daemon.json."
fi

# Start and enable Docker service
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
  echo "Error: Failed to reload systemd daemon."
fi

sudo systemctl restart docker
if [ $? -ne 0 ]; then
  echo "Error: Failed to restart Docker service."
fi

sudo systemctl enable docker
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable Docker service."
fi

# Configure persistent loading of modules
if ! grep -q "overlay" /etc/modules-load.d/k8s.conf; then
  sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure persistent loading of modules."
  fi
fi

# Load modules at runtime
sudo modprobe overlay
if [ $? -ne 0 ]; then
  echo "Error: Failed to load overlay module at runtime."
fi

sudo modprobe br_netfilter
if [ $? -ne 0 ]; then
  echo "Error: Failed to load br_netfilter module at runtime."
fi

# Reload sysctl parameters
sudo sysctl --system
if [ $? -ne 0 ]; then
  echo "Error: Failed to reload sysctl parameters."
fi

# Install additional required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
if [ $? -ne 0 ]; then
  echo "Error: Failed to install additional required packages."
fi

# Remove containerd.io if installed
sudo apt -y remove containerd.io
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove containerd.io."
fi

# Install Docker and containerd.io
sudo apt install -y docker.io
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Docker.io."
fi

sudo apt -y autoremove
if [ $? -ne 0 ]; then
  echo "Error: Failed to autoremove unnecessary packages."
fi

# Configure containerd and start the service
sudo mkdir -p /etc/containerd
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/containerd directory."
fi

containerd config default | sudo tee /etc/containerd/config.toml
if [ $? -ne 0 ]; then
  echo "Error: Failed to configure containerd."
fi

sudo systemctl restart containerd
if [ $? -ne 0 ]; then
  echo "Error: Failed to restart containerd service."
fi

sudo systemctl enable containerd
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable containerd service."
fi

systemctl status containerd
if [ $? -ne 0 ]; then
  echo "Error: containerd service is not running properly."
fi

# Disable swap
sudo swapoff -a
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable swap."
fi

if ! grep -q "^#swap.img" /etc/fstab; then
  sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
  if [ $? -ne 0 ]; then
    echo "Error: Failed to comment out swap.img in /etc/fstab."
  fi
fi

# Check and configure Docker daemon
FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
  echo "$FILE exists."
else
  echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' | sudo tee /etc/docker/daemon.json
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create /etc/docker/daemon.json."
  fi
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd and restart kubelet."
  fi
fi

# Ensure Docker uses systemd as the cgroup driver
if ! grep -q "native.cgroupdriver=systemd" /etc/systemd/system/multi-user.target.wants/docker.service; then
  sudo systemctl stop docker
  sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Docker to use systemd as the cgroup driver."
  fi
fi

# Mask swap device
sudo systemctl mask "dev-sda3.swap"
if [ $? -ne 0 ]; then
  echo "Error: Failed to mask swap device."
fi
