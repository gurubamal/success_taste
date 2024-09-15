#!/bin/bash

if [ "$HOSTNAME" != "node4" ]; then
    if [ ! -e /etc/kubernetes/kubelet.conf ]; then
        sudo rm -f /etc/containerd/config.toml
        sudo systemctl restart containerd
        sudo systemctl enable containerd
        sudo swapoff -a
        sudo kubeadm join 192.168.56.4:6443 --token eq8ofg.jtng0t0fbfryaadj --discovery-token-ca-cert-hash sha256:421163a568f5c9517876f6516c253e867b2d9368f2e8c3d809907f447a2a1117 
    fi
else
    exit 0
fi
