#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Copy 03ceph.sh to node6
cat 03ceph.sh | vagrant ssh node6 -c 'sudo tee 03ceph.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy 03ceph.sh to node6."
fi

# Make 03ceph.sh executable on node6
vagrant ssh node6 -c 'sudo chmod +x 03ceph.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to make 03ceph.sh executable on node6."
fi

# Execute 03ceph.sh on node6
vagrant ssh node6 -c 'sudo ./03ceph.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute 03ceph.sh on node6."
fi
