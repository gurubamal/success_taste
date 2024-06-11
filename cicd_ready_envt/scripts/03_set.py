import os

def get_current_ip():
    with os.popen("ip r s") as f:
        for line in f:
            if "src" in line and "192.168.56" in line:
                ip = line.split("src")[1].strip().split(" ")[0]
                return ip
    return None

def get_hostname_for_ip(ip):
    hosts_file = "/etc/hosts"
    with open(hosts_file, "r") as file:
        for line in file:
            if line.startswith(ip):
                parts = line.split()
                if len(parts) > 1:
                    return parts[1]
    return None

def set_hostname(hostname):
    os.system(f"hostnamectl set-hostname {hostname}")
    print(f"Hostname set to {hostname}")

def main():
    ip = get_current_ip()
    if not ip:
        print("IP address not found in the range 192.168.56.*.")
        return

    hostname = get_hostname_for_ip(ip)
    if not hostname:
        print(f"No hostname entry found for IP {ip} in /etc/hosts.")
        return

    current_hostname = os.popen("hostname").read().strip()
    if current_hostname != hostname:
        set_hostname(hostname)
    else:
        print(f"Current hostname {current_hostname} matches the /etc/hosts entry.")

if __name__ == "__main__":
    main()
