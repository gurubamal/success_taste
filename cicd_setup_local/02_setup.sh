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

# Define versions
KUBERNETES_VERSION="v1.29.5"
KUBERNETES_BINARIES=("kubeadm" "kubelet" "kubectl")

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if Kubernetes binaries are installed
install_required=false
for binary in "${KUBERNETES_BINARIES[@]}"; do
    if ! command_exists "$binary"; then
        install_required=true
        break
    fi
done

if [ "$install_required" = true ]; then
    echo "Kubernetes binaries not found. Installing..."

    # Download Kubernetes binaries
    cd /tmp
    curl -LO "https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubeadm"
    curl -LO "https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubelet"
    curl -LO "https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl"

    # Make the binaries executable
    chmod +x kubeadm kubelet kubectl

    # Move binaries to /usr/local/bin
    sudo mv kubeadm kubelet kubectl /usr/local/bin/
else
    echo "Kubernetes binaries are already installed."
fi

# Check if kubelet service is available and running
if systemctl list-units --type=service --all | grep -q 'kubelet.service'; then
    echo "kubelet service already exists."
else
    echo "Creating kubelet systemd service..."

    # Create kubelet systemd service file
    cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Create kubelet service environment file
    sudo mkdir -p /etc/systemd/system/kubelet.service.d
    cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd"
ExecStart=
ExecStart=/usr/local/bin/kubelet \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF

    # Reload systemd, enable and start kubelet
    sudo systemctl daemon-reload
    sudo systemctl enable kubelet
    sudo systemctl start kubelet
fi

# Verify installations
echo "Verifying installations..."
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
