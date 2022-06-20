if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.6:6443 --token xhefw2.wm5kp2m8rle44rzk --discovery-token-ca-cert-hash sha256:017e7ce8788cd9adc7245d50a965f5a1306d904efceaed4743979bc6e872febc
	fi
	else exit 0
	fi
