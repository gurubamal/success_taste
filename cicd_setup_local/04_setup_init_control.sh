#ssh to node6 and run below command, it will generate compute_add.sh file which provides  join command that you need to run on node7 and node8 and later you need to execute 04_post_join_control.sh on node6 as final command:
if ! [ "$HOSTNAME" = node6 ]; then
	exit 0
fi

# Function to check if kubelet is running, identify its ports, and kill the process
check_and_kill_kubelet() {
    if pgrep -x "kubelet" > /dev/null; then
        echo "Kubelet is running. Checking the ports it is using..."
        # Find the ports used by kubelet
        sudo lsof -i -P -n | grep kubelet | grep LISTEN
        # Get the PID of kubelet
        PID=$(pgrep -x "kubelet")
        if [ -n "$PID" ]; then
            echo "Killing kubelet process with PID $PID..."
            sudo kill -9 $PID
            echo "Process $PID killed."
        else
            echo "No process found for kubelet."
        fi
    else
        echo "Kubelet is not running."
    fi
}

# Function to stop kubelet service
stop_kubelet_service() {
    echo "Stopping kubelet service..."
    sudo systemctl stop kubelet
    echo "Kubelet service stopped."
}

# Check and kill kubelet if running
check_and_kill_kubelet

# Stop kubelet service
stop_kubelet_service

echo "Kubelet process and service have been stopped."

# Update package list
sudo apt-get update

# Install socat and conntrack
sudo apt-get install -y socat conntrack
sudo kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers --kubernetes-version 1.28.0
# Install crictl
CRICTL_VERSION="v1.24.1"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
rm crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

# Verify installations
echo "Verifying installations..."
if ! command -v socat &> /dev/null; then
    echo "socat installation failed."
else
    echo "socat installed successfully."
fi

if ! command -v conntrack &> /dev/null; then
    echo "conntrack installation failed."
else
    echo "conntrack installed successfully."
fi

if ! command -v crictl &> /dev/null; then
    echo "crictl installation failed."
else
    echo "crictl installed successfully."
fi

echo "All required dependencies have been installed."

if [ "$HOSTNAME" = node6 ]; then
	if ! [ -e /etc/kubernetes/pki/ca.crt ]
	then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
	sudo kubeadm init --apiserver-advertise-address=192.168.58.6 --kubernetes-version v1.25.0 --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all |tee init.txt ; echo sudo $(tail -2 init.txt|head -1| cut -d'\' -f1)  $(tail -1 init.txt| cut -d'[' -f1) |tee -a  compute_add.sh
	JOIN_CMD=$(cat compute_add.sh)
	echo   "if ! [ $HOSTNAME = node6 ]; then
	if ! [ -e /etc/kubernetes/kubelet.conf ] ; then
	sudo rm /etc/containerd/config.toml
	sudo systemctl restart containerd
	sudo systemctl enable containerd
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
