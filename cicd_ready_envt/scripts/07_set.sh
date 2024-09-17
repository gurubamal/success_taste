#!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

#sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd.io -o Dpkg::Options::="--force-confnew" 2> /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd.io -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd

KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.31.1-1 kubeadm=1.31.1-1 kubectl=1.31.1-1
sudo apt-mark hold kubelet kubeadm kubectl

sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock

sudo tee /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS='--node-ip $(ip -4 addr show enp0s8 | grep "inet" | head -1 | awk '{print $2}' | cut -d/ -f1)'
EOF

# Step 1: Prepare your system
echo "Loading necessary kernel modules..."
if [ ! -f /etc/modules-load.d/containerd.conf ]; then
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
  sudo modprobe overlay
  sudo modprobe br_netfilter
else
  echo "Kernel modules already configured."
fi

echo "Applying sysctl params without reboot..."
if [ ! -f /etc/sysctl.d/k8s.conf ]; then
  sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
  sudo sysctl --system
else
  echo "Sysctl parameters already set."
fi

# Step 2: Install Containerd
echo "Setting up the Docker repository and installing containerd..."
if ! dpkg-query -W -f='${Status}' containerd.io 2>/dev/null | grep -q "ok installed"; then
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  #sudo apt-get install -y containerd.io
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containerd.io -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  echo "Configuring containerd to use systemd as the cgroup driver..."
  sudo mkdir -p /etc/containerd
  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
  sudo systemctl restart containerd
  sudo systemctl enable containerd
else
  echo "Containerd is already installed and configured."
fi

# Step 3: Add Kubernetes Repositories
echo "Adding Kubernetes repositories..."
add_repo_and_install() {
  local repo_url=$1
  echo "deb [trusted=yes] $repo_url kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet=1.31.1-1 kubeadm=1.31.1-1 kubectl=1.31.1-1
  sudo apt-mark hold kubelet kubeadm kubectl
}

install_kubernetes_components() {
  sudo apt-get install -y kubelet=1.31.1-1 kubeadm=1.31.1-1 kubectl=1.31.1-1
  sudo apt-mark hold kubelet kubeadm kubectl
}

try_install_kubernetes() {
  add_repo_and_install "http://apt.kubernetes.io/"
  if ! command -v kubectl &>/dev/null || ! command -v kubeadm &>/dev/null || ! command -v kubelet &>/dev/null; then
    echo "Trying alternative repository..."
    add_repo_and_install "http://mirrors.aliyun.com/kubernetes/apt/"
    if ! command -v kubectl &>/dev/null || ! command -v kubeadm &>/dev/null || ! command -v kubelet &>/dev/null; then
      echo "Trying another alternative repository..."
      add_repo_and_install "https://raw.githubusercontent.com/kubernetes/release/master/debian"
    fi
  fi
}

try_install_kubernetes

echo "Verifying Kubernetes component installation..."
if command -v kubectl &>/dev/null && command -v kubeadm &>/dev/null && command -v kubelet &>/dev/null; then
  echo "Kubernetes components are correctly installed."
else
  echo "Kubernetes installation failed!"
fi
