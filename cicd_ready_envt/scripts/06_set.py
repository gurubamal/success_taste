import os
import subprocess
import sys

# Define the password
pxt = "vagrant"

# Write the password to the .txtpwd file (equivalent to echo vagrant > .txtpwd)
password_file = ".txtpwd"
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

password = read_password(password_file)

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

# Define the nodes
nodes = {
    "node4": "192.168.56.4",
    "node5": "192.168.56.5",
    "node6": "192.168.56.6",
    "node7": "192.168.56.7",
}

# Check SSH connectivity and update the Ansible hosts file
with open("/etc/ansible/hosts", "a") as hosts_file:
    hosts_file.write("[nodes]\n")
    for node, ip in nodes.items():
        command = ["sshpass", "-p", password, "ssh", "-o", "StrictHostKeyChecking=no", f"vagrant@{ip}", "hostname"]
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f"stdout: {result.stdout.decode()}")
        print(f"stderr: {result.stderr.decode()}")
        if result.returncode == 0:
            hosts_file.write(f"{node} ansible_host={ip} ansible_user=vagrant ansible_ssh_pass={password}\n")
        else:
            print(f"Failed to connect to {node}")

# Test the Ansible setup
test_command = "ansible all -m ping"
print(f"Running test command: {test_command}")
test_result = subprocess.run(test_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print(test_result.stdout.decode())
if test_result.returncode == 0:
    print("Ansible setup is working correctly.")
else:
    print(f"Ansible setup failed. stderr: {test_result.stderr.decode()}")
