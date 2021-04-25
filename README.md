# kubernetes-aws
This section describes the steps to deploy a Kubernetes cluster on AWS based on the configuration in kube-cluster.yaml.

## Pre-requisites:
1. Install aws cli on your client device. Refer to [Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. Configure your AWS credentials.
   - Go to IAM role > Users > <User> > Security Credentials, select **Create access key**.
   - Enter *aws configure*
3. Generate SSH key pair. The key is referenced by kube-cluster.yanl to enable login to kubernetes nodes.
   - Enter: *ssh-keygen*
4. Install **eksctl** on your client device to manage the k8 cluster. Refer to [Installing eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

## Steps:
1. View *kube-cluster.yaml* which contains the basic configuration for a cluster on AWS. Refer to [eksctl yaml file examples](https://github.com/weaveworks/eksctl/tree/main/examples) 
2. Create the cluster by entering:  
*eksctl create cluster -f kube-cluster.yaml*. 

The cluster creation process on AWS will typically take 25-30mins. 

## Verification:
The following Kubernetes objects are created by the default kube-cluster.yaml.
- 1 Kubernetes cluster.
- 2 public nodes as BIG-IP instances. External IP addresses assigned.
- 1 private node as BIG-IP instance.

```  
$ kubectl $ kubectl get all -n kube-system
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
replicaset.apps/coredns-6548845887   2         2         2       29h```

## 
