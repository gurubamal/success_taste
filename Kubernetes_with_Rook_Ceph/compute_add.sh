#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Check if not on node6 and if kubelet.conf does not exist
if ! [ "$HOSTNAME" = "node6" ]; then
  if ! [ -e /etc/kubernetes/kubelet.conf ]; then
    sudo rm /etc/containerd/config.toml
    if [ $? -ne 0 ]; then
      echo "Error: Failed to remove /etc/containerd/config.toml."
    fi

    sudo systemctl restart containerd
    if [ $? -ne 0 ]; then
      echo "Error: Failed to restart containerd."
    fi

    sudo systemctl enable containerd
    if [ $? -ne 0 ]; then
      echo "Error: Failed to enable containerd."
    fi

    sudo kubeadm join 192.168.58.6:6443 --token xhefw2.wm5kp2m8rle44rzk --discovery-token-ca-cert-hash sha256:017e7ce8788cd9adc7245d50a965f5a1306d904efceaed4743979bc6e872febc
    if [ $? -ne 0 ]; then
      echo "Error: Failed to join Kubernetes cluster."
    fi
  fi
else
  exit 0
fi
