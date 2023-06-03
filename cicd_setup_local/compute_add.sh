if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm join 192.168.58.6:6443 --token kunylf.q650h66wip8d4e9l --discovery-token-ca-cert-hash sha256:f53a1c4dfe172f0e25dcbe13a41d3362fbf63f64cb7875ed585eb7cd563d062c
	fi
	else exit 0
	fi
