NOTE: Given CODE (only with instructions below) is working fine now (when uploaded), it installs the latest version of everything. In future, if software versions get significant changes or updates in the code, these scripts would also need updates.

NOTE: Following is just for hands-on and learning practicals. In production, you will have to follow security in scripts and implementations (which is not applicable in these practicals).

Pre-requisites:

    Basic Linux Skills are expected

    On your hardware (laptop, desktop, server) Secure boot must be disabled from BIOS; also, virtualization should be enabled.

    Vagrant, VirtualBox, and git should be pre-installed (restart device once after virtual box install)

    It is expected that you are connected to internet

    Run the all the commands from success_taste Directory (clone it using: git clone https://github.com/gurubamal/success_taste.git)

 vagrant plugin install vagrant-vbguest

    RUN below only if you are in Linux or Mac terminal:

 echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc

 chmod +x *.sh

NOTE: Most of the commands work in success_taste directory as the present working directory. Complete setup downloads packages from internet.

NOTE: Linux admin User (with sudo perms) & password will be vagrant (password is vagrant as well) (K8s VM IPs : 192.168.58.6 - master node/ 192.168.58.7 - compute node / 192.168.58.8 - compute node)

NOTE: You just need to run the above commands once (you need not repeat them for the second time in the same environment).

NOTE: In each section, It can take upto 30-60 minutes of time to run it completely (based on your internet speed).

You can get in touch with me at : gurubamal@gmail.com

############# Openstack (Wallaby) with Ceph - (Glance as an example) Install#########################

CEPH (v15) MULTINODE VMS Install SETUP:

   Switch directory to success_taste/openstack_with_ceph/

    Now run the below commands:

    vagrant up

    ./ceph_final_touch.sh
    
    ./ostack_final.sh

and then login to node7 using "vagrant ssh node7" and run following commands:

      sudo -i
      /root/openstack_final.sh
      

Script will configure openstack that can be accessed from http://192.168.58.7/horizon using user - admin | password - avi123  | Domain  - default

You would be able to see that glance has been confirgured by the script to make use of ceph storage as an example already. it can be checked at:
https://192.168.58.6:8443/#/block/rbd (ceph storage dashboard)

    Post setup ceph storage Dashboard "https://192.168.58.6:8443/#/dashboard" will be available "ubuntu will be user and password will be password"
    Setup install node6 (acts as node01, admin+mon node), node7 (acts as osd node02) and node8 (acts as osd node03)

NOTE: All ceph commands will need sudo privileges. Scripts creates & uses "/dev/sdc" in each node (while installation) for ceph storage pool

If it gets interrupted, it will be some issue at your end (scripts are already ok tested); check for its output; it is either a resources issue in your device or vagrant related most of the time. You can re-run commands if it looks intermittent.


NOTE (For WINDOWS Hosts): If you are running "vagrant up" in windows, then you need to ssh to node6 (vagrant ssh node6) and then execute "sudo bash /vagrant/03ceph.sh" once to setup ceph
