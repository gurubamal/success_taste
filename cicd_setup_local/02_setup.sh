#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Remove swap entries from /etc/fstab
sudo sed -i '/swap/d' /etc/fstab

# Ensure sysctl parameters are set
if ! grep -q "net.bridge.bridge-nf-call-ip6tables" /etc/sysctl.d/kubernetes.conf; then
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
fi

# Ensure modules are loaded
if ! grep -q "br_netfilter" /etc/modules-load.d/containerd.conf; then
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
fi

# Load required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system

# Install necessary packages
sudo apt install curl apt-transport-https -y

# Add Kubernetes apt repository key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install Kubernetes packages
sudo apt-get update
sudo apt install -y wget curl vim git kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Add Docker repository and install Docker
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create Docker configuration directory
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create Docker daemon configuration file
if [ ! -f /etc/docker/daemon.json ]; then
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
fi

# Start and enable Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

# Configure persistent loading of modules
if ! grep -q "overlay" /etc/modules-load.d/k8s.conf; then
  sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
fi

# Load modules at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Reload sysctl configuration
sudo sysctl --system

# Install necessary packages again
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start the service
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

# Disable swap
sudo swapoff -a
if ! grep -q "^#swap.img" /etc/fstab; then
  sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
fi

# Create Docker daemon configuration file if it doesn't exist
if [ ! -f /etc/docker/daemon.json ]; then
  sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
fi

# Modify Docker service file if necessary
if ! grep -q "native.cgroupdriver=systemd" /etc/systemd/system/multi-user.target.wants/docker.service; then
  sudo systemctl stop docker
  sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet
fi

# Mask swap device
sudo systemctl mask "dev-sda3.swap"
