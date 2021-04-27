The files in this directory configure BIG-IP Controller Ingress Service:  
- k8s-rbac.yaml: Cluster and Cluster Role binding configuration  
- customresourcedefinitions.yaml: When using CIS in CRD mode  
- cis-deployment: To install CIS as a pod in the kube-system namespace    
- as3.yaml: To configure the BIG-IP in a new partition    
- f5-hello-world-deployment.yaml: To deploy a list of apps as pods in the default namespace    
- f5-hello-world-service.yaml: To expose the list of apps as Kubernetes services.

## Source
[F5 CIS on Clouddocs](https://clouddocs.f5.com/containers/latest/userguide/kubernetes/#examples-repository).  
The [F5Networks / k8s-bigip-ctlr repository](https://github.com/F5Networks/k8s-bigip-ctlr).  
