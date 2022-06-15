#!/usr/bin/env bash

set -x
set -o

source /root/admin-openrc.sh

# Create avi specific user, project and role
#openstack user create --password-prompt --description 'Avi Admin user' aviuser
openstack user create --password guru123 --description 'Avi Admin user' aviuser
openstack role create aviadmin
openstack project create --description 'Avi LBaaS Project' avilbaas

# Avi avi user Avi role in avi project; configure policy files in keystone,
# nova, neutron and glance
openstack role add --project avilbaas --user aviuser aviadmin
openstack role assignment list --user aviuser --names

# Add reader role in demo tenant (test demo tenant in provider mode)
openstack role add --project demo --user aviuser aviadmin
openstack role assignment list --user aviuser --names
