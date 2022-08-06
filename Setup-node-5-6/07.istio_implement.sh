git clone https://github.com/DickChesterwood/istio-fleetman.git
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/1-istio-init.yaml
echo "wait for 3 minutes! services are coming up..."
sleep 180
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/2-istio-minikube.yaml
#Set label in default namespace for istio-injection to enabled
kubectl label namespace default istio-injection=enabled
echo "wait for 3 minutes! services are coming up..."
sleep 180
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/3-kiali-secret.yaml
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/4-application-full-stack.yaml
echo 	"kiali services will be running at http://192.168.58.6:31000/
	and fleet management app will be availabe at  http://192.168.58.6:30080/"
