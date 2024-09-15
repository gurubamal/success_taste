import subprocess

def run_command(command):
    """Run a shell command."""
    subprocess.run(command, shell=True, check=True)

def is_package_installed(package_name):
    """Check if a package is installed."""
    result = subprocess.run(f"dpkg -l | grep -qw {package_name}", shell=True)
    return result.returncode == 0

def install_packages():
    """Install required packages if they are not already installed."""
    packages = ['openssh-server', 'sshpass']
    for package in packages:
        if not is_package_installed(package):
            run_command(f"sudo apt -y install {package}")
        else:
            print(f"{package} is already installed.")

def update_sshd_config():
    """Update the SSHD config to disable root login if not already set."""
    config_path = '/etc/ssh/sshd_config'
    with open(config_path, 'r') as file:
        config_lines = file.readlines()

    config_changed = False
    with open(config_path, 'w') as file:
        for line in config_lines:
            if line.strip().startswith('PermitRootLogin'):
                if 'no' not in line:
                    file.write('PermitRootLogin no\n')
                    config_changed = True
                else:
                    file.write(line)
            else:
                file.write(line)

    if not config_changed:
        print("PermitRootLogin is already set to 'no'.")

def restart_ssh_service():
    """Restart the SSH service."""
    run_command("sudo systemctl restart ssh")

def main():
    """Main function to install and configure OpenSSH server and sshpass."""
    install_packages()
    update_sshd_config()
    restart_ssh_service()
    print("OpenSSH server and sshpass installed and configured successfully.")

if __name__ == "__main__":
    main()
