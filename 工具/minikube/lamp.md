
kubectl apply -k ./

minikube service wordpress --url

kubectl delete -k ./


https://kubernetes.io/zh/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/