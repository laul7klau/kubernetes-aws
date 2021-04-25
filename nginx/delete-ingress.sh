#!/bin/sh
cd kubernetes-ingress/deployments
kubectl delete -f cafe-ingress.yaml
kubectl delete -f cafe-secret.yaml
kubectl delete -f cafe.yaml

kubectl delete namespace nginx-ingress
kubectl delete clusterrole nginx-ingress
kubectl delete clusterrolebinding nginx-ingress
kubectl delete -f common/crds
