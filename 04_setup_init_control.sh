#ssh to node6 and run below command, it will generate compute_add.sh file which provides  join command that you need to run on node7 and node8 and later you need to execute 04_post_join_control.sh on node6 as final command:
if ! [ "$HOSTNAME" = node6 ]; then
	exit 0
fi

if [ "$HOSTNAME" = node6 ]; then
	if ! [ -e /etc/kubernetes/pki/ca.crt ]
	then
	sudo kubeadm init --apiserver-advertise-address=192.168.58.6 --pod-network-cidr=10.244.0.0/16 |tee init.txt ; echo sudo $(tail -2 init.txt|head -1| cut -d'\' -f1)  $(tail -1 init.txt| cut -d'[' -f1) |tee compute_add.sh
	JOIN_CMD=$(cat compute_add.sh)
	echo   "if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	$JOIN_CMD
	fi
	else exit 0
	fi" |tee  compute_add.sh
	sed 's/node6 = node6/\$HOSTNAME = node6/g' compute_add.sh |tee /vagrant/compute_add.sh	
	chmod +x /vagrant/*.sh
	else exit 0
	fi
fi
#JOIN_CMD=$(cat compute_add.sh)
#echo "if ! [ "$HOSTNAME" = node6 ]; then
#$JOIN_CMD
#fi" |tee  compute_add.sh
#chmod +x compute_add.sh
#sed 's/node6 = node6/\$HOSTNAME = node6/g' compute_add.sh |tee /vagrant/compute_add.sh
#rm  join.info
#sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16
#sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16
#sudo -i vagrant
#mkdir -p ~/.kube
#sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
#sudo chown vagrant:vagrant  /home/vagrant/.kube/config
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
