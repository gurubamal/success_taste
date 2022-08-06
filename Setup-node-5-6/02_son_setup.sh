#
apt-get update
#apt-get install -y docker-ce kubelet kubeadm kubectl
#
#
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sysctl -p
#usermod -aG docker vagrant
sudo swapoff /swap.img
sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
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
