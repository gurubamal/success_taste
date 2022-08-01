#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
wget https://packages.cloud.google.com/apt/doc/apt-key.gpg  --no-check-certificate
sudo apt-key add apt-key.gpg
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF |  tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker-ce kubelet kubeadm kubectl
#
#
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sysctl -p
usermod -aG docker vagrant
sudo swapoff -a
sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
echo overlay br_netfilter|sudo tee -a  /etc/modules-load.d/containerd.conf  
FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
    echo "$FILE exists."
else echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}'|sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
fi

FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
    echo "$FILE exists."
else echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}'|sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
fi

if ! grep native.cgroupdriver=systemd /etc/systemd/system/multi-user.target.wants/docker.service
then
	sudo systemctl stop docker
	sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
	sudo systemctl daemon-reload
	sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
fi
