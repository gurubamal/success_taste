
set -x

# # explicitly set locale to avoid any pip install issues
export LC_ALL=C
# clone avi-heat
cd /root
git clone $HEAT_REPO
cd avi-heat
git checkout $HEAT_BRANCH
python setup.py sdist
pip install dist/*tar.gz

sed -i '1 a plugin_dirs = "/usr/local/lib/python2.7/dist-packages/avi/heat"' /etc/heat/heat.conf

pkill -9 heat-engine
service heat-engine start


source /root/admin-openrc.sh
openstack service create  --name avi --description "Avi LBaaS" avi-lbaas
openstack endpoint create --region RegionOne avi-lbaas public https://${AVI_IP}/api
