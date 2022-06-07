source  ~/keystonerc
sudo mkdir -p /var/kvm/images
wget http://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img -P /var/kvm/images
sudo modprobe nbd
sudo qemu-nbd --connect=/dev/nbd0 /var/kvm/images/ubuntu-20.04-server-cloudimg-amd64.img
sudo  mount /dev/nbd0p1 /mnt
sudo  sed -i '13i ssh_pwauth: true' /mnt/etc/cloud/cloud.cfg 
sudo sudo sed -i 's/lock_passwd\:\ True/lock_passwd\:\ False/g'  /mnt/etc/cloud/cloud.cfg
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd0p1
openstack image create "Ubuntu2004" --file /var/kvm/images/ubuntu-20.04-server-cloudimg-amd64.img --disk-format qcow2 --container-format bare --public
openstack image list
