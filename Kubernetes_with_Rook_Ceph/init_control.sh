ansible -i hosts control  -u vagrant  -a "sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16" |tee init.txt ; echo sudo $(tail -2 init.txt|head -1| cut -d'\' -f1)  $(tail -1 init.txt| cut -d'[' -f1) |tee compute_add.sh
