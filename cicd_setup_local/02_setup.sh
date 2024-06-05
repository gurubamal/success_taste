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

# Install Kubernetes packages
# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl wget vim git gnupg2 software-properties-common

# Function to install Kubernetes binaries directly
install_k8s_binaries() {
    echo "Attempting to install Kubernetes binaries directly..."
    cd /usr/local/bin
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubeadm"
    sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubelet"

    if [ -f kubectl ] && [ -f kubeadm ] && [ -f kubelet ]; then
        sudo chmod +x /usr/local/bin/kubectl /usr/local/bin/kubeadm /usr/local/bin/kubelet
        echo "Direct download and installation of Kubernetes binaries successful."
        kubectl version --client && kubeadm version && kubelet --version
    else
        echo "Direct download failed. Falling back to package installation..."
        install_k8s_packages
    fi
}

# Function to install Kubernetes packages using apt
install_k8s_packages() {
    echo "Attempting to install Kubernetes packages via apt..."
    sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    if command -v kubectl >/dev/null && command -v kubeadm >/dev/null && command -v kubelet >/dev/null; then
        echo "Package installation of Kubernetes tools successful."
        kubectl version --client && kubeadm version && kubelet --version
    else
        echo "Package installation of Kubernetes tools failed."
        exit 1
    fi
}

# Try direct download first, fall back to package installation if needed
install_k8s_binaries

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
