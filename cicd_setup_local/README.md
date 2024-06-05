
**Written by: Ram Nath (gurubamal)**

---

### NOTE:
The provided code currently functions flawlessly, ensuring the installation of the most up-to-date revisions of all components. However, it is crucial to recognize that software versions may undergo significant advancements in both code structure and installation procedures over time. Therefore, it is essential to periodically review and update the code to ensure compatibility with future upgrades.

Please ignore any error messages when you run the vagrant up command. I have included extensive error handling, so errors may appear as part of the pre-requisite checks.

**My YouTube Channel**: [https://www.youtube.com/@iySetsfineWorkc](https://www.youtube.com/@iySetsfineWorkc)

---

### Pre-requisites:

- Basic Linux skills are expected.
- On your hardware (laptop, desktop, server), ensure Secure Boot is disabled in the BIOS and virtualization is enabled. 24GB system RAM is required.
- **VAGRANT**, **VIRTUALBOX**, and **GIT** should be pre-installed. (Restart your device once after installing VirtualBox.)
- Ensure you are connected to the internet.
- Run all commands from the `success_taste` directory (clone it using: `git clone https://github.com/gurubamal/success_taste.git`).

    ```sh
    vagrant plugin install vagrant-vbguest
    ```

- For Linux or Mac terminal users:

    ```sh
    echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc
    chmod +x *.sh
    ```

### Notes:

1. Most commands should be executed from the `success_taste/cicd_setup_local` directory as the present working directory. The complete setup will download packages from the internet.
2. The Linux admin user (with sudo permissions) and password will be `vagrant` (both username and password). 
   - K8s VM IPs:
     - Master Node: 192.168.58.6
     - Compute Node: 192.168.58.7
     - Jenkins Node: 192.168.58.8
     - Jenkins Ansible Controller: 192.168.58.9
3. The above commands need to be run only once in the same environment.
4. Each section may take 30-60 minutes to complete, depending on your internet speed.

You can reach out to me at: [gurubamal@gmail.com](mailto:gurubamal@gmail.com)

---

### Kubernetes Setup

**Instructions for K8s Installation:**

1. Switch to the `success_taste/cicd_setup_local` directory and ensure all scripts are executable:

    ```sh
    chmod +x *.sh
    ```

2. Run the following commands:

    ```sh
    cp Vagrantfile_k8s_node6n7 Vagrantfile
    vagrant up 
    ssh vagrant@192.168.58.6 (password: vagrant)
    ```

    Check `kubectl` commands.

    - Node 6 will be the master node, whereas Node 7 will be the worker node.
    - Note: The value `interface=eth1` in `calico.yaml` was set because my VirtualBox VMs use `eth1` as the default network device with IP `192.168.58.x`. Adjust this setting if the `eth` name varies on your machines.

---

### Jenkins Setup

**Instructions for Jenkins Installation:**

1. Switch to the `success_taste/cicd_setup_local` directory and ensure all scripts are executable:

    ```sh
    chmod +x *.sh
    ```

2. Run the following commands:

    ```sh
    cp Vagrantfile_jenkins_node8 Vagrantfile
    vagrant up 
    ```

    Browse Jenkins at [http://192.168.58.8:8080](http://192.168.58.8:8080).

    Fetch the password with the following command:

    ```sh
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

---

### Ansible & Docker Repository Setup

**Instructions for Ansible & Docker Repository Installation:**

1. Switch to the `success_taste/cicd_setup_local` directory and ensure all scripts are executable:

    ```sh
    chmod +x *.sh
    ```

2. Run the following commands:

    ```sh
    cp Vagrantfile_ansible_node9 Vagrantfile
    vagrant up 
    ssh vagrant@192.168.58.9 (password: vagrant)
    ```

    Check Ansible and Docker commands for automations and repository:

    ```sh
    docker ps
    ```

    Example output:

    ```
    CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS          PORTS                                       NAMES
    484668f20499   registry:2   "/entrypoint.sh /etc…"   15 minutes ago   Up 15 minutes   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   registry
    ```

---

### Vagrant Cleanup

To clean any previously implemented setup, use the following command:

```sh
vagrant destroy
```

Ensure the correct Vagrantfile is in use when running Vagrant commands, as Vagrant reads the current Vagrantfile. You may need to copy or rename the appropriate Vagrantfile to ensure your VMs are removed properly (Vagrant commands only act on the current Vagrantfile).
