#!/bin/sh
#Pre-requisites: You are in the same root directory after creating the ingress controller from the create-ingress.sh script.
cd kubernetes-ingress/deployments
kubectl delete -f cafe-ingress.yaml
kubectl delete -f cafe-secret.yaml
kubectl delete -f cafe.yaml

kubectl delete namespace nginx-ingress
kubectl delete clusterrole nginx-ingress
kubectl delete clusterrolebinding nginx-ingress
kubectl delete -f common/crds

cd ../..
echo "Manually remove the NGINX ingress github clone with *'rm -rf kubernetes-ingress'*"
