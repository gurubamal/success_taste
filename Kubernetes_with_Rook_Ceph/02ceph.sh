#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker GPG key."
fi

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker repository."
fi

# Add Kubernetes GPG key and repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes GPG key."
fi

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes repository to sources list."
fi

# Update package lists and install Docker and Kubernetes packages
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt-get install -y docker-ce kubelet kubeadm kubectl
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Docker and Kubernetes packages."
fi

# Configure sysctl
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
if [ $? -ne 0 ]; then
  echo "Error: Failed to update /etc/sysctl.conf."
fi

sudo sysctl -p
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply sysctl settings."
fi

# Add vagrant user to docker group
sudo usermod -aG docker vagrant
if [ $? -ne 0 ]; then
  echo "Error: Failed to add vagrant user to docker group."
fi

# Disable swap
sudo swapoff -a
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable swap."
fi

sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
if [ $? -ne 0 ]; then
  echo "Error: Failed to comment out swap.img in /etc/fstab."
fi

# Load required kernel modules
echo overlay br_netfilter | sudo tee -a /etc/modules-load.d/containerd.conf
if [ $? -ne 0 ]; then
  echo "Error: Failed to configure kernel modules."
fi

# Configure Docker daemon
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
  sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd and restart Docker and Kubelet."
  fi
fi

if ! grep -q "native.cgroupdriver=systemd" /etc/systemd/system/multi-user.target.wants/docker.service; then
  sudo systemctl stop docker
  sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Docker to use systemd as the cgroup driver."
  fi
  sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd and restart Docker and Kubelet after configuration."
  fi
fi

# Reset root password
echo -e "vagrant\nvagrant" | sudo passwd root
if [ $? -ne 0 ]; then
  echo "Error: Failed to reset root password."
fi

# Configure SSH for node6
if [ "$HOSTNAME" = "node6" ]; then
  echo "Host node01
    Hostname node6
    User root
Host node02
    Hostname node7
    User root
Host node03
    Hostname node8
    User root" | sudo tee /root/.ssh/config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure SSH for node6."
  fi
  sudo chmod 600 /root/.ssh/config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set permissions on /root/.ssh/config."
  fi
fi

# Generate SSH key if not exists
if [ ! -f /root/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
  if [ $? -ne 0 ]; then
    echo "Error: Failed to generate SSH key."
  fi
else
  echo "SSH key already exists."
fi

# Update and install Ceph and sshpass
sudo apt update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt -y install ceph sshpass
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Ceph and sshpass."
fi

# Update /etc/hosts if necessary
if ! grep -q "192.168.58" /etc/hosts; then
  {
    echo "192.168.58.7        node7   node02"
    echo "192.168.58.8        node8   node03"
    echo "192.168.58.6        node6   node01"
    echo "192.168.58.5        node5   controller"
  } | sudo tee -a /etc/hosts > /dev/null

  if [ $? -ne 0 ]; then
    echo "Error: Failed to update /etc/hosts."
  fi
fi

# Reset root password if not already done
FILEX=/home/vagrant/x.txt
if test -f "$FILEX"; then
  echo "Password was reset already."
else
  echo -e "vagrant\nvagrant" | sudo passwd root
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reset root password."
  else
    touch $FILEX
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create x.txt to indicate password reset."
    fi
  fi
fi

# Configure Ceph if on node6
if [ "$HOSTNAME" = "node6" ]; then
  UUID=$(uuidgen)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to generate UUID."
  fi

  echo "[global]
# specify cluster network for monitoring
cluster network = 192.168.58.0/24
# specify public network
public network = 192.168.58.0/24
# specify UUID generated above
fsid = $UUID
# specify IP address of Monitor Daemon
mon host = 192.168.58.6
# specify Hostname of Monitor Daemon
mon initial members = node01
osd pool default crush rule = -1

# mon.(Node name)
[mon.node01]
# specify Hostname of Monitor Daemon
host = node01
# specify IP address of Monitor Daemon
mon addr = 192.168.58.6
# allow to delete pools
mon allow pool delete = true" | sudo tee /etc/ceph/ceph.conf
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Ceph."
  fi
fi

# Uncomment the following block to copy SSH keys to other nodes if needed
# for NODE in node6 node7 node8; do
#   sshpass -p vagrant ssh-copy-id root@$NODE
#   if [ $? -ne 0 ]; then
#     echo "Error: Failed to copy SSH key to $NODE."
#   fi
# done
