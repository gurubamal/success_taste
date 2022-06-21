cat jenkins_install.sh| vagrant ssh node6  -c 'sudo tee jenkins_install.sh'
vagrant ssh node6  -c 'sudo chmod +x jenkins_install.sh'
vagrant ssh node6  -c './jenkins_install.sh'
