#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Copy SSH key to nodes
for NODE in node6 node7 node8; do
  sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no root@$NODE
  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy SSH key to $NODE."
  fi
done

# Create Ceph keyrings and import keys
ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/ceph/ceph.mon.keyring."
fi

ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/ceph/ceph.client.admin.keyring."
fi

ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /var/lib/ceph/bootstrap-osd/ceph.keyring."
fi

ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
if [ $? -ne 0 ]; then
  echo "Error: Failed to import /etc/ceph/ceph.client.admin.keyring into /etc/ceph/ceph.mon.keyring."
fi

ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
if [ $? -ne 0 ]; then
  echo "Error: Failed to import /var/lib/ceph/bootstrap-osd/ceph.keyring into /etc/ceph/ceph.mon.keyring."
fi

# Generate monitor map
FSID=$(grep "^fsid" /etc/ceph/ceph.conf | awk {'print $NF'})
NODENAME=$(grep "^mon initial" /etc/ceph/ceph.conf | awk {'print $NF'})
NODEIP=$(grep "^mon host" /etc/ceph/ceph.conf | awk {'print $NF'})
monmaptool --create --add $NODENAME $NODEIP --fsid $FSID /etc/ceph/monmap
if [ $? -ne 0 ]; then
  echo "Error: Failed to create monmap."
fi

# Create directory for Monitor Daemon
mkdir /var/lib/ceph/mon/ceph-node01
if [ $? -ne 0 ]; then
  echo "Error: Failed to create directory for Monitor Daemon."
fi

# Initialize Monitor Daemon
ceph-mon --cluster ceph --mkfs -i $NODENAME --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
if [ $? -ne 0 ]; then
  echo "Error: Failed to initialize Monitor Daemon."
fi

chown ceph. /etc/ceph/ceph.*
chown -R ceph. /var/lib/ceph/mon/ceph-node01 /var/lib/ceph/bootstrap-osd
if [ $? -ne 0 ]; then
  echo "Error: Failed to change ownership for Ceph files."
fi

systemctl enable --now ceph-mon@$NODENAME
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable and start ceph-mon@$NODENAME."
fi

# Enable Messenger v2 Protocol and Placement Groups auto scale module
ceph mon enable-msgr2
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable Messenger v2 Protocol."
fi

ceph mgr module enable pg_autoscaler
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable Placement Groups auto scale module."
fi

# Create directory for Manager Daemon
mkdir /var/lib/ceph/mgr/ceph-node01
if [ $? -ne 0 ]; then
  echo "Error: Failed to create directory for Manager Daemon."
fi

# Create auth key for Manager Daemon
ceph auth get-or-create mgr.$NODENAME mon 'allow profile mgr' osd 'allow *' mds 'allow *'
if [ $? -ne 0 ]; then
  echo "Error: Failed to create auth key for Manager Daemon."
fi

ceph auth get-or-create mgr.node01 | tee /etc/ceph/ceph.mgr.admin.keyring
if [ $? -ne 0 ]; then
  echo "Error: Failed to get or create auth key for mgr.node01."
fi

cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-node01/keyring
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy ceph.mgr.admin.keyring to /var/lib/ceph/mgr/ceph-node01."
fi

chown ceph. /etc/ceph/ceph.mgr.admin.keyring
chown -R ceph. /var/lib/ceph/mgr/ceph-node01
if [ $? -ne 0 ]; then
  echo "Error: Failed to change ownership for Ceph manager files."
fi

systemctl enable --now ceph-mgr@$NODENAME
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable and start ceph-mgr@$NODENAME."
fi

# Distribute Ceph configuration and keyrings to other nodes
for NODE in node01 node02 node03; do
  if [ ! ${NODE} = "node01" ]; then
    scp /etc/ceph/ceph.conf ${NODE}:/etc/ceph/ceph.conf
    if [ $? -ne 0 ]; then
      echo "Error: Failed to copy ceph.conf to $NODE."
    fi

    scp /etc/ceph/ceph.client.admin.keyring ${NODE}:/etc/ceph
    if [ $? -ne 0 ]; then
      echo "Error: Failed to copy ceph.client.admin.keyring to $NODE."
    fi

    scp /var/lib/ceph/bootstrap-osd/ceph.keyring ${NODE}:/var/lib/ceph/bootstrap-osd
    if [ $? -ne 0 ]; then
      echo "Error: Failed to copy bootstrap-osd keyring to $NODE."
    fi
  fi

  ssh $NODE "chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/*; \
              parted --script /dev/sdb 'mklabel gpt'; \
              parted --script /dev/sdb 'mkpart primary 0% 100%'; \
              ceph-volume lvm create --data /dev/sdb1"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Ceph on $NODE."
  fi
done

# Install and configure Ceph Dashboard
echo "password" > pass.txt
sudo apt -y install ceph-mgr-dashboard
if [ $? -ne 0 ]; then
  echo "Error: Failed to install ceph-mgr-dashboard."
fi

echo "Sleeping for 60s.., waiting for dashboard to be ready..."
sleep 60

ceph mgr module enable dashboard
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable dashboard module."
fi

ceph dashboard create-self-signed-cert
if [ $? -ne 0 ]; then
  echo "Error: Failed to create self-signed cert for dashboard."
fi

ceph dashboard ac-user-create ubuntu -i ./pass.txt administrator
if [ $? -ne 0 ]; then
  echo "Error: Failed to create dashboard user."
fi

ceph -s
ceph osd tree
ceph df
ceph osd df
ceph config set mon auth_allow_insecure_global_id_reclaim false
ceph mgr services
