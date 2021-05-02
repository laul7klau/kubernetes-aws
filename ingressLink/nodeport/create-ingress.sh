#!/bin/sh
git clone https://github.com/nginxinc/kubernetes-ingress/
cd kubernetes-ingress/deployments
git checkout v1.11.1
#Set up files
cp ../examples/complete-example/cafe.yaml .
cp ../examples/complete-example/cafe-secret.yaml .
wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/nginx-ingress/config/cafe-ingress.yaml
wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/nginx-ingress/config/nginx-config.yaml
#Install Ingress Controller per https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f rbac/rbac.yaml

kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f common/ingress-class.yaml

kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
kubectl apply -f common/crds/k8s.nginx.org_globalconfigurations.yaml
kubectl apply -f common/global-configuration.yaml
#Install Ingress Controller pods as daemonset
kubectl apply -f daemon-set/nginx-ingress.yaml
#Exposing service as nodeport and creating AWS loadbalancer
kubectl create -f service/nodeport.yaml
kubectl apply -f nginx-config.yaml
#Configuring coffee tea app by configuring Ingress Controller through ingress resource
kubectl create -f cafe.yaml
kubectl create -f cafe-secret.yaml
kubectl create -f cafe-ingress.yaml
