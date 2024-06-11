import subprocess

def run_shell_script(script_path):
    try:
        # Ensure the script has execute permissions
        subprocess.run(['chmod', '+x', script_path], check=True)

        # Run the shell script
        result = subprocess.run(['sudo', 'bash', script_path], capture_output=True, text=True)
        print(result.stdout)
        if result.returncode != 0:
            print(f"Error running script: {result.stderr}")
    except subprocess.CalledProcessError as e:
        print(f"Script failed with error: {e}")

if __name__ == "__main__":
    script_path = '/vagrant/scripts/setup_kubernetes.sh'
    run_shell_script(script_path)
