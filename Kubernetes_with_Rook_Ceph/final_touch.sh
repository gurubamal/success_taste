#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Copy 05_post_join_control.sh to node6
cat 05_post_join_control.sh | vagrant ssh node6 -c 'sudo tee 05_post_join_control.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy 05_post_join_control.sh to node6."
  exit 1
fi

# Make 05_post_join_control.sh executable on node6
vagrant ssh node6 -c 'sudo chmod +x 05_post_join_control.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to make 05_post_join_control.sh executable on node6."
  exit 1
fi

# Execute 05_post_join_control.sh on node6
vagrant ssh node6 -c 'sudo ./05_post_join_control.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute 05_post_join_control.sh on node6."
  exit 1
fi

# Apply Calico network plugin on node6
vagrant ssh node6 -c 'kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml'
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply Calico network plugin on node6."
  exit 1
fi
