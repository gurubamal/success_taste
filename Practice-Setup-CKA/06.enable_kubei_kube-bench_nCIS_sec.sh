kubectl apply -f kubei.yaml
###
git clone   https://github.com/aquasecurity/kube-bench.git
cd kube-bench/
kubectl apply -f job-node.yaml
kubectl apply -f job-master.yaml
kubectl get pods
#kubectl logs "master"|tee master.audit.report
#kubectl logs "node"| tee node.audit.report
###
sudo apt-cache policy ubuntu-advantage-tools
sudo apt-cache policy ubuntu-advantage-tools
sudo apt install ubuntu-advantage-tools usg
sudo ua version
sudo ua status
sudo ua attach C148smEmHdTdUDj2LfUkFKCFQii34g
sudo ua enable usg
sudo apt install libopenscap8
#sudo usg audit level2_server
