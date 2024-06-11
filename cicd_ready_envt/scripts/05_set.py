import subprocess
import socket
import os

def run_command(command):
    """
    Function to run a system command and print the output.
    """
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if result.returncode == 0:
        print(f"Success: {result.stdout}")
    else:
        print(f"Error: {result.stderr}")

def add_line_to_file(line, filepath):
    """
    Function to add a line to a file if it doesn't already exist.
    """
    if not os.path.exists(filepath):
        with open(filepath, 'w') as file:
            file.write(line + '\n')
    else:
        with open(filepath, 'r') as file:
            lines = file.readlines()
            if line not in [line.strip() for line in lines]:
                with open(filepath, 'a') as file:
                    file.write(line + '\n')

def read_initial_admin_password():
    """
    Function to read the initial Jenkins admin password.
    """
    password_file = '/var/lib/jenkins/secrets/initialAdminPassword'
    if os.path.exists(password_file):
        with open(password_file, 'r') as file:
            password = file.read().strip()
            print(f"Initial Jenkins Admin Password: {password}\nStart using Jenkins, available at http://192.168.56.4:8080/")
    else:
        print("Jenkins initial admin password file does not exist.")

def install_jenkins():
    """
    Function to install Jenkins on an Ubuntu server.
    """
    # Check if the hostname is node4
    if socket.gethostname() != "node4":
        print("This script can only be run on node4.")
        return
    
    # Update the system
    run_command('sudo apt update')
    
    # Install Java (Jenkins requires Java)
    run_command('sudo apt install -y openjdk-11-jdk')
    
    # Set JAVA_HOME environment variable
    java_home_path = 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))'
    add_line_to_file(java_home_path, '/etc/profile')
    run_command('. /etc/profile')
    
    # Add Jenkins repository key to the system
    run_command('curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null')
    
    # Append the Debian package repository address to the server's sources.list
    repo_line = 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/'
    add_line_to_file(repo_line, '/etc/apt/sources.list.d/jenkins.list')
    
    # Update the system again after adding the Jenkins repository
    run_command('sudo apt update')
    
    # Install Jenkins
    run_command('sudo apt install -y jenkins')
    
    # Start Jenkins service
    run_command('sudo systemctl start jenkins')
    
    # Enable Jenkins service to start on boot
    run_command('sudo systemctl enable jenkins')
    
    # Ensure firewall allows Jenkins (if UFW is enabled)
    run_command('sudo ufw allow 8080')
    run_command('sudo ufw --force enable')
    run_command('sudo ufw status')
    
    # Read and print the initial admin password
    read_initial_admin_password()

if __name__ == "__main__":
    install_jenkins()
