#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Copy rceph_final.sh to node6
cat rceph_final.sh | vagrant ssh node6 -c 'sudo tee rceph_final.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy rceph_final.sh to node6."
fi

# Make rceph_final.sh executable on node6
vagrant ssh node6 -c 'sudo chmod +x rceph_final.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to make rceph_final.sh executable on node6."
fi

# Execute rceph_final.sh on node6
vagrant ssh node6 -c 'sudo ./rceph_final.sh'
if [ $? -ne 0 ]; then
  echo "Error: Failed to execute rceph_final.sh on node6."
fi
