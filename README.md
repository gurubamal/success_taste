NOTE:
Given CODE (only with instructions below) is working fine now (when uploaded), it installs the latest version of everything. In future, if software versions get significant changes or updates in the code, these scripts would also need updates. 

NOTE: Following is just for hands-on and learning practicals. In production, you will have to follow security practices in scripts and implementations (which is not applicable in these practicals).


Tutorial videos:  (I intend to make (upload) some youtube videos on "practicals on container security" and "k8 network made simple" with hands-on practice examples once I complete some of my urgent work successfully)

https://www.youtube.com/watch?v=Hqkujcop3NE&t=5s

Pre-requisites:

> Basic Linux Skills are expected

> On your hardware (laptop, desktop, server) Secure boot must be disabled from BIOS; also, virtualization should be enabled.

> Vagrant, VirtualBox (On Windows 10 - use VirtualBox version 5.4.2 only), and git should be pre-installed (restart device once after virtual box install).
> Ensure your device doesn't go to sleep when it's idle (while scripts are running), change power, battery settings whereever applicable

> NOTE (for re-setup): Ensure you have given full-control to your users on success_taste directory as vagrant script will create second disk for each VM on it, also, run virtual box as administrator to see current VMs as you are running power shell (and then vagrant commands) as Administrator. to clean-up a previously ran vagrant up setup - delete VMs (either via vagrant up or manually, also in case you delete VMs manually, delete vdi files from directory where you ran vagrant up and also delete .vagrant folder from same directory. Also, when doing cleanup, check "C:\Users\<Your User name>\VirtualBox VMs" for any folders that should be deleted as VMs are created there by default. In case you get issue "VBOX_E_FILE_ERROR" or error related to VDI; you can comment lines 25.26.27.28,29, and 30 in your Vagrantfile to disable additional disk creation.

> On Windows 10 - use VirtualBox version 5.4.2 only, for best fuctionality in windows follow and set environment : https://www.vagrantup.com/docs/other/wsl; optionally, You can use Powershell and run below commands (must be administrator) on powershell:
		
		vagrant plugin update
		
		vagrant plugin install vagrant-vbguest 

> Run the all the vagarant commands from success_taste Directory (clone it using: git clone https://github.com/gurubamal/success_taste.git)

     vagrant plugin install vagrant-vbguest
 
> RUN below only if you are in Linux or Mac terminal:

     echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc

     chmod +x *.sh

NOTE: Most of the commands work in success_taste directory as the present working directory. Complete setup downloads packages from internet. 

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - compute node)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment). 

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

You can get in touch with me at : gurubamal@gmail.com

########################

NOTE: For "Openstack with ceph setup practical" use "https://github.com/gurubamal/success_taste/blob/main/openstack_with_ceph/README.md"

############# SEC - A - CEPH (v15) MULTINODE Install#########################

NOTE: If you are here for k8s setup then use ###### SEC - B ####  mentioned next 

CEPH (v15) MULTINODE VMS Install SETUP:

1) Rename Vagrantfile.ceph to Vagrantfile in success_taste directory and make all scripts executable
     	
2) Now run the below commands:

	vagrant up 
	
	./ceph_final_touch.sh

If it gets interrupted, it will be some issue at your end (scripts are already ok tested); check for its output; it is either a resources issue in your device or vagrant related most of the time. You can re-run commands if it looks intermittent. 

3)  Post setup Ceph Dashboard "https://192.168.58.6:8443/#/dashboard" will be available 
	"ubuntu will be user and password will be password"
5)  Setup install node6 (acts as node01, admin+mon node), node7 (acts as osd node02) and node8 (acts as osd node03)  

NOTE: All ceph commands will need sudo privileges. Scripts creates & uses "/dev/sdc" in each node (while installation) for ceph storage pool 

NOTE (For WINDOWS Hosts):
If you are running "vagrant up" in windows, then you need to ssh to node6 (vagrant ssh node6) and then execute "sudo bash /vagrant/03ceph.sh" once to setup ceph


######################### SEC - B K8s Multinode Install #########################

Instructions for K8s Installation:

1) Switch to success_taste directory and ensure all scripts are executable already:
	
	chmod +x *.sh


2) Rename or copy (i.e. use cp or mv commands) Vagrantfile_k8s to Vagrantfile 


3)  Run :
	
	vagrant up 
	
	./final_touch.sh 

once commands are executed, go to vagrant@192.168.58.6 (password is vagrant) and check pods if calico and coredns are running or not. use command: 
	kubectl get pods -A -w
			

NOTE: I have observed that script (2nd command "vagrant ssh node6  -c '/vagrant/05_post_join_control.sh'" ) sometimes can have issue in windows, so you can directly use following commands in node6 (ssh to node6 using "vagrant ssh node6" from you local machine):
RUN FOLLOWING IN node6 COMMANDLINE:

	sudo mkdir -p /home/vagrant/.kube
	sudo chown vagrant:vagrant /home/vagrant/.kube
	sudo mkdir -p /root/.kube
	sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
	sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
	sudo chown vagrant:vagrant  /home/vagrant/.kube/config
	kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
	
	
In case you want to practice k8s network-policies use (weave-net instead of flannel) : 
	kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

NOTE : If it gets interrupted, it will be some issue at your end (scripts are already ok tested); check for its output; it is either a resources issue in your device or vagrant related most of the time. You can re-run commands if it looks intermittent. 

 (Rest for next 3-5 minutes after all commands; Once you have completed the above commands, your Kubernetes cluster would be ready.
 
 IMPORTANT_NOTE: I have observed that if all nodes stay in not-ready for more than 5 minutes then it is only if network plugin image was not pulled from internet (may be they keep it down for some updates), in that case delete existing net-plugin deployment and respective pods and deploy alternative network plugin from node6:
 
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml



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

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile for any of your vagrant actions.



