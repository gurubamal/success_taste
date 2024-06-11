if ! [ $HOSTNAME = node4 ]; then
        if ! [ -e /etc/kubernetes/kubelet.conf ]; then
            sudo rm /etc/containerd/config.toml
            sudo systemctl restart containerd
            sudo systemctl enable containerd
            sudo swapoff -a
            sudo kubeadm join 192.168.56.4:6443 --token xt0pkz.n4hwq5omx9k3qdej --discovery-token-ca-cert-hash sha256:5539599614385f3cb9e1f6f0713f287ef709eead28a20f7d4c3aab3a40198bae
        fi
        else
            exit 0
        fi
