#ssh to node6 and run below command, it will generate compute_add.sh file which provides  join command that you need to run on node7 and node8 and later you need to execute 04_post_join_control.sh on node6 as final command:
if ! [ "$HOSTNAME" = node5 ]; then
	exit 0
fi

if [ "$HOSTNAME" = node5 ]; then
	if ! [ -e /etc/kubernetes/pki/ca.crt ]
	then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	echo 'apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.58.5
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: node5
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: cluster1
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: 1.24.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 192.168.0.0/12
scheduler: {}'> cluster1.conf

        kubeadm init  --config cluster1.conf  |tee init.txt ; echo sudo $(tail -2 init.txt|head -1| cut -d'\' -f1)  $(tail -1 init.txt| cut -d'[' -f1) |tee -a  compute_add.sh
	JOIN_CMD=$(cat compute_add.sh)
	echo   "if ! [ $HOSTNAME = node5 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	$JOIN_CMD
	fi
	else exit 0
	fi" |tee  compute_add.sh
	sed 's/node5 = node5/\$HOSTNAME = node5/g' compute_add.sh |tee /vagrant/compute_add.sh	
	chmod +x /vagrant/*.sh
	else exit 0
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
