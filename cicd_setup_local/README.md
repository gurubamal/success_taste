NOTE:
While CODE is currently working fine, it installs the latest version of everything. However, it is possible that future software versions may have significant changes to the code or installation method. In such cases, CODE may need to be updated.


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

NOTE: Most of the commands work in success_taste/cicd_setup_local directory as the present working directory. Complete setup downloads packages from internet. 

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - Jenkins Node,  192.168.58.9 - Jenkins anisble Controller)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment). 

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

You can get in touch with me at : gurubamal@gmail.com



######################### JENKINS SETUP #########################

Instructions for Jenkins Installation:

1) Switch to success_taste/cicd_setup_local directory and ensure all scripts are executable already:
	
		chmod +x *.sh

2)  Run :
	
		cp Vagrantfile_jenkins_node8 Vagrantfile
	
		vagrant up 
	
	Browse jenkins at 
		http://192.168.58.8:8080
	Fetch password with following command:
		sudo cat /var/lib/jenkins/secrets/initialAdminPassword
	
######################### K8S SETUP #########################

Instructions for K8s Installation:

1) Switch to success_taste/cicd_setup_local directory and ensure all scripts are executable already:
	
		chmod +x *.sh

2)  Run : 
	
		cp Vagrantfile_k8s_node6n7  Vagrantfile
	
		vagrant up 
	
		ssh vagrant@192.168.58.6 (password = vagrant)
	
	check kubectl commands
	
NOTE 1: node6 will be master node whereas node7 will be worker node

NOTE 2: please note that following info "value: "interface=eth1"  in calico.yaml was set by me because my Virtualbox VMs are aquiring eth1 as default network device with IP 192.168.58.x for my VMs. You need to set it in case it's eth name varies in your machines. you can leave it as it is if it works all great already.

######################### Ansible SETUP #########################

Instructions for Ansible Installation:

1) Switch to success_taste/cicd_setup_local directory and ensure all scripts are executable already:
	
		chmod +x *.sh

2)  Run :
	
		cp Vagrantfile_ansible_node9  Vagrantfile
	
		vagrant up 
	
		ssh vagrant@192.168.58.9 (password = vagrant)
	
	check ansible commands



	
VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

	vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile. You may have to copy or Rename right Vagrant file to ensure your VMs are removed properly (vagrant command only acts on current Vagrantfile)



