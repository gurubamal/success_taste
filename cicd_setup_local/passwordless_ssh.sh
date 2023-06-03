#!/bin/bash
sudo apt -y install sshpass
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
for i in 6 7 8 9
        do       sshpass -p vagrant ssh-copy-id vagrant@node$i 
		 sudo sshpass -p vagrant sudo ssh-copy-id root@node$i
done
