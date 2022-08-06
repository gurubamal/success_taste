#RUN on controlnode:
>~/.ssh/known_hosts

for i in 6 7 8
	do
	sshpass -f password.txt  ssh-copy-id -o StrictHostKeyChecking=no vagrant@10.0.3.$i
done
