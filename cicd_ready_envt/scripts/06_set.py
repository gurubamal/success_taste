import os
import subprocess
import sys
import site

def install_package(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", package])

def import_or_install(package):
    try:
        __import__(package)
    except ImportError:
        install_package(package)
        __import__(package)

# Ensure the user's site-packages directory is in the sys.path
sys.path.append(site.getusersitepackages())

import_or_install('paramiko')
import paramiko

# Password for sshpass
password_file = ".txtpwd"

# Write the password to the .txtpwd file (equivalent to echo vagrant > .txtpwd)
pxt = "vagrant"
with open(password_file, 'w') as file:
    file.write(pxt)
print(f"Password written to {password_file}")

# Function to read the password from the .txtpwd file
def read_password(file_path):
    with open(file_path, 'r') as file:
        return file.read().strip()

# Read the password from the .txtpwd file
if not os.path.exists(password_file):
    print(f"Password file {password_file} not found.")
    exit(1)

PASSWORD = read_password(password_file)

# Ensure the script runs only on node4
hostname = os.uname().nodename
if hostname != "node4":
    print("This script should only be run on node4")
    exit(1)

# Check if Ansible is installed, if not, install it
try:
    subprocess.run(["ansible", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print("Ansible is already installed.")
except subprocess.CalledProcessError:
    print("Ansible is not installed. Installing Ansible...")
    subprocess.run(["sudo", "apt-get", "update"], check=True)
    subprocess.run(["sudo", "apt-get", "install", "-y", "ansible", "sshpass"], check=True)

# Remote nodes
hosts = ["node4", "node5", "node6"]

# Generate and copy SSH keys
def generate_ssh_key_on_remote(host, password):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, username='vagrant', password=password)

    stdin, stdout, stderr = ssh.exec_command('if [ ! -f ~/.ssh/id_rsa ]; then ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa; fi')
    stdout.channel.recv_exit_status()  # Wait for the command to complete
    ssh.close()

def copy_ssh_key_to_remote(host, password):
    subprocess.run(["sshpass", "-p", password, "ssh-copy-id", "-o", "StrictHostKeyChecking=no", f"vagrant@{host}"], check=True)

def check_ssh_connection(host, password):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, username='vagrant', password=password)

    stdin, stdout, stderr = ssh.exec_command("echo 'SSH setup complete on '$(hostname)")
    print(stdout.read().decode().strip())
    ssh.close()

def update_ansible_hosts_file(hosts):
    ansible_hosts_path = "/etc/ansible/hosts"
    temp_file = "/tmp/ansible_hosts_temp"

    with open(temp_file, "w") as hosts_file:
        with open(ansible_hosts_path, "r") as original_file:
            hosts_file.write(original_file.read())
        for host in hosts:
            hosts_file.write(f"{host} ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa\n")

    subprocess.run(["sudo", "mv", temp_file, ansible_hosts_path], check=True)

for host in hosts:
    print(f"Processing {host}")
    generate_ssh_key_on_remote(host, PASSWORD)
    copy_ssh_key_to_remote(host, PASSWORD)
    check_ssh_connection(host, PASSWORD)

update_ansible_hosts_file(hosts)
print("Ansible hosts file updated.")

# Test the Ansible setup
test_command = "ansible all -m ping"
print(f"Running test command: {test_command}")
test_result = subprocess.run(test_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print(test_result.stdout.decode())
if test_result.returncode == 0:
    print("Ansible setup is working correctly.")
else:
    print(f"Ansible setup failed. stderr: {test_result.stderr.decode()}")
