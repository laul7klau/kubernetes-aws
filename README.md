# kubernetes-aws
This repository is a step by step guide for the QUICK deployment of NGINX Ingress Controller or BIG-IP Container Ingress Service for Kubernetes.  

Map:
- **kubernetes-aws**:  
  Perform the steps in this README.md first to first deploy a Kubernetes cluster on AWS.    
     - **nginx-ingress**: Perform the steps here to deploy NGINX ingress controller.  
     OR
     - **bigip-ctrl-ingress**: Perform the steps here if you want to deploy BIG-IP CIS.  

## Pre-requisites:
1. Install aws cli on your client device. Refer to [Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. Configure your AWS credentials.
   - Go to IAM role > Users > <User> > Security Credentials, select **Create access key**.
   - Enter *aws configure*
3. Generate SSH key pair. The key is referenced by kube-cluster.yaml to enable login to kubernetes nodes.
   - Enter: *ssh-keygen*
4. Install **eksctl** on your client device to manage the k8 cluster. Refer to [Installing eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

## Steps:
1. Download *kube-cluster.yaml* which contains the basic configuration for a cluster on AWS. Refer to [eksctl yaml file examples](https://github.com/weaveworks/eksctl/tree/main/examples)  
   ``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/kube-cluster.yaml``
2. Create the cluster by entering:  
   ``eksctl create cluster -f kube-cluster.yaml``   
3. Set up the kubernetes dashboard.  
   - chmod u+x setup-dashboard.sh
   - ./setup-dashboard.sh
   - Access the dashboard using the link and token from the output of the script.

The cluster creation process on AWS will typically take 25-30mins. 

## Verification:
The following Kubernetes objects are created by the default kube-cluster.yaml
- 1 Kubernetes cluster.
- 2 public nodes as AWS instances. External IP addresses assigned.
- 1 private node as AWS instance.  
  
```$ kubectl get nodes. 
NAME                                           STATUS   ROLES    AGE   VERSION   
ip-<IP>.us-west-2.compute.internal   Ready    <none>   43h   v1.19.6-eks-49a6c0  
ip-<IP>.us-west-2.compute.internal   Ready    <none>   43h   v1.19.6-eks-49a6c0  
ip-<IP>.us-west-2.compute.internal   Ready    <none>   43h   v1.19.6-eks-49a6c0  

$ kubectl get all -n kube-system   
NAME                           READY   STATUS    RESTARTS   AGE  
pod/aws-node-fmf9h             1/1     Running   0          29h  
pod/aws-node-ms9ts             1/1     Running   0          29h  
pod/aws-node-z2zzv             1/1     Running   0          29h  
pod/coredns-6548845887-lxtk4   1/1     Running   0          29h  
pod/coredns-6548845887-wj679   1/1     Running   0          29h  
pod/kube-proxy-48fmz           1/1     Running   0          29h  
pod/kube-proxy-pvjsv           1/1     Running   0          29h  
pod/kube-proxy-whzt7           1/1     Running   0          29h  

NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE  
service/kube-dns   ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   29h  

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE  
daemonset.apps/aws-node     3         3         3       3            3           <none>          29h  
daemonset.apps/kube-proxy   3         3         3       3            3           <none>          29h  

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE  
deployment.apps/coredns   2/2     2            2           29h  

NAME                                 DESIRED   CURRENT   READY   AGE  
replicaset.apps/coredns-6548845887   2         2         2       29h.```   
```  

## Destroy.  
On the AWS console, go to Services > CloudFormation.   
Select the nodegroup stacks, select Delete. 
Select the Kubernetes cluster, select Delete.  

## What's next:  
- Go to the sub directory, *nginx-ingress*, to create NGINX Ingress Controller.    
OR
- Go to the sub directory *bigip-ctrl-ingress* to create the BIG-IP Controller Ingress Service, CIS.  
  -  Then go to the sub-sub directory *Ingress link*, to create the NGINX Ingress Controller and F5 Ingress Link.  
