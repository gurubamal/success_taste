if ! [ $HOSTNAME = node7 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.7:6443 --token bj2fnr.gzlw20r39kh5a8ru --discovery-token-ca-cert-hash sha256:be3fafc8ef83a8a20b9bcd09f3ff9dffad21bf684882d03a0514ca1f48c56d27
	fi
	else exit 0
	fi
