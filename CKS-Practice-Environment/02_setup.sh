#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
##wget https://packages.cloud.google.com/apt/doc/apt-key.gpg  --no-check-certificate
#sudo apt-key add apt-key.gpg
sudo sed -i '/swap/d' /etc/fstab
if ! grep net.bridge.bridge-nf-call-ip6tables /etc/sysctl.d/kubernetes.conf
then
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
fi
if ! grep br_netfilter /etc/modules-load.d/containerd.colternf
then	
sudo tee /etc/modules-load.d/containerd.colternf <<EOF
overlay
br_netfilter
EOF
fi
sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system
#add-apt-repository \
#"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#$(lsb_release -cs) \
#stable"
#
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#cat << EOF |  tee /etc/apt/sources.list.d/kubernetes.list
#deb https://apt.kubernetes.io/ kubernetes-Jammy main
#EOF
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-jammy main"
sudo apt install curl apt-transport-https -y
curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
#apt-get install -y  kubelet kubeadm kubectl
sudo apt install wget curl vim git kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
#sudo apt install -y containerd.io


# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
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

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# Configure persistent loading of modules
if ! grep overlay /etc/modules-load.d/k8s.conf
then
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
fi

# Ensure you load modules

# Set up required sysctl params
#sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#net.ipv4.ip_forward = 1
#EOF

# Configure persistent loading of modules

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter


# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start service
sudo su -
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

#containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
#sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
#sudo systemctl restart containerd
#sudo systemctl enable containerd
#
#
#echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
#sysctl -p
#usermod -aG docker vagrant
sudo swapoff -a
if ! grep "^#swap.img" /etc/fstab
then
sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
fi
#echo overlay br_netfilter|sudo tee -a  /etc/modules-load.d/containerd.conf
FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
    echo "$FILE exists."
else echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}'|sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload && sudo systemctl restart kubelet
fi

FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
    echo "$FILE exists."
else echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}'|sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload && sudo systemctl restart kubelet
fi

if ! grep native.cgroupdriver=systemd /etc/systemd/system/multi-user.target.wants/docker.service
then
	sudo systemctl stop docker
	sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
	sudo systemctl daemon-reload
	sudo systemctl daemon-reload && sudo systemctl restart kubelet
fi
sudo systemctl mask "dev-sda3.swap"
