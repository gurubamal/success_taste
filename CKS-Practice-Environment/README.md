NOTE:
Given CODE is working fine at the moment (when uploaded), it installs the latest version of everything. It is possible that later sonarqube or k8s versions may have massive changes in the code and installation method, and the code would need an update at that point in time!


Pre-requisites:

> Basic Linux Skills are expected

> On your hardware (laptop, desktop, server) Secure boot must be disabled from BIOS; also, virtualization should be enabled. 24GB system RAM is expected

> Vagrant, VirtualBox, and git should be pre-installed (restart device once after virtual box install)

> It is expected that you are connected to internet 

> Run the all the commands from success_taste Directory (clone it using: git clone https://github.com/gurubamal/success_taste.git)

     vagrant plugin install vagrant-vbguest
 
> RUN below only if you are in Linux or Mac terminal:

     echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc

     chmod +x *.sh

NOTE: Most of the commands work in success_taste directory as the present working directory. Complete setup downloads packages from internet. 

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - compute node)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment). 

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

You can get in touch with me at : gurubamal@gmail.com



######################### Kubernetes with Ceph HA #########################

Instructions for K8s Installation:

1) Switch to success_taste directory and ensure all scripts are executable already:
	
	chmod +x *.sh

2)  Run :
	
	vagrant up 
	
	./final_touch.sh             #You need to wait for cluster to be ready, Check nodes and pods for verification after this script  
	
	./final_r_ceph_touch.sh      #It sets up rook ceph cluster -ready to use 
	
	
	

NOTE: I have observed that script (2nd command "vagrant ssh node6  -c '/vagrant/05_post_join_control.sh'" ) sometimes can have issue in windows, so you can directly use following commands in node6 (ssh to node6 using "vagrant ssh node6" from you local machine):
RUN FOLLOWING IN node6 COMMANDLINE:

	sudo mkdir -p /home/vagrant/.kube
	sudo chown vagrant:vagrant /home/vagrant/.kube
	sudo mkdir -p /root/.kube
	sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
	sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
	sudo chown vagrant:vagrant  /home/vagrant/.kube/config
	kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml


 (Rest for next 3-5 minutes after all commands; Once you have completed the above commands, your Kubernetes cluster would be ready.

t code>


######################### SEC - C #########################

VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

	vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile for any of your sonarqube  actions.



