if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo kubeadm join 192.168.58.6:6443 --token dt0n3u.u8cg014jh2hszfu2 --discovery-token-ca-cert-hash sha256:87ce34c89210c06fb53176cc1ba8caabc1e8e572768f1aa5c5420ea8f36de454
	fi
	else exit 0
	fi
