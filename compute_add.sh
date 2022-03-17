if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo kubeadm join 192.168.58.6:6443 --token p4bd45.a1dizj25wiidz3hs --discovery-token-ca-cert-hash sha256:c4a9ffa476ac106925fa1e5191767800eabdfda91a2ad3f91e80fb9741c4e980
	fi
	else exit 0
fi
