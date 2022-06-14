  git clone https://github.com/avinetworks/openstack-installer.git
     ip a s
     cd openstack-installer/
    ls
    cd wallaby/
    ls
    vi installer.sh 
    sed 's/ens3/enp0s8/s' installer.sh 
    sed 's/ens3/enp0s8/g' installer.sh 
   sed -i 's/ens3/enp0s8/g' installer.sh 
   vi installer.sh 
   ./installer.sh 
   vi installer.sh 
   ifconfig 
   sed -i 's/ens4/enp0s9/g' installer.sh 
   ./installer.sh 
   ls
    mkdir /root/files
   cd ..
   mv wallaby/*.* /root/files/.
   cd /root/files/
   ls
   ./installer.sh 
   sudo apt install software-properties-common
   ./installer.sh 
   echo $?
   cat ./installer.sh 
   cat ./installer.sh |grep horizon
   cat ./installer.sh |grep -i dash
   sed -i 's/ens4/enp0s9/g'  custom-post-install.sh
  









apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top 
  vi /etc/netplan/50-vagrant.yaml 
  netplan apply 
  sudo reboot 
  ip r s
  apt -y install nova-compute nova-compute-kvm qemu-system-data 
  vi  /etc/nova/nova.conf
  chgrp nova /etc/nova/nova.conf 
  source admin-openrc.sh 
  openstack compute service list 
