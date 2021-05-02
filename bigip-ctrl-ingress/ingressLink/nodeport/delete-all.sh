#!/bin/sh
#Pre-requisites: You are in the same root project directory where 'ingresslink.yaml' and the 'kubernetes-ingress' github directory is located.
#Remove nginx resources.
kubectl delete -f kubernetes-ingress/deployments/cafe-ingress.yaml
kubectl delete -f kubernetes-ingress/deployments/cafe-secret.yaml
kubectl delete -f kubernetes-ingress/deployments/cafe.yaml

kubectl delete namespace nginx-ingress
kubectl delete clusterrole nginx-ingress
kubectl delete clusterrolebinding nginx-ingress
kubectl delete -f kubernetes-ingress/deployments/common/crds

#Remove ingress link resources
kubectl delete -f ingresslink.yaml
kubectl delete -f cis-ingresslink-deployment.yaml
kubectl delete -f customresourcedefinitions.yaml
kubectl delete -f ingresslink-customresourcedefinition.yaml

#Remove big-ip cis resources. Warning: This will delete all BIG-IP CIS resources created in the parent directory as well.
kubectl delete -f https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/k8s-rbac.yaml
kubectl delete serviceaccount bigip-ctlr -n kube-system
kubectl delete secret f5-bigip-ctlr-login -n kube-system
kubectl delete -f f5-hello-world-deployment.yaml
kubectl delete -f f5-hello-world-service.yaml

echo "Manually remove the 'kubernetes-ingress' github directory: 'rm -f kubernetes-ingress'
