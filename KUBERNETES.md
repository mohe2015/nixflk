# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

https://helm.sh/


kubectl apply -f ./kubernetes/static-nginx-deployment.yaml
kubectl get pods -l run=my-nginx -o wide
kubectl get pods -l run=my-nginx -o yaml | grep podIP

kubectl create -f ./kubernetes/static-nginx-service.yaml

kubectl get nodes -o wide

kubectl get svc my-nginx -o yaml | grep nodePort -C 5
kubectl get nodes -o yaml | grep ExternalIP -C 1

curl 46.101.164.27:31583

kubectl edit svc my-nginx

kubectl get svc my-nginx

kubectl describe service my-nginx

https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/