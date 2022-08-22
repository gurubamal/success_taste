if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.6:6443 --token a874ub.qdhegpl2x4m369sc --discovery-token-ca-cert-hash sha256:97362483b6742c804b092fb68d968eb526d29ddfaecc42339255cf53af79a11c
	fi
	else exit 0
	fi
