Pre-requisites:

> Basic Linux Skills are expected

> Secure boot must be disabled from BIOS; also, virtualization should be enabled.

> Vagrant, VirtualBox, and git should be pre-installed

> Run the following commands from success_taste Directory:

    $ vagrant plugin install vagrant-vbguest

    $ gunzip ae2cae1d-d99d-491f-b862-71afb5d46c0b.*

    $ vagrant box add --name bento/ubuntu-20.04 ae2cae1d-d99d-491f-b862-71afb5d46c0b

    $ echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc

    $ chmod +x *.sh

NOTE: Most of the commands work in success_taste directory as the present working directory

> Download success_taste folder from google drive Link: 
https://drive.google.com/drive/folders/13L3BK8V3a6w5ET5Qacdevly4l8iGZ8ZQ

OR

https://drive.google.com/drive/folders/1ryF7vcrSj1B5Y4CT3LOzWdhwF4QKZRdF

Request Anshul Srivastava for access to this folder.

NOTE:You just need to run the above command once (you need not repeat them for the second time in the same environment).

####### SEC - A #########################

For sonarqube node installation:

1) In case you have run K8s installation steps recently, then rename Vagrantfile to Vagrantfile_k8s and also rename sonqube_Vagrantfile to Vagrantfile

2) run "vagrant up" for sonarqube installation now


>>sonarquube server should be ready within 30 minutes, depending on your internet connection.

Now use http://192.168.58.5:9000; use admin as user and admin as password.

NOTE: You can run any code scan for the latest vulnerabilities using the following command:
#sudo /home/vagrant/dependency-check/bin/dependency-check.sh --noupdate --prettyPrint --format HTML -scan ./<your project code>




######################### SEC - B #########################

Instructions for K8s Installation:

NOTE: if you have freshly downloaded the code and want to Install Kubernetes first, then go ahead with default Vagrantfile (it is for kubernetes already)


1) Switch to success_taste directory and ensure all scripts are executable already:
$chmod +x *.sh


2) If you are executing these steps after SEC - A (sonarqube installation), rename  Vagrantfile to sonqube_Vagrantfile; and then rename Vagrantfile_k8s to Vagrantfile 


3)  run “vagrant up”


4) ./final_touch.sh


Once you have completed the above commands, your Kubernetes cluster would be ready within the next 5 minutes.


######################### SEC - C #########################

Instructions for CIS security tools Installation:

for Kubei, Kube-bench and CIS scanning  use below script from success_taste directory on a functional kubernetes cluster:

./06.enable_kubei_kube-bench_nCIS_sec.sh


######################### SEC - D #########################

VAGRANT CLEAN UP:

To clean any previously implemented setup, use the below command:

$vagrant destroy

Ensure the right Vagrantfile for which you are running vagrant commands. Note that vagrant commands read  Vagrantfile for any of your sonarqube  actions.



