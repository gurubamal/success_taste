#!/usr/local/bin/bash

echo $(cat join.info|grep kubeadm |cut -d'\' -f1) $(cat join.info |grep discovery-token-ca-cert-hash| cut -d"[" -f1) |tee compute_add.sh

chmod +x compute_add.sh
