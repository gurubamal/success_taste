#!/usr/bin/env bash

set -x
set -e

export LC_ALL=C

if [[ "$1" == "DISABLE" ]]; then
    echo "DISABLING AVI OS POLICIES..."
    sed -e "/^policy_file/ s/policy_file/# policy_file/g" -i /etc/keystone/keystone.conf
    sed -e "/^policy_file/ s/policy_file/# policy_file/g" -i /etc/nova/nova.conf
    sed -e "/^policy_file/ s/policy_file/# policy_file/g" -i /etc/neutron/neutron.conf
else
    echo "ENABLING AVI OS POLICIES..."
    sed -e "/^# policy_file/ s/# policy_file/policy_file/g" -i /etc/keystone/keystone.conf
    sed -e "/^# policy_file/ s/# policy_file/policy_file/g" -i /etc/nova/nova.conf
    sed -e "/^# policy_file/ s/# policy_file/policy_file/g" -i /etc/neutron/neutron.conf
fi

apache2ctl restart
service nova-api restart
service neutron-server restart
