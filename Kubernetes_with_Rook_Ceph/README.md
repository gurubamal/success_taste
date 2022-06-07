NOTE:
Given CODE is working fine at the moment (when uploaded), it installs the latest version of everything. It is possible that later sonarqube or k8s versions may have massive changes in the code and installation method, and the code would need an update at that point in time!

Tutorial videos:

Part 1  - https://youtu.be/BNnTaX3cR2k

Part 2 (final) - https://youtu.be/UJlWT4wgpSw

Pre-requisites:

> Basic Linux Skills are expected

> On your hardware (laptop, desktop, server) Secure boot must be disabled from BIOS; also, virtualization should be enabled.

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

############# SEC - A - CEPH (v15) MULTINODE Install#########################

NOTE: If you are here for k8s setup then use ###### SEC - B ####  mentioned next 

CEPH (v15) MULTINODE VMS Install SETUP:

1) Rename Vagrantfile.ceph to Vagrantfile in success_taste directory
2) Now run the below commands:

    vagrant up ; ./ceph_final_touch.sh

3)  Post setup Dashboard "https://192.168.58.6:8443/#/dashboard" will be available "ubuntu will be user and password will be password"
4)  Setup install node6 (acts as node01, admin+mon node), node7 (acts as osd node02) and node8 (acts as osd node03)  

NOTE: All ceph commands will need sudo privileges. Scripts creates & uses "/dev/sdb" in each node (while installation) for ceph storage pool 

NOTE (For WINDOWS Hosts):
If you are running "vagrant up" in windows, then you need to ssh to node6 (vagrant ssh node6) and then execute "sudo bash /vagrant/03ceph.sh" once to setup ceph


######################### SEC - B K8s Multinode Install #########################

Instructions for K8s Installation:

1) Switch to success_taste directory and ensure all scripts are executable already:
	
	chmod +x *.sh


2) Rename or copy (i.e. use cp or mv commands) Vagrantfile_k8s to Vagrantfile 


3)  Run :
	
	vagrant up ; ./final_touch.sh
	

NOTE: I have observed that script (2nd command "vagrant ssh node6  -c '/vagrant/05_post_join_control.sh'" ) sometimes can have issue in windows, so you can directly use following commands in node6 (ssh to node6 using "vagrant ssh node6" from you local machine):
RUN FOLLOWING IN node6 COMMANDLINE:

	sudo mkdir -p /home/vagrant/.kube
	sudo chown vagrant:vagrant /home/vagrant/.kube
	sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
	sudo chown vagrant:vagrant  /home/vagrant/.kube/config
	kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml


 (Rest for next 3-5 minutes after all commands; Once you have completed the above commands, your Kubernetes cluster would be ready.


######################### SEC - C #########################

Instructions for CIS security tools Installation:

for Kubei, Kube-bench and CIS scanning  use below script from success_taste directory on a functional kubernetes cluster:

	./06.enable_kubei_kube-bench_nCIS_sec.sh

######################### SEC - D #########################

Instructions for  Istio service mesh Installation:

Use below script from success_taste directory on a functional kubernetes cluster:

	./istio_install.sh

You will find kiali services will be running at http://192.168.58.6:31000/ ,  test fleet management app will be availabe at http://192.168.58.6:30080/ & Jaeger will be availabe at http://192.168.58.6:31001

NOTE: It is best if you set Memory for k8s nodes to 4GB for istio setup (you can use Vagrantfile.istio as default Vagrantfile as an example)

######################### SEC - E #########################

For sonarqube node installation:

1) Rename sonqube_Vagrantfile to Vagrantfile

2) Run following for sonarqube installation now :
	
	vagrant up

>>sonarquube server should be ready within 30 minutes, depending on your internet connection.

Now use http://192.168.58.5:9000; use admin as user and admin as password.

NOTE: You can run any code scan for the latest vulnerabilities using the following command:
	
	sudo /home/vagrant/dependency-check/bin/dependency-check.sh --noupdate --prettyPrint --format HTML -scan ./<your project code>


######################### SEC - F #########################

VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

	vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile for any of your sonarqube  actions.


