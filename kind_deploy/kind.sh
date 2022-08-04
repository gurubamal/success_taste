sudo apt install docker.io
sudo apt install golang-go
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
sudo chmod +x kind
sudo mv kind /usr/bin/.
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/bin/
if ! ls kind-demo/
	then
	git clone https://github.com/vfarcic/kind-demo.git
	kind create cluster --name successtaste --config kind-demo/multi-node.yaml 
fi
#sudo kind create cluster
#sudo kubectl cluster-info --context kind-kind
