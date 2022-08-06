#

if ! grep 192.168.58 /etc/hosts
        then
        echo 192.168.58.7        node7   node02| sudo tee -a /etc/hosts
        echo 192.168.58.8        node8   node03| sudo tee -a /etc/hosts
        echo 192.168.58.6        node6   node01| sudo tee -a /etc/hosts
        echo 192.168.58.9        node9  controller| sudo tee -a /etc/hosts
fi

if ! grep "PasswordAuthentication yes" /etc/ssh/sshd_config
        then
        sudo sed -i "s/\#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
        echo "PasswordAuthentication yes" |sudo tee -a  /etc/ssh/sshd_config
        sudo sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
fi

if ! grep "PermitRootLogin yes" /etc/ssh/sshd_config
        then
		echo "PermitRootLogin yes" |sudo tee -a /etc/ssh/sshd_config
fi

if ! grep "StrictHostKeyChecking no" /etc/ssh/ssh_config
        then
		echo "StrictHostKeyChecking no" |sudo tee -a /etc/ssh/ssh_config
fi

sudo systemctl restart ssh

FILEX=/home/vagrant/x.txt
if test -f "$FILEX"; then
     echo "Password was reset already"
else
    echo -e "vagrant\nvagrant" | sudo passwd root ; touch $FILEX
fi
