
**Latest -- tested code**: [success_taste](https://github.com/gurubamal/success_taste/tree/main/cicd_ready_envt)

**Written by: Ram Nath (gurubamal)**

---

### NOTE:
The provided code currently functions flawlessly, ensuring the installation of the most up-to-date revisions of all components. However, it is crucial to recognize that software versions may undergo significant advancements in both code structure and installation procedures over time.  It works currently, but future support depends on my availability to fix any issues.

**NOTE**: The following is intended for hands-on learning and practicals. In production environments, follow security practices in scripts and implementations, which is not applicable to these practicals.

---

### Pre-requisites:

- Basic Linux skills are expected.
- On your hardware (laptop, desktop, server), ensure Secure Boot is disabled in the BIOS and virtualization is enabled.
- **Vagrant**, **VirtualBox** and **Git** should be pre-installed. (Restart your device once after installing VirtualBox.)
- Ensure your device doesn't go to sleep when idle (while scripts are running). Change power and battery settings as applicable.

    **NOTE (for re-setup)**: Ensure you have given full control to your users on the `success_taste` directory as the Vagrant script will create a second disk for each VM in it. Also, run VirtualBox as an administrator to see current VMs, as you are running PowerShell (and then Vagrant commands) as an Administrator. To clean up a previously run Vagrant setup, delete VMs (either via `vagrant up` or manually). If you delete VMs manually, delete VDI files from the directory where you ran `vagrant up` and also delete the `.vagrant` folder from the same directory. Additionally, check `C:\Users\<Your User Name>\VirtualBox VMs` for any folders that should be deleted as VMs are created there by default. In case you encounter the issue "VBOX_E_FILE_ERROR" or an error related to VDI, comment out lines 25-30 in your Vagrantfile to disable additional disk creation.

## Notes
- Most commands should be run with `success_taste/cicd_ready_envt/` as the present working directory.
- For Windows Hosts make sure you validate VBoxManage.exe PATH and if needed modify Vagrantfile to right Path  like this :  "\"C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage.exe\"  (as per your Virtualbox installation PATH in your windows system)
- Please note that sometimes you need to restart VirtualBox VMs because the latest modeled laptops, systems, and OS features may restrict and block them if they detect no activity in it.
- The setup downloads packages from the internet.
- The Linux admin user with sudo permissions will be `vagrant` (password: `vagrant`).
- Kubernetes VM IPs: 
  - Master node: 192.168.56.4
  - Compute node1: 192.168.56.5
  - Compute node2: 192.168.56.6
- Commands need to be run only once in the same environment.
- Setup may take 30-60 minutes to complete, depending on your internet speed.

## Contact
For any queries, reach out to me at: [gurubamal@gmail.com](mailto:gurubamal@gmail.com)

---

## Kubernetes Installation Instructions

1. Navigate to the `success_taste/cicd_ready_envt/` directory and ensure all scripts are executable:
    \`\`\`
    chmod +x *.sh
    \`\`\`
2. Run the setup:
    \`\`\`
    vagrant up
    \`\`\`

NOTE: If you find your setup (vagrant up command) stuck in the middle on any of the nodes, you can log in to the node and complete the setup by running these scripts manually as well.

      /vagrant/scripts/01_set.sh
      sudo python3 /vagrant/scripts/02_set.py
      sudo python3 /vagrant/scripts/03_set.py
      sudo python3 /vagrant/scripts/04_set.py
      sudo python3 /vagrant/scripts/05_set.py
      /vagrant/scripts/07_set.sh
      /vagrant/scripts/08_set.sh
      /vagrant/scripts/09_set.sh
      /vagrant/scripts/compute_add.sh
      
Ensure you have restarted your machine/laptop before "vagrant up" command. If your setup was incomplete due to SSH connectivity or connection issues, you can reset/restart the Virtual box VMs (as per previous logs from vagrant up command) on the VirtualBox interface. After waiting for 2 minutes, run "vagrant up" again. you can alsways start fresh using "vagrant destroy -f" first and "vagrant up" command second.

Restart your new VMs (all nodes) after this setup is complete.
   
### K8s Cluster + Jenkins + Ansible
- Access the master node at 192.168.56.4 using the `vagrant` or `root` user.
- Jenkins server is available at `192.168.56.4:8080`; the password can be found in the specified file at this URL.
- "Vagrant up" command will not setup Ansible for you. To complete the Ansible setup and start using it for practice, run following command (on node4 -- 192.168.56.4): ``` sudo python3 /vagrant/scripts/06_set.py ```

You can use the code from https://github.com/gurubamal/project_work-Industry-Grade-Project-2/tree/master, where I have created a pipeline test on this setup for reference.

---

## Vagrant Cleanup
To clean any previously implemented setup, use the command:
\`\`\`
vagrant destroy -f
\`\`\`
Ensure you are in the `success_taste/cicd_ready_envt/` directory where the `Vagrantfile` is located when running Vagrant commands.
