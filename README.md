NOTE:
Currently, the provided code is functioning all well, showcasing its flawless ability to install the most up-to-date revisions of all components. It is of paramount importance to acknowledge that software versions are susceptible to substantial advancements in both code structure and installation procedures as time progresses. Consequently, it becomes imperative to meticulously scrutinize the code and effectuate any essential enhancements to guarantee seamless compatibility with forthcoming upgrades.

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

NOTE: Most of the commands work in success_taste directory or respective setup Directory as the present working directory. Complete setup downloads packages from internet. 

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - compute node)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment). 

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

You can get in touch with me at : gurubamal@gmail.com

################

	
VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

	vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile. You may have to copy or Rename right Vagrant file to ensure your VMs are removed properly (vagrant command only acts on current Vagrantfile)





