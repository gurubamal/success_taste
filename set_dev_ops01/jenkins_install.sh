git clone https://github.com/scriptcamp/kubernetes-jenkins

kubectl create namespace devops-tools

kubectl apply -f serviceAccount.yaml
kubectl create -f volume.yaml
kubectl apply -f deployment.yaml

#echo "Getting everything ready..."
#sleep 300
kubectl apply -f service.yaml
#kubectl get pods --namespace=devops-tools|grep '1/1'
STATUS=$(echo $?)
if  [[ $STATUS == 0 ]]
	then	echo "Runnning next Steps..."
	else	sleep 60
fi


JENKINS_POD=$(kubectl get pods --namespace=devops-tools|tail -1|awk '{print $1}')

echo 'use http://192.168.58.6:32000/login URL for jenkins login with password mentioned below:'
kubectl exec $JENKINS_POD -n devops-tools -- cat  /var/jenkins_home/secrets/initialAdminPassword
