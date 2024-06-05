
**Latest -- tested code**: [success_taste](https://github.com/gurubamal/success_taste/tree/main/cicd_setup_local)

**Written by: Ram Nath (gurubamal)**

---

### NOTE:
The provided code currently functions flawlessly, ensuring the installation of the most up-to-date revisions of all components. However, it is crucial to recognize that software versions may undergo significant advancements in both code structure and installation procedures over time. Therefore, it is essential to periodically review and update the code to ensure compatibility with future upgrades.

**NOTE**: The following is intended for hands-on learning and practicals. In production environments, follow security practices in scripts and implementations, which is not applicable to these practicals.

**Tutorial Videos**: (I intend to make and upload some YouTube videos on "Practicals on Container Security" and "K8s Network Made Simple" with hands-on practice examples once I complete some of my urgent work successfully)

[YouTube Tutorial](https://www.youtube.com/watch?v=Hqkujcop3NE&t=5s)

---

### Pre-requisites:

- Basic Linux skills are expected.
- On your hardware (laptop, desktop, server), ensure Secure Boot is disabled in the BIOS and virtualization is enabled.
- **Vagrant**, **VirtualBox** (on Windows 10 - use VirtualBox version 5.4.2 only), and **Git** should be pre-installed. (Restart your device once after installing VirtualBox.)
- Ensure your device doesn't go to sleep when idle (while scripts are running). Change power and battery settings as applicable.

    **NOTE (for re-setup)**: Ensure you have given full control to your users on the `success_taste` directory as the Vagrant script will create a second disk for each VM in it. Also, run VirtualBox as an administrator to see current VMs, as you are running PowerShell (and then Vagrant commands) as an Administrator. To clean up a previously run Vagrant setup, delete VMs (either via `vagrant up` or manually). If you delete VMs manually, delete VDI files from the directory where you ran `vagrant up` and also delete the `.vagrant` folder from the same directory. Additionally, check `C:\Users\<Your User Name>\VirtualBox VMs` for any folders that should be deleted as VMs are created there by default. In case you encounter the issue "VBOX_E_FILE_ERROR" or an error related to VDI, comment out lines 25-30 in your Vagrantfile to disable additional disk creation.

- On Windows 10, use VirtualBox version 5.4.2 only. For best functionality, follow and set the environment: [Vagrant WSL Setup](https://www.vagrantup.com/docs/other/wsl). Optionally, you can use PowerShell and run the following commands (must be an administrator) in PowerShell:

    ```sh
    vagrant plugin update
    vagrant plugin install vagrant-vbguest 
    ```

- Run all Vagrant commands from the `success_taste` directory (clone it using: `git clone https://github.com/gurubamal/success_taste.git`).

    ```sh
    vagrant plugin install vagrant-vbguest
    ```

- For Linux or Mac terminal users:

    ```sh
    echo "export VAGRANT_DEFAULT_PROVIDER=virtualbox" >> ~/.bashrc ; source ~/.bashrc
    chmod +x *.sh
    ```

### Notes:

1. Most commands should be executed from the `success_taste` directory or the respective setup directory as the present working directory. The complete setup will download packages from the internet.
2. The Linux admin user (with sudo permissions) and password will be `vagrant` (both username and password). 
   - K8s VM IPs:
     - Master Node: 192.168.58.6
     - Compute Node: 192.168.58.7
     - Compute Node: 192.168.58.8
3. The above commands need to be run only once in the same environment.
4. Each section may take 30-60 minutes to complete, depending on your internet speed.

You can reach out to me at: [gurubamal@gmail.com](mailto:gurubamal@gmail.com)

---

### Vagrant Cleanup

To clean any previously implemented setup, use the following command:

```sh
vagrant destroy
```

Ensure the correct Vagrantfile is in use when running Vagrant commands, as Vagrant reads the current Vagrantfile. You may need to copy or rename the appropriate Vagrantfile to ensure your VMs are removed properly (Vagrant commands only act on the current Vagrantfile).
