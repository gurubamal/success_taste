import subprocess

def run_command(command):
    subprocess.run(command, shell=True, check=True)

def is_entry_in_file(entry, file_path):
    with open(file_path, 'r') as file:
        return entry in file.read()

# Check if 192.168.56 is in /etc/hosts and add entries if not present
host_entries = [
    '192.168.56.4        node4   node04',
    '192.168.56.5        node5   node05',
    '192.168.56.6        node6   node06',
    '192.168.56.7        node7   node07'
]

hosts_file = '/etc/hosts'
if not any('192.168.56' in entry for entry in host_entries if is_entry_in_file(entry, hosts_file)):
    for entry in host_entries:
        run_command(f'echo {entry} | sudo tee -a {hosts_file}')

# Update sshd_config for PasswordAuthentication
sshd_config_file = '/etc/ssh/sshd_config'
if is_entry_in_file('PasswordAuthentication no', sshd_config_file):
    run_command("sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config")

# Check and update PermitRootLogin
if not is_entry_in_file('PermitRootLogin yes', sshd_config_file):
    run_command('echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config')

# Check and update StrictHostKeyChecking in ssh_config
ssh_config_file = '/etc/ssh/ssh_config'
if not is_entry_in_file('StrictHostKeyChecking no', ssh_config_file):
    run_command('echo "StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config')

# Restart SSH service
run_command('sudo systemctl restart ssh')

# Uncomment and adjust as needed for mounting vagrant or appending IP to /etc/hosts
# run_command('echo "vagrant /vagrant vboxsf uid=1000,gid=1000,_netdev 0 0" | sudo tee -a /etc/fstab')
# IP = subprocess.check_output("ip r s|grep 10.0.3|awk '{print $NF}'|cut -d'.' -f4", shell=True).decode().strip()
# run_command(f'echo "$IP node$(hostname)" | sudo tee -a /etc/hosts')
