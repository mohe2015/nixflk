
USE https://github.com/prometheus-operator/kube-prometheus

kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090

kubectl --namespace monitoring port-forward svc/grafana 3000

kubectl --namespace monitoring port-forward svc/alertmanager-main 9093

https://grafana.com/docs/grafana-cloud/quickstart/prometheus_operator/

kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
kubectl get deploy

kubectl apply -f prom_rbac.yaml
kubectl apply -f prometheus.yaml
kubectl get prometheus
kubectl get pod

kubectl apply -f prom_svc.yaml
kubectl get service

kubectl port-forward svc/prometheus 9090

kubectl apply -f prometheus_servicemonitor.yaml







helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack

