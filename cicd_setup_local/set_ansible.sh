#!/bin/bash
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update  -y
sudo apt install ansible -y
sudo apt -y install ansible-core ansible --allow-change-held-packages
echo "[servers]
node6 ansible_host=192.168.58.6
node7 ansible_host=192.168.58.7
node8 ansible_host=192.168.58.8
node9 ansible_host=192.168.58.9

[all:vars]
ansible_python_interpreter=/usr/bin/python3" | sudo tee /etc/ansible/hosts
#sudo apt -y install expect
#ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1

#for i in 6 7 8
#       do      /vagrant/login_expect  node$i
#done
sudo apt update
sudo apt -y remove containerd.io
sudo apt -y install docker.io
sudo apt -y autoremove
Sudo mkdir /etc/docker/registry
echo "version: 0.1
storage:
  filesystem:
    rootdirectory: /var/lib/registry
"   |sudo tee  /etc/docker/registry/config.yml
sudo usermod -aG docker vagrant
sudo systemctl unmask docker.service
sudo systemctl enable docker.service
sudo systemctl start docker.service

docker run -d -p 5000:5000 --restart=always --name registry registry:2
docker ps
