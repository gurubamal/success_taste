IP=$(ip r s|grep 192.168.58|awk '{print $NF}')
hostnamectl set-hostname node$(ip r s|grep 192.168.58|awk '{print $NF}'|cut -d"." -f4)
#

if ! 192.168.58 /etc/hosts
        then
        echo 192.168.58.7        node7   node02| sudo tee -a /etc/hosts
        echo 192.168.58.8        node8   node03| sudo tee -a /etc/hosts      
        echo 192.168.58.6        node6   node01| sudo tee -a /etc/hosts
        echo 192.168.58.9        node9  controller| sudo tee -a /etc/hosts
fi

sudo sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config

if ! grep "PermitRootLogin yes" /etc/ssh/sshd_config
	then echo "PermitRootLogin yes" |sudo tee -a /etc/ssh/sshd_config
fi
if ! grep "StrictHostKeyChecking no" /etc/ssh/ssh_config
        then echo "StrictHostKeyChecking no" |sudo tee -a /etc/ssh/ssh_config
fi
sudo systemctl restart ssh
#echo "vagrant /vagrant vboxsf uid=1000,gid=1000,_netdev 0 0" |sudo tee -a /etc/fstab
#
#echo "$IP node$(ip r s|grep 10.0.3|awk '{print $NF}'|cut -d"." -f4)" |tee -a /etc/hosts
