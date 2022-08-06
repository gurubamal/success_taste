if ! [ $HOSTNAME = node5 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.5:6443 --token qesudx.qyg2owtx0t4dmio3 --discovery-token-ca-cert-hash sha256:d2f7d34bf6b589ddaefc7b91ea9f59547b35f456df92cf02575f2b53c8735352
	fi
	else exit 0
	fi
