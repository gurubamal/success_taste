#!/bin/bash

# Remove swap
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Ensure bridge network settings
if ! grep -q net.bridge.bridge-nf-call-ip6tables /etc/sysctl.d/kubernetes.conf; then
    sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
fi

# Load necessary kernel modules
if ! grep -q br_netfilter /etc/modules-load.d/containerd.conf; then    
    sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
fi

sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker repository and key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt-get update
sudo apt-get install -y containerd.io docker-ce docker-ce-cli

# Create Docker configuration
sudo mkdir -p /etc/systemd/system/docker.service.d
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

# Start and enable Docker
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# Configure persistent loading of modules
if ! grep -q overlay /etc/modules-load.d/k8s.conf; then
    sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
fi

# Reload sysctl settings
sudo sysctl --system

# Add Kubernetes repository and key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl wget vim git gnupg2 software-properties-common

# Remove the specific repository file
sudo rm -f /etc/apt/sources.list.d/home:alvistack.list

# Remove the corresponding GPG key
sudo apt-key del 4BECC97550D0B1FD

# Update package list
sudo apt-get update

# Remove duplicate Docker repository entries
sudo rm -f /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_ubuntu-jammy.list
sudo apt-get update

# Install snapd
sudo apt-get install -y snapd

# Install kubectl, kubeadm, and kubelet using snap
sudo snap install kubectl --classic
sudo snap install kubeadm --classic
sudo snap install kubelet --classic

# Verify installations
kubectl version --client
kubeadm version
kubelet --version

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Check containerd status
sudo systemctl status containerd

# Additional configurations for Docker
FILE=/etc/docker/daemon.json
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' | sudo tee /etc/docker/daemon.json
    sudo systemctl daemon-reload && sudo systemctl restart kubelet
fi

if ! grep -q native.cgroupdriver=systemd /etc/systemd/system/multi-user.target.wants/docker.service; then
    sudo systemctl stop docker
    sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo systemctl restart kubelet
fi

# Mask swap partition (only if it exists)
if [ -e /dev/sda3.swap ]; then
    sudo systemctl mask "dev-sda3.swap"
fi
