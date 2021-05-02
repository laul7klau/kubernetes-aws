#!/bin/sh
#Pre-requisites: You are in the same root directory after creating the ingress controller from the create-ingress.sh script.
#Remove nginx resources.
kubectl delete -f cafe-ingress.yaml
kubectl delete -f cafe-secret.yaml
kubectl delete -f cafe.yaml

kubectl delete namespace nginx-ingress
kubectl delete clusterrole nginx-ingress
kubectl delete clusterrolebinding nginx-ingress
kubectl delete -f common/crds

#Remove ingress link resources
kubectl delete -f ingresslink.yaml
kubectl delete -f cis-ingresslink-deployment.yaml
kubectl delete -f customresourcedefinitions.yaml
kubectl delete -f ingresslink-customresourcedefinition.yaml

#Remove big-ip cis resources
kubectl delete -f https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/k8s-rbac.yaml
kubectl delete serviceaccount bigip-ctlr -n kube-system
kubectl delete secret f5-bigip-ctlr-login -n kube-system
kubectl delete -f f5-hello-world-deployment.yaml
kubectl delete -f f5-hello-world-service.yaml
