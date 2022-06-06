DRIVE=sdb
MYNODEIP=192.168.58.5

(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo w # Write changes
) | sudo fdisk /dev/$DRIVE

sudo pvcreate /dev/$DRIVE1

sudo vgcreate -s 32M vg_volume01 /dev/$DRIVE1
sudo apt -y install targetcli-fb

sudo sed -i 's/enabled_backends =/enabled_backends = lvm/g' /etc/cinder/cinder.conf

echo "
# add to the end
[lvm]
target_helper = lioadm
target_protocol = iscsi
# IP address of Storage Node
target_ip_address = $MYNODEIP
# volume group name created on [1]
volume_group = vg_volume01
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volumes_dir = $state_path/volumes" |sudo tee -a /etc/cinder/cinder.conf

sudo systemctl restart cinder-volume


echo "
# add to the end
[cinder]
os_region_name = RegionOne" | sudo tee -a /etc/nova/nova.conf


echo "export OS_VOLUME_API_VERSION=3" |sudo tee -a  ~/keystonerc
source ~/keystonerc

