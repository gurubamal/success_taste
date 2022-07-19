if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.6:6443 --token fizlg9.539zxdux03g2ujrd --discovery-token-ca-cert-hash sha256:dd5f3db51a9d1647df0a35a2684417cde112a2f1839a00d373d9bd7c7870a2da
	fi
	else exit 0
	fi
