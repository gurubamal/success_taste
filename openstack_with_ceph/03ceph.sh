for NODE in node6 node7 node8
	do sshpass -pvagrant ssh-copy-id -o StrictHostKeyChecking=no  root@$NODE
done
ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
#creating /etc/ceph/ceph.mon.keyring
# generate secret key for Cluster admin
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
#creating /etc/ceph/ceph.client.admin.keyring
# generate key for bootstrap
ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
#creating /var/lib/ceph/bootstrap-osd/ceph.keyring
# import generated key
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
#importing contents of /etc/ceph/ceph.client.admin.keyring into /etc/ceph/ceph.mon.keyring
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
#importing contents of /var/lib/ceph/bootstrap-osd/ceph.keyring into /etc/ceph/ceph.mon.keyring
# generate monitor map
FSID=$(grep "^fsid" /etc/ceph/ceph.conf | awk {'print $NF'})
NODENAME=$(grep "^mon initial" /etc/ceph/ceph.conf | awk {'print $NF'})
NODEIP=$(grep "^mon host" /etc/ceph/ceph.conf | awk {'print $NF'})
monmaptool --create --add $NODENAME $NODEIP --fsid $FSID /etc/ceph/monmap
#monmaptool: monmap file /etc/ceph/monmap
#monmaptool: set fsid to 72840c24-3a82-4e28-be87-cf9f905918fb
#monmaptool: writing epoch 0 to /etc/ceph/monmap (1 monitors)
# create a directory for Monitor Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
mkdir /var/lib/ceph/mon/ceph-node01
# assosiate key and monmap to Monitor Daemon
# --cluster (Cluster Name)
ceph-mon --cluster ceph --mkfs -i $NODENAME --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
chown ceph. /etc/ceph/ceph.*
chown -R ceph. /var/lib/ceph/mon/ceph-node01 /var/lib/ceph/bootstrap-osd
systemctl enable --now ceph-mon@$NODENAME
# enable Messenger v2 Protocol
ceph mon enable-msgr2
# enable Placement Groups auto scale module
ceph mgr module enable pg_autoscaler
# create a directory for Manager Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
mkdir /var/lib/ceph/mgr/ceph-node01
# create auth key
ceph auth get-or-create mgr.$NODENAME mon 'allow profile mgr' osd 'allow *' mds 'allow *'

#[mgr.node01]
#        key = AQC3IEZfESetLhAA/rnFCLkpvopkARxyLKLJAA==

ceph auth get-or-create mgr.node01 | tee /etc/ceph/ceph.mgr.admin.keyring
cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-node01/keyring
chown ceph. /etc/ceph/ceph.mgr.admin.keyring
chown -R ceph. /var/lib/ceph/mgr/ceph-node01
systemctl enable --now ceph-mgr@$NODENAME

for NODE in node01 node02 node03
do
    if [ ! ${NODE} = "node01" ]
    then
        scp /etc/ceph/ceph.conf ${NODE}:/etc/ceph/ceph.conf
        scp /etc/ceph/ceph.client.admin.keyring ${NODE}:/etc/ceph
        scp /var/lib/ceph/bootstrap-osd/ceph.keyring ${NODE}:/var/lib/ceph/bootstrap-osd
    fi
    ssh $NODE \
    "chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/*; \
    parted --script /dev/sdc 'mklabel gpt'; \
    parted --script /dev/sdc "mkpart primary 0% 100%"; \
    ceph-volume lvm create --data /dev/sdc1"
done
#ceph config set mon auth_allow_insecure_global_id_reclaim false
echo password > pass.txt
apt -y install ceph-mgr-dashboard
echo "Sleeping for 60s.., waiting for dashboard to be ready........"
sleep 60
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
ceph dashboard ac-user-create ubuntu -i ./pass.txt administrator
ceph -s
ceph osd tree
ceph df
ceph osd df
ceph config set mon auth_allow_insecure_global_id_reclaim false
ceph mgr services
