
sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
sudo apt -y install nova-compute nova-compute-kvm

echo "# add follows (enable VNC)
[vnc]
enabled = True
server_listen = 0.0.0.0
server_proxyclient_address = controller
novncproxy_base_url = http://controller:6080/vnc_auto.html "|sudo tee -a /etc/nova/nova.conf

sudo systemctl restart nova-compute

sudo su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"

#openstack compute service list


