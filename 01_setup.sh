IP=$(ip r s|grep 192.168.58|awk '{print $NF}')
sudo hostnamectl set-hostname node$(ip r s|grep 192.168.58|awk '{print $NF}'|cut -d"." -f4)
#
echo 192.168.58.7        node7 | tee -a /etc/hosts  
echo 192.168.58.8        node8 | tee -a /etc/hosts 
echo 192.168.58.6        node6 | tee -a /etc/hosts 

sudo sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh
#echo "vagrant /vagrant vboxsf uid=1000,gid=1000,_netdev 0 0" |sudo tee -a /etc/fstab
#
#echo "$IP node$(ip r s|grep 10.0.3|awk '{print $NF}'|cut -d"." -f4)" |tee -a /etc/hosts
