#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository \
#"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#$(lsb_release -cs) \
#stable"
#
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#cat << EOF |  tee /etc/apt/sources.list.d/kubernetes.list
#deb https://apt.kubernetes.io/ kubernetes-xenial main
#EOF
apt-get update
#apt-get install -y docker-ce kubelet kubeadm kubectl
#
#
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sysctl -p
#usermod -aG docker vagrant
#sudo swapoff -a
#sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
#echo overlay br_netfilter|sudo tee -a  /etc/modules-load.d/containerd.conf  
#FILE=/etc/docker/daemon.json
#if test -f "$FILE"; then
#    echo "$FILE exists."
#else echo '{
#  "exec-opts": ["native.cgroupdriver=systemd"]
#}'|sudo tee /etc/docker/daemon.json
#sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
#fi

#FILE=/etc/docker/daemon.json
#if test -f "$FILE"; then
#    echo "$FILE exists."
#else echo '{
#  "exec-opts": ["native.cgroupdriver=systemd"]
#}'|sudo tee /etc/docker/daemon.json
#sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
#fi

#if ! grep native.cgroupdriver=systemd /etc/systemd/system/multi-user.target.wants/docker.service
#then
#	sudo systemctl stop docker
#	sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
#	sudo systemctl daemon-reload
#	sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
#fi
#echo -e "vagrant\nvagrant" | sudo passwd root
if  [ "$HOSTNAME" = node6 ]; then
	echo "Host node01
    Hostname node6
    User root
Host node02
    Hostname node7
    User root
Host node03
    Hostname node8
    User root" |sudo tee /root/.ssh/config
    sudo chmod 600 /root/.ssh/config
fi
if  test -f /root/.ssh/id_rsa
	then
	sudo ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
	else echo "All Set"
fi
apt update
apt -y install ceph sshpass



#if ! 192.168.58 /etc/hosts
#	then
#	echo 192.168.58.7        node7   node02| sudo tee -a /etc/hosts  
#	echo 192.168.58.8        node8   node03| sudo tee -a /etc/hosts 
#	echo 192.168.58.6        node6   node01| sudo tee -a /etc/hosts 
#	echo 192.168.58.5        node5 	controller| sudo tee -a /etc/hosts
#fi



#echo "127.0.0.1 localhost
#127.0.1.1 vagrant

# The following lines are desirable for IPv6 capable hosts
#::1     ip6-localhost ip6-loopback
#fe00::0 ip6-localnet
#ff00::0 ip6-mcastprefix
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
#192.168.58.7 node7 node02
#192.168.58.8 node8 node03
#192.168.58.6 node6 node01" |sudo tee /etc/hosts

#FILEX=/home/vagrant/x.txt
#if test -f "$FILEX"; then
#     echo "Password was reset already"
#else
#    echo -e "vagrant\nvagrant" | sudo passwd root ; touch $FILEX
#fi

if  [ "$HOSTNAME" = node6 ]; then
	UUID=$(uuidgen)
	echo "[global]
# specify cluster network for monitoring
cluster network = 192.168.58.0/24
# specify public network
public network = 192.168.58.0/24
# specify UUID genarated above
fsid = $UUID
# specify IP address of Monitor Daemon
mon host = 192.168.58.6
# specify Hostname of Monitor Daemon
mon initial members = node01
osd pool default crush rule = -1

# mon.(Node name)
[mon.node01]
# specify Hostname of Monitor Daemon
host = node01
# specify IP address of Monitor Daemon
mon addr = 192.168.58.6
# allow to delete pools
mon allow pool delete = true" |sudo tee /etc/ceph/ceph.conf
fi
#for NODE in node6 node7 node8
#	do sshpass -pvagrant ssh-copy-id root@$NODE
#done
