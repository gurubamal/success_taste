cat rceph_final.sh | vagrant ssh node6  -c 'sudo tee rceph_final.sh'
vagrant ssh node6  -c 'sudo chmod +x rceph_final.sh'
vagrant ssh node6  -c './rceph_final.sh'
