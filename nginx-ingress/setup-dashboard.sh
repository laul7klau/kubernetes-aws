#!/bin/sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl proxy &
kubectl -n kube-system describe secret deployment-controller-token
echo "\n\n\n\nLogin to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy with token above.\n"
