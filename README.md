NOTE:
Given CODE is working fine at the moment (when uploaded), it installs the latest version of everything. It is possible that later sonarqube or k8s versions may have massive changes in the code and installation method, and the code would need an update at that point in time!

Tutorial video:
https://youtu.be/BNnTaX3cR2k

Pre-requisites:

> Basic Linux Skills are expected

> On your hardware (laptop, desktop, server) Secure boot must be disabled from BIOS; also, virtualization should be enabled.

> Vagrant, VirtualBox, and git should be pre-installed

> It is expected that you are connected to internet 

> Run the following commands from success_taste Directory:

     vagrant plugin install vagrant-vbguest
 
> RUN below only if you are in Linux or Mac terminal:

     echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc

     chmod +x *.sh

NOTE: Most of the commands work in success_taste directory as the present working directory. Complete setup downloads packages from internet. 

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - compute node)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment). 

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

####### SEC - A #########################

For sonarqube node installation:

1) Rename sonqube_Vagrantfile to Vagrantfile

2) Run following for sonarqube installation now :
	
	vagrant up

>>sonarquube server should be ready within 30 minutes, depending on your internet connection.

Now use http://192.168.58.5:9000; use admin as user and admin as password.

NOTE: You can run any code scan for the latest vulnerabilities using the following command:
	
	sudo /home/vagrant/dependency-check/bin/dependency-check.sh --noupdate --prettyPrint --format HTML -scan ./<your project code>

######################### SEC - B #########################

Instructions for K8s Installation:

NOTE: if you have freshly downloaded the code and want to Install Kubernetes first, then go ahead with default Vagrantfile (it is for kubernetes already)


1) Switch to success_taste directory and ensure all scripts are executable already:
	
	chmod +x *.sh


2) If you are executing these steps after SEC - A (sonarqube installation), rename  Vagrantfile to sonqube_Vagrantfile; and then rename Vagrantfile_k8s to Vagrantfile 


3)  run :
	
	vagrant up

4) and then on your linux or mac terminal:

	./final_touch.sh

NOTE: in case you are using windows, instead of using ./final_touch.sh use  following command (FROM WINDOWS COMMANDLINE):
	
    vagrant ssh node6  -c '/vagrant/05_post_join_control.sh'
	
I have observed that script sometimes can return with issue in windows, so you can directly use following commands in node6 (ssh to node6 using "vagrant ssh node6" from you local machine):
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

VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

	vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile for any of your sonarqube  actions.



